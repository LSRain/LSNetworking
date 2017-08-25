//
//  LSNetworking.h
//  LSNetworking
//
//  Created by WangBiao on 2017/6/17.
//  Copyright © 2017年 LSRain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

/**
 `LSNetworking` is Provides commonly used network processing, network status monitoring, data requests, file / picture upload and download, etc.
 
 ## Introduction
 Provides the usual network processing
    * The network request encapsulates[AFN]( https://github.com/AFNetworking/AFNetworking ), and the current version is `3.1.0`.
    * File upload package `NSURLSession`.
 
 ## Scenes
    * Network status monitoring
    * `GET / POST` data request
    * `Upload / download` file / picture
 
 ## Network Reachability Monitoring
    - `checkNetStatusWithBlock:`
    - `isNetwork`
 
 Note that if you use `isNetwork` to get the current network status, then you need to have a delay, and before that, you need to call`checkNetStatusWithBlock:`this callback to open the network monitoring. So the right way is this Two methods are used together.

 ## Network request
    - `getOrPostWithType:WithUrl:params:success:fail:`
 
 The method provides a common `GET / POST` data request, but please note that your URL return result should be a correct`JSON` data type. In Development environment, you can define the parameters of the dictionary type you need and assign To `params`.
 
 ```objc
     NSString *sendURL = @"APIURL";
     [LSNetworking getOrPostWithType:GET WithUrl:sendURL params:nil success:^(id response) {
        // you can do the data processing here ...
     } fail:^(NSError *error) {
        // Abnormal data processing
     }];
 ```
 */

#pragma mark - Typedef definition

/**
 network status

 - StatusUnknown: Network state enumeration
 */
typedef NS_ENUM(NSUInteger, LSNetworkStatusType){
    StatusUnknown           = -1,   // Unknown network
    StatusNotReachable      = 0,    // No internet
    StatusReachableViaWWAN  = 1,    // Mobile phone network
    StatusReachableViaWiFi  = 2     // WIFI
};

/**
 * Request Mode
 * GET OR POST
 */
typedef enum HttpMethod {
    GET,
    POST
} LSHTTPMethod;

typedef NSURLSessionTask LSURLSessionTask;

# pragma mark - Block definition

typedef void(^LSResponseSuccess)(id response);
typedef void(^LSResponseFail)(NSError *error);
typedef void(^LSUploadProgress)(int64_t bytesProgress, int64_t totalBytesProgress);
typedef void(^LSDownloadProgress)(int64_t bytesProgress, int64_t totalBytesProgress);
/// Block of Network State
typedef void(^LSNetworkStatus)(LSNetworkStatusType status);

@interface LSNetworking : NSObject

/**
 Singleton

 @return Self - Singleton
 */
+ (LSNetworking *)sharedNetworking;

#pragma mark - Network request

/**
 Use GET/POST request data

 @param httpMethod GET/POST
 @param url url
 @param params Request parameter
 @param success success
 @param fail fail
 @return Request the task object
 */
+ (LSURLSessionTask *)getOrPostWithType:(LSHTTPMethod)httpMethod WithUrl:(NSString *)url params:(NSDictionary *)params success:(LSResponseSuccess)success fail:(LSResponseFail)fail;

#pragma mark - Network monitoring

/**
 *  check network status
 */
+ (void)checkNetStatusWithBlock:(LSNetworkStatus)networkStatus;

/**
 Whether there is a network
 - It should be noted that this method must be used with `checkNetStatusWithBlock:`
 
 @return Whether there is a network
 */
+ (BOOL)isNetwork;

# pragma mark - Upload and download

/**
 The upload image method supports multiple uploads and leaflets

 @param imageArr imageArr
 @param url url
 @param filename filename
 @param nameArr nameArr
 @param params Parameter dictionary
 @param progress progress
 @param success success
 @param fail fail
 @return Request the task object
 */
+ (LSURLSessionTask *)uploadWithImages:(NSArray *)imageArr url:(NSString *)url filename:(NSString *)filename names:(NSArray *)nameArr params:(NSDictionary *)params progress:(LSUploadProgress)progress success:(LSResponseSuccess)success fail:(LSResponseFail)fail;

/**
 Download the file method

 @param url url
 @param saveToPath File save the path, if not pass it to the Documents directory, the original name of the file
 @param progressBlock progressBlock
 @param success success
 @param fail fail
 @return Request the task object
 */
+ (LSURLSessionTask *)downloadWithUrl:(NSString *)url saveToPath:(NSString *)saveToPath progress:(LSDownloadProgress )progressBlock success:(LSResponseSuccess )success failure:(LSResponseFail )fail;

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

@end
