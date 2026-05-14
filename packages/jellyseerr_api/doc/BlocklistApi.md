# jellyseerr_api.api.BlocklistApi

## Load the API package
```dart
import 'package:jellyseerr_api/api.dart';
```

All URIs are relative to *http://localhost:5055/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**blacklistGet**](BlocklistApi.md#blacklistget) | **GET** /blacklist | Returns blocklisted items
[**blacklistPost**](BlocklistApi.md#blacklistpost) | **POST** /blacklist | Add media to blocklist
[**blacklistTmdbIdDelete**](BlocklistApi.md#blacklisttmdbiddelete) | **DELETE** /blacklist/{tmdbId} | Remove media from blocklist
[**blacklistTmdbIdGet**](BlocklistApi.md#blacklisttmdbidget) | **GET** /blacklist/{tmdbId} | Get media from blocklist
[**blocklistCollectionCollectionIdDelete**](BlocklistApi.md#blocklistcollectioncollectioniddelete) | **DELETE** /blocklist/collection/{collectionId} | Remove collection from blocklist
[**blocklistCollectionCollectionIdPost**](BlocklistApi.md#blocklistcollectioncollectionidpost) | **POST** /blocklist/collection/{collectionId} | Add collection to blocklist
[**blocklistGet**](BlocklistApi.md#blocklistget) | **GET** /blocklist | Returns blocklisted items
[**blocklistPost**](BlocklistApi.md#blocklistpost) | **POST** /blocklist | Add media to blocklist
[**blocklistTmdbIdDelete**](BlocklistApi.md#blocklisttmdbiddelete) | **DELETE** /blocklist/{tmdbId} | Remove media from blocklist
[**blocklistTmdbIdGet**](BlocklistApi.md#blocklisttmdbidget) | **GET** /blocklist/{tmdbId} | Get media from blocklist


# **blacklistGet**
> BlocklistGet200Response blacklistGet(take, skip, search, filter)

Returns blocklisted items

**DEPRECATED**: Use `/blocklist` instead. This endpoint will be deprecated soon. 

### Example
```dart
import 'package:jellyseerr_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = JellyseerrApi().getBlocklistApi();
final num take = 25; // num | 
final num skip = 0; // num | 
final String search = dune; // String | 
final String filter = filter_example; // String | 

try {
    final response = api.blacklistGet(take, skip, search, filter);
    print(response);
} catch on DioException (e) {
    print('Exception when calling BlocklistApi->blacklistGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **take** | **num**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **search** | **String**|  | [optional] 
 **filter** | **String**|  | [optional] [default to 'manual']

### Return type

[**BlocklistGet200Response**](BlocklistGet200Response.md)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **blacklistPost**
> blacklistPost(blocklist)

Add media to blocklist

**DEPRECATED**: Use `/blocklist` instead. This endpoint will be deprecated soon. 

### Example
```dart
import 'package:jellyseerr_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = JellyseerrApi().getBlocklistApi();
final Blocklist blocklist = ; // Blocklist | 

try {
    api.blacklistPost(blocklist);
} catch on DioException (e) {
    print('Exception when calling BlocklistApi->blacklistPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **blocklist** | [**Blocklist**](Blocklist.md)|  | 

### Return type

void (empty response body)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **blacklistTmdbIdDelete**
> blacklistTmdbIdDelete(tmdbId, mediaType)

Remove media from blocklist

**DEPRECATED**: Use `/blocklist/{tmdbId}` instead. This endpoint will be deprecated soon. 

### Example
```dart
import 'package:jellyseerr_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = JellyseerrApi().getBlocklistApi();
final String tmdbId = 1; // String | tmdbId ID
final String mediaType = mediaType_example; // String | 

try {
    api.blacklistTmdbIdDelete(tmdbId, mediaType);
} catch on DioException (e) {
    print('Exception when calling BlocklistApi->blacklistTmdbIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tmdbId** | **String**| tmdbId ID | 
 **mediaType** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **blacklistTmdbIdGet**
> blacklistTmdbIdGet(tmdbId, mediaType)

Get media from blocklist

**DEPRECATED**: Use `/blocklist/{tmdbId}` instead. This endpoint will be deprecated soon. 

### Example
```dart
import 'package:jellyseerr_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = JellyseerrApi().getBlocklistApi();
final String tmdbId = 1; // String | tmdbId ID
final String mediaType = mediaType_example; // String | 

try {
    api.blacklistTmdbIdGet(tmdbId, mediaType);
} catch on DioException (e) {
    print('Exception when calling BlocklistApi->blacklistTmdbIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tmdbId** | **String**| tmdbId ID | 
 **mediaType** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **blocklistCollectionCollectionIdDelete**
> blocklistCollectionCollectionIdDelete(collectionId)

Remove collection from blocklist

Removes all movies in a collection from the blocklist

### Example
```dart
import 'package:jellyseerr_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = JellyseerrApi().getBlocklistApi();
final String collectionId = 1424991; // String | Collection ID

try {
    api.blocklistCollectionCollectionIdDelete(collectionId);
} catch on DioException (e) {
    print('Exception when calling BlocklistApi->blocklistCollectionCollectionIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **collectionId** | **String**| Collection ID | 

### Return type

void (empty response body)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **blocklistCollectionCollectionIdPost**
> blocklistCollectionCollectionIdPost(collectionId, body)

Add collection to blocklist

Adds all movies in a collection to the blocklist

### Example
```dart
import 'package:jellyseerr_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = JellyseerrApi().getBlocklistApi();
final String collectionId = 1424991; // String | Collection ID
final JsonObject body = Object; // JsonObject | 

try {
    api.blocklistCollectionCollectionIdPost(collectionId, body);
} catch on DioException (e) {
    print('Exception when calling BlocklistApi->blocklistCollectionCollectionIdPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **collectionId** | **String**| Collection ID | 
 **body** | **JsonObject**|  | [optional] 

### Return type

void (empty response body)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **blocklistGet**
> BlocklistGet200Response blocklistGet(take, skip, search, filter)

Returns blocklisted items

Returns list of all blocklisted media

### Example
```dart
import 'package:jellyseerr_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = JellyseerrApi().getBlocklistApi();
final num take = 25; // num | 
final num skip = 0; // num | 
final String search = dune; // String | 
final String filter = filter_example; // String | 

try {
    final response = api.blocklistGet(take, skip, search, filter);
    print(response);
} catch on DioException (e) {
    print('Exception when calling BlocklistApi->blocklistGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **take** | **num**|  | [optional] 
 **skip** | **num**|  | [optional] 
 **search** | **String**|  | [optional] 
 **filter** | **String**|  | [optional] [default to 'manual']

### Return type

[**BlocklistGet200Response**](BlocklistGet200Response.md)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **blocklistPost**
> blocklistPost(blocklist)

Add media to blocklist

### Example
```dart
import 'package:jellyseerr_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = JellyseerrApi().getBlocklistApi();
final Blocklist blocklist = ; // Blocklist | 

try {
    api.blocklistPost(blocklist);
} catch on DioException (e) {
    print('Exception when calling BlocklistApi->blocklistPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **blocklist** | [**Blocklist**](Blocklist.md)|  | 

### Return type

void (empty response body)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **blocklistTmdbIdDelete**
> blocklistTmdbIdDelete(tmdbId, mediaType)

Remove media from blocklist

### Example
```dart
import 'package:jellyseerr_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = JellyseerrApi().getBlocklistApi();
final String tmdbId = 1; // String | tmdbId ID
final String mediaType = mediaType_example; // String | 

try {
    api.blocklistTmdbIdDelete(tmdbId, mediaType);
} catch on DioException (e) {
    print('Exception when calling BlocklistApi->blocklistTmdbIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tmdbId** | **String**| tmdbId ID | 
 **mediaType** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **blocklistTmdbIdGet**
> blocklistTmdbIdGet(tmdbId, mediaType)

Get media from blocklist

### Example
```dart
import 'package:jellyseerr_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = JellyseerrApi().getBlocklistApi();
final String tmdbId = 1; // String | tmdbId ID
final String mediaType = mediaType_example; // String | 

try {
    api.blocklistTmdbIdGet(tmdbId, mediaType);
} catch on DioException (e) {
    print('Exception when calling BlocklistApi->blocklistTmdbIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tmdbId** | **String**| tmdbId ID | 
 **mediaType** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

