import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bridge_errors.dart';

/// Lightweight one-shot bus for surfacing typed plugin errors to the UI.
///
/// Data providers that catch a [BridgeException] they want to display can
/// `ref.read(bridgeErrorBusProvider.notifier).state = e`. The home screen
/// listens to this state and shows a snackbar, then clears the state. This
/// keeps Flutter `BuildContext` out of the `core/` data layer.
final bridgeErrorBusProvider = StateProvider<BridgeException?>((_) => null);
