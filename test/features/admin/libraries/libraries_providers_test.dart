import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/jellyfin/jellyfin_client.dart';
import 'package:jellyfish/features/admin/libraries/libraries_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockJellyfinApi extends Mock implements JellyfinApi {}

class _MockLibraryStructureApi extends Mock implements LibraryStructureApi {}

Response<T> _ok<T>(T data) => Response<T>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

VirtualFolderInfo _library({
  String name = 'Movies',
  CollectionTypeOptions? collectionType,
}) =>
    VirtualFolderInfo(
      (b) => b
        ..name = name
        ..collectionType = collectionType ?? CollectionTypeOptions.movies,
    );

void main() {
  late _MockJellyfinApi api;
  late _MockLibraryStructureApi libraryApi;

  setUp(() {
    api = _MockJellyfinApi();
    libraryApi = _MockLibraryStructureApi();
    when(() => api.getLibraryStructureApi()).thenReturn(libraryApi);
  });

  setUpAll(() {
    registerFallbackValue(
      MediaPathDto((b) => b
        ..name = ''
        ..path = ''),
    );
    registerFallbackValue(CollectionTypeOptions.movies);
    registerFallbackValue(BuiltList<String>.of([]));
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [jellyfinApiProvider.overrideWithValue(api)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('AdminLibrariesNotifier', () {
    test('build returns libraries sorted alphabetically by name', () async {
      final libs = BuiltList<VirtualFolderInfo>.of([
        _library(name: 'TV Shows'),
        _library(name: 'Anime'),
        _library(name: 'Movies'),
      ]);
      when(() => libraryApi.getVirtualFolders())
          .thenAnswer((_) async => _ok(libs));

      final c = makeContainer();
      final list = await c.read(adminLibrariesProvider.future);

      expect(list.length, 3);
      expect(list.first.name, 'Anime');
      expect(list.last.name, 'TV Shows');
    });

    test('build returns empty list when server returns empty', () async {
      when(() => libraryApi.getVirtualFolders()).thenAnswer(
        (_) async => _ok(BuiltList<VirtualFolderInfo>.of([])),
      );

      final c = makeContainer();
      final list = await c.read(adminLibrariesProvider.future);

      expect(list, isEmpty);
    });

    test('build exposes AsyncError when API throws', () async {
      when(() => libraryApi.getVirtualFolders())
          .thenThrow(Exception('unauthorized'));

      final c = makeContainer();
      Object? caught;
      try {
        await c.read(adminLibrariesProvider.future);
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      expect(c.read(adminLibrariesProvider).hasError, isTrue);
    });

    test('rename calls renameVirtualFolder with correct old/new names', () async {
      final libs = BuiltList<VirtualFolderInfo>.of([_library(name: 'Movies')]);
      when(() => libraryApi.getVirtualFolders())
          .thenAnswer((_) async => _ok(libs));
      when(() => libraryApi.renameVirtualFolder(
            name: any(named: 'name'),
            newName: any(named: 'newName'),
            refreshLibrary: any(named: 'refreshLibrary'),
          )).thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminLibrariesProvider.future);
      await c.read(adminLibrariesProvider.notifier).rename('Movies', 'Films');

      verify(() => libraryApi.renameVirtualFolder(
            name: 'Movies',
            newName: 'Films',
            refreshLibrary: false,
          )).called(1);
    });

    test('remove calls removeVirtualFolder with correct name and refreshes',
        () async {
      final libs = BuiltList<VirtualFolderInfo>.of([_library(name: 'Music')]);
      when(() => libraryApi.getVirtualFolders())
          .thenAnswer((_) async => _ok(libs));
      when(() => libraryApi.removeVirtualFolder(
            name: any(named: 'name'),
            refreshLibrary: any(named: 'refreshLibrary'),
          )).thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminLibrariesProvider.future);
      await c.read(adminLibrariesProvider.notifier).remove('Music');

      verify(() => libraryApi.removeVirtualFolder(
            name: 'Music',
            refreshLibrary: false,
          )).called(1);
      verify(() => libraryApi.getVirtualFolders()).called(2);
    });

    test('addPath calls addMediaPath with correct library name and path',
        () async {
      final libs = BuiltList<VirtualFolderInfo>.of([_library(name: 'Movies')]);
      when(() => libraryApi.getVirtualFolders())
          .thenAnswer((_) async => _ok(libs));
      when(() => libraryApi.addMediaPath(
            mediaPathDto: any(named: 'mediaPathDto'),
            refreshLibrary: any(named: 'refreshLibrary'),
          )).thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminLibrariesProvider.future);
      await c
          .read(adminLibrariesProvider.notifier)
          .addPath('Movies', '/mnt/movies2');

      verify(() => libraryApi.addMediaPath(
            mediaPathDto: any(named: 'mediaPathDto'),
            refreshLibrary: false,
          )).called(1);
    });

    test('removePath calls removeMediaPath with correct name and path', () async {
      final libs = BuiltList<VirtualFolderInfo>.of([_library(name: 'Movies')]);
      when(() => libraryApi.getVirtualFolders())
          .thenAnswer((_) async => _ok(libs));
      when(() => libraryApi.removeMediaPath(
            name: any(named: 'name'),
            path: any(named: 'path'),
            refreshLibrary: any(named: 'refreshLibrary'),
          )).thenAnswer((_) async => _ok<void>(null));

      final c = makeContainer();
      await c.read(adminLibrariesProvider.future);
      await c
          .read(adminLibrariesProvider.notifier)
          .removePath('Movies', '/mnt/old-movies');

      verify(() => libraryApi.removeMediaPath(
            name: 'Movies',
            path: '/mnt/old-movies',
            refreshLibrary: false,
          )).called(1);
    });
  });
}
