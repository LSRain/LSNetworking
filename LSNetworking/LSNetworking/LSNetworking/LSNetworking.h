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

/// 网络状态 network status
typedef enum : NSUInteger {
    StatusUnknown           = -1,   // 未知网络 Unknown network
    StatusNotReachable      = 0,    // 没有网络 No internet
    StatusReachableViaWWAN  = 1,    // 手机自带网络 Mobile phone network
    StatusReachableViaWiFi  = 2     // WIFI
} LSNetworkStatu;

/**
 * 请求方式 Request mode
 * GET OR POST
 */
typedef enum HttpMethod {
    GET,
    POST
} LSHTTPMethod;

typedef void( ^ LSResponseSuccess)(id response);
typedef void( ^ LSResponseFail)(NSError *error);

typedef void( ^ LSUploadProgress)(int64_t bytesProgress,
int64_t totalBytesProgress);

typedef void( ^ LSDownloadProgress)(int64_t bytesProgress,
int64_t totalBytesProgress);


typedef NSURLSessionTask LSURLSessionTask;

@interface LSNetworking : NSObject

@property (nonatomic,assign)LSNetworkStatu networkStats;

/**
 Singleton

 @return SELF
 */
+ (LSNetworking *)sharedLSNetworking;


/**
 *  Turn on network monitoring
 */
+ (void)startMonitoring;

/**
 *  Get network status
 */
+ (LSNetworkStatu)checkNetStatus;

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

@end
