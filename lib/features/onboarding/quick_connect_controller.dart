import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/jellyfin/jellyfin_client.dart';
import 'onboarding_controller.dart';

/// State machine for an in-flight Quick Connect attempt. Modelled as a sealed
/// type so consumers can pattern-match exhaustively (`switch (state) { ... }`)
/// without forgetting a branch.
sealed class QuickConnectState {
  const QuickConnectState();
}

class QcIdle extends QuickConnectState {
  const QcIdle();
}

class QcLoading extends QuickConnectState {
  const QcLoading();
}

class QcPending extends QuickConnectState {
  const QcPending({required this.code});
  final String code;
}

class QcApproved extends QuickConnectState {
  const QcApproved();
}

class QcDone extends QuickConnectState {
  const QcDone();
}

class QcError extends QuickConnectState {
  const QcError(this.message);
  final String message;
}

class QcTimeout extends QuickConnectState {
  const QcTimeout();
}

/// Parameters to start a Quick Connect flow against a specific server.
class QuickConnectArgs {
  const QuickConnectArgs({
    required this.serverUrl,
    this.proxyAuth,
    this.serverName,
    this.serverId,
  });
  final String serverUrl;
  final String? proxyAuth;
  final String? serverName;
  final String? serverId;
}

const _qcPollInterval = Duration(seconds: 3);
const _qcTimeout = Duration(minutes: 5);

final quickConnectControllerProvider =
    AutoDisposeNotifierProvider<QuickConnectController, QuickConnectState>(
      QuickConnectController.new,
    );

/// Drives a Quick Connect attempt end-to-end:
///   1. POST /QuickConnect/Initiate → display the 6-char code to the user.
///   2. Poll /QuickConnect/Connect every 3 s until `authenticated == true`
///      (or [_qcTimeout] elapses).
///   3. POST /Users/AuthenticateWithQuickConnect → real `AuthenticationResult`.
///   4. Hand off to [OnboardingController.finalizeQuickConnect] which persists
///      the account and switches the active session.
class QuickConnectController extends AutoDisposeNotifier<QuickConnectState> {
  CancelToken? _cancelToken;
  bool _disposed = false;

  @override
  QuickConnectState build() {
    ref.onDispose(() {
      _disposed = true;
      _cancelToken?.cancel('disposed');
    });
    return const QcIdle();
  }

  /// Starts a new Quick Connect flow. Safe to call once per controller
  /// lifecycle; calling again while one is running is a no-op.
  Future<void> start(QuickConnectArgs args) async {
    if (state is! QcIdle && state is! QcError && state is! QcTimeout) return;
    _cancelToken = CancelToken();
    state = const QcLoading();

    final client = ref.read(jellyfinClientProvider);
    try {
      final initiated = await client.initiateQuickConnect(
        serverUrl: args.serverUrl,
        proxyAuth: args.proxyAuth,
      );
      final code = initiated.code;
      final secret = initiated.secret;
      if (code == null || secret == null) {
        _safeSetState(const QcError('Server returned an invalid response'));
        return;
      }
      _safeSetState(QcPending(code: code));

      final approved = await _pollUntilApproved(
        client: client,
        secret: secret,
        args: args,
      );
      if (!approved || _disposed) return;

      _safeSetState(const QcApproved());

      final auth = await client.authenticateWithQuickConnect(
        serverUrl: args.serverUrl,
        secret: secret,
        proxyAuth: args.proxyAuth,
      );
      if (_disposed) return;

      await ref
          .read(onboardingControllerProvider)
          .finalizeQuickConnect(
            auth: auth,
            serverUrl: args.serverUrl,
            proxyAuth: args.proxyAuth,
            serverName: args.serverName,
            serverId: args.serverId,
          );
      _safeSetState(const QcDone());
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || _disposed) return;
      _safeSetState(QcError(_humanError(e)));
    } on Object catch (e) {
      if (_disposed) return;
      _safeSetState(QcError(e.toString()));
    }
  }

  /// Aborts an in-flight flow. The sheet calls this from its dispose / cancel
  /// button. After cancel the controller stays in its last visible state and
  /// can be restarted via [start].
  void cancel() {
    _cancelToken?.cancel('user-cancel');
  }

  Future<bool> _pollUntilApproved({
    required JellyfinClient client,
    required String secret,
    required QuickConnectArgs args,
  }) async {
    final deadline = DateTime.now().add(_qcTimeout);
    while (!_disposed && DateTime.now().isBefore(deadline)) {
      // Sleep first so we don't hammer the server immediately after Initiate
      // (Jellyfin needs a moment to register the request anyway).
      await Future<void>.delayed(_qcPollInterval);
      if (_disposed) return false;
      final ct = _cancelToken;
      if (ct == null || ct.isCancelled) return false;
      final res = await client.pollQuickConnect(
        serverUrl: args.serverUrl,
        secret: secret,
        proxyAuth: args.proxyAuth,
        cancelToken: ct,
      );
      if (res.authenticated ?? false) return true;
    }
    if (!_disposed) _safeSetState(const QcTimeout());
    return false;
  }

  void _safeSetState(QuickConnectState next) {
    if (_disposed) return;
    state = next;
  }

  String _humanError(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401) return 'Quick Connect rejected by the server';
    if (code == 404) return 'This server does not support Quick Connect';
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not reach the server';
    }
    return 'Quick Connect failed (${e.message ?? 'unknown error'})';
  }
}
