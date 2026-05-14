# jellyfin_api.model.OpenLiveStreamDto

## Load the model package
```dart
import 'package:jellyfin_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**openToken** | **String** | Gets or sets the open token. | [optional] 
**userId** | **String** | Gets or sets the user id. | [optional] 
**playSessionId** | **String** | Gets or sets the play session id. | [optional] 
**maxStreamingBitrate** | **int** | Gets or sets the max streaming bitrate. | [optional] 
**startTimeTicks** | **int** | Gets or sets the start time in ticks. | [optional] 
**audioStreamIndex** | **int** | Gets or sets the audio stream index. | [optional] 
**subtitleStreamIndex** | **int** | Gets or sets the subtitle stream index. | [optional] 
**maxAudioChannels** | **int** | Gets or sets the max audio channels. | [optional] 
**itemId** | **String** | Gets or sets the item id. | [optional] 
**enableDirectPlay** | **bool** | Gets or sets a value indicating whether to enable direct play. | [optional] 
**enableDirectStream** | **bool** | Gets or sets a value indicating whether to enable direct stream. | [optional] 
**alwaysBurnInSubtitleWhenTranscoding** | **bool** | Gets or sets a value indicating whether always burn in subtitles when transcoding. | [optional] 
**deviceProfile** | [**DeviceProfile**](DeviceProfile.md) |  | [optional] 
**directPlayProtocols** | [**BuiltList&lt;MediaProtocol&gt;**](MediaProtocol.md) | Gets or sets the device play protocols. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


