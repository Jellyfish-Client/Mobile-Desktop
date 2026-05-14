# jellyseerr_api.api.OverrideruleApi

## Load the API package
```dart
import 'package:jellyseerr_api/api.dart';
```

All URIs are relative to *http://localhost:5055/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**overrideRuleGet**](OverrideruleApi.md#overrideruleget) | **GET** /overrideRule | Get override rules
[**overrideRulePost**](OverrideruleApi.md#overriderulepost) | **POST** /overrideRule | Create override rule
[**overrideRuleRuleIdDelete**](OverrideruleApi.md#overrideruleruleiddelete) | **DELETE** /overrideRule/{ruleId} | Delete override rule by ID
[**overrideRuleRuleIdPut**](OverrideruleApi.md#overrideruleruleidput) | **PUT** /overrideRule/{ruleId} | Update override rule


# **overrideRuleGet**
> BuiltList<OverrideRule> overrideRuleGet()

Get override rules

Returns a list of all override rules with their conditions and settings

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

final api = JellyseerrApi().getOverrideruleApi();

try {
    final response = api.overrideRuleGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling OverrideruleApi->overrideRuleGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;OverrideRule&gt;**](OverrideRule.md)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **overrideRulePost**
> BuiltList<OverrideRule> overrideRulePost()

Create override rule

Creates a new Override Rule from the request body.

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

final api = JellyseerrApi().getOverrideruleApi();

try {
    final response = api.overrideRulePost();
    print(response);
} catch on DioException (e) {
    print('Exception when calling OverrideruleApi->overrideRulePost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;OverrideRule&gt;**](OverrideRule.md)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **overrideRuleRuleIdDelete**
> OverrideRule overrideRuleRuleIdDelete(ruleId)

Delete override rule by ID

Deletes the override rule with the provided ruleId.

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

final api = JellyseerrApi().getOverrideruleApi();
final num ruleId = 8.14; // num | 

try {
    final response = api.overrideRuleRuleIdDelete(ruleId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling OverrideruleApi->overrideRuleRuleIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ruleId** | **num**|  | 

### Return type

[**OverrideRule**](OverrideRule.md)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **overrideRuleRuleIdPut**
> BuiltList<OverrideRule> overrideRuleRuleIdPut(ruleId)

Update override rule

Updates an Override Rule from the request body.

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

final api = JellyseerrApi().getOverrideruleApi();
final num ruleId = 8.14; // num | 

try {
    final response = api.overrideRuleRuleIdPut(ruleId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling OverrideruleApi->overrideRuleRuleIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ruleId** | **num**|  | 

### Return type

[**BuiltList&lt;OverrideRule&gt;**](OverrideRule.md)

### Authorization

[apiKey](../README.md#apiKey), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

