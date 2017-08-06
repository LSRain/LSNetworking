# LSNetworking
Provides commonly used network processing, network status monitoring, data requests, file / picture upload and download, etc.

## Introduction
The tool provides the usual network processing

* The network request encapsulates [AFN] (https://github.com/AFNetworking/AFNetworking), and the current version is `3.1.0`.
* File upload package `NSURLSession`

### use
* Network status monitoring
* `GET / POST` data request
* `Upload / download` file / picture

### use
For commonly used network requests, you can use the following methods directly

```objc
// demo - Please replace the correct URL and parameters
NSString *sendURL = @"sendTestURL";
NSDictionary *sendDic = @{
                         @"sendParameTestKey" : @"sendParameTestValue"
                         };
[LSNetworking getOrPostWithType:GET WithUrl:sendURL params:sendDic success:^(id response) {
   // you can do the data processing here ...
} fail:^(NSError *error) {
   // Abnormal data processing
}];
```

File upload, you need to create a tool instance, and then call the object method

```objc
# pragma mark - uploadFile

/**
 Multi-file upload, you can upload text messages
 
 @param URLString      File upload address
 @param serverFileName The server receives the field name of the file
 @param filePaths      Multi-file path collection
 @param textDict       Multi-file upload when the text information
 */
- (void)uploadFilesWithURLString:(NSString *)URLString serverFileName:(NSString *)serverFileName filePaths:(NSArray *)filePaths textDict:(NSDictionary *)textDict;

/**
 Single file upload, can not upload text information
 
 @param URLString      File upload address
 @param serverFileName The server receives the field name of the file
 @param filePath       The path to the file
 */
- (void)uploadFileWithURLString:(NSString *)URLString serverFileName:(NSString *)serverFileName filePath:(NSString *)filePath;
```

## 中文介绍
工具提供了常用的网络处理

* 其中网络请求封装了[AFN](https://github.com/AFNetworking/AFNetworking),当前项目中使用到的版本为`3.1.0`.
* 文件上传封装了`NSURLSession`

### 用途
* 网络状态监测
* `GET/POST`数据请求
* `上传/下载`文件/图片

### 使用
对于常用的网络请求，你可以直接使用如下的方式

```objc
// demo - Please replace the correct URL and parameters
NSString *sendURL = @"sendTestURL";
NSDictionary *sendDic = @{
                         @"sendParameTestKey" : @"sendParameTestValue"
                         };
[LSNetworking getOrPostWithType:GET WithUrl:sendURL params:sendDic success:^(id response) {
   // you can do the data processing here ...
} fail:^(NSError *error) {
   // Abnormal data processing
}];
```

文件的上传，则需要先创建工具实例，再调用对象方法

```objc
# pragma mark - uploadFile

/**
 Multi-file upload, you can upload text messages
 
 @param URLString      File upload address
 @param serverFileName The server receives the field name of the file
 @param filePaths      Multi-file path collection
 @param textDict       Multi-file upload when the text information
 */
- (void)uploadFilesWithURLString:(NSString *)URLString serverFileName:(NSString *)serverFileName filePaths:(NSArray *)filePaths textDict:(NSDictionary *)textDict;

/**
 Single file upload, can not upload text information
 
 @param URLString      File upload address
 @param serverFileName The server receives the field name of the file
 @param filePath       The path to the file
 */
- (void)uploadFileWithURLString:(NSString *)URLString serverFileName:(NSString *)serverFileName filePath:(NSString *)filePath;
```


