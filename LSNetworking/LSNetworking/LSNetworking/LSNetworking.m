//
//  LSNetworking.m
//  LSNetworking
//
//  Created by WangBiao on 2017/6/17.
//  Copyright © 2017年 LSRain. All rights reserved.
//

#import "LSNetworking.h"

#ifdef DEBUG
#   define LSLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define CCPLog(...)
#endif

static NSMutableArray<NSURLSessionDataTask *> *tasks;

@implementation LSNetworking

+ (LSNetworking *)sharedLSNetworking{
    static LSNetworking *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[LSNetworking alloc] init];
    });
    
    return handler;
}

+ (NSMutableArray *)tasks{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tasks = [[NSMutableArray alloc] init];
    });
    return tasks;
}

+ (LSURLSessionTask *)getOrPostWithType:(LSHTTPMethod)httpMethod WithUrl:(NSString *)url params:(NSDictionary *)params success:(CCPResponseSuccess)success fail:(CCPResponseFail)fail{
    
    return [self baseRequestType:httpMethod url:url params:params success:success fail:fail];
}

+ (LSURLSessionTask *)uploadWithImages:(NSArray *)imageArr url:(NSString *)url filename:(NSString *)filename names:(NSArray *)nameArr params:(NSDictionary *)params progress:(CCPUploadProgress)progress success:(CCPResponseSuccess)success fail:(CCPResponseFail)fail{
    /// Is there any Chinese in the address?
    NSString *urlStr=[NSURL URLWithString:url] ? url : [self strUTF8Encoding:url];
    
    AFHTTPSessionManager *manager=[self getAFManager];
    __block LSURLSessionTask *sessionTask = [manager POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i = 0; i < imageArr.count; i ++) {
            UIImage *image = (UIImage *)imageArr[i];
            NSData *imageData = UIImageJPEGRepresentation(image,1.0);
            NSString *imageFileName = filename;
            if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyyMMddHHmmss";
                NSString *str = [formatter stringFromDate:[NSDate date]];
                imageFileName = [NSString stringWithFormat:@"%@.png", str];
            }
            NSString *nameString = (NSString *)nameArr[i];

            [formData appendPartWithFileData:imageData name:nameString fileName:imageFileName mimeType:@"image/jpg"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        LSLog(@"Upload progress--%lld,total progress---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
            progress ? progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success ? success(responseObject) : nil;
        [[self tasks] removeObject:sessionTask];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail ? fail(error) : nil;
        [[self tasks] removeObject:sessionTask];
    }];
    
    sessionTask ? [[self tasks] addObject:sessionTask] : nil;
    
    return url ? sessionTask : nil;
    
}


+ (LSURLSessionTask *)downloadWithUrl:(NSString *)url saveToPath:(NSString *)saveToPath progress:(CCPDownloadProgress )progressBlock success:(CCPResponseSuccess )success failure:(CCPResponseFail )fail{
    
    if (url==nil) {
        return nil;
    }
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPSessionManager *manager = [self getAFManager];
    
    LSURLSessionTask *sessionTask = nil;
    
    sessionTask = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        
        LSLog(@"Download progress--%.1f",1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) {
                
                progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (!saveToPath) {
            NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            LSLog(@"Default path--%@",downloadURL);
            return [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
            
        }else{
            NSURL *downloadURL = [NSURL fileURLWithPath:saveToPath];
            LSLog(@"Target download path--%@",downloadURL);
            return [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [[self tasks] removeObject:sessionTask];
        
        if (error == nil) {
            
            if (success) {
                /// Returns the full path
                success([filePath path]);
            }
            
        } else {
            
            if (fail) {
                
                fail(error);
                
            }
        }
    }];
    
    /// start download
    [sessionTask resume];
    if (sessionTask) {
        [[self tasks] addObject:sessionTask];
    }
    
    return sessionTask;
    
}

+ (LSURLSessionTask *)baseRequestType:(LSHTTPMethod)type url:(NSString *)url params:(NSDictionary *)params success:(CCPResponseSuccess)success fail:(CCPResponseFail)fail{
    /// Is there any Chinese in the address?
    NSString *urlStr = [NSURL URLWithString:url] ? url : [self strUTF8Encoding:url];
    
    AFHTTPSessionManager *manager=[self getAFManager];
    LSURLSessionTask *sessionTask=nil;
    switch (type) {
        case GET:
            {
                sessionTask = [manager GET:urlStr parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    
                    if (success) {
                        success(responseObject);
                    }
                    
                    [[self tasks] removeObject:sessionTask];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    if (fail) {
                        fail(error);
                    }
                    [[self tasks] removeObject:sessionTask];
                }];
            }
            break;
        case POST:
            {
                sessionTask = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    if (success) {
                        success(responseObject);
                    }
                    [[self tasks] removeObject:sessionTask];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    if (fail) {
                        fail(error);
                    }
                    [[self tasks] removeObject:sessionTask];
                }];
            }
            break;
        default:
            break;
    }
    
    sessionTask ? [[self tasks] addObject:sessionTask] : nil;
    
    return url ? sessionTask : nil;
    
}

+ (AFHTTPSessionManager *)getAFManager{
    static AFHTTPSessionManager *httpManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        httpManager = [AFHTTPSessionManager manager];
        
        /// Set the return data to json
        httpManager.responseSerializer = [AFJSONResponseSerializer serializer];
        httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        /// set NSData
        //httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        httpManager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        httpManager.requestSerializer.timeoutInterval= 30;
        httpManager.responseSerializer.acceptableContentTypes = [
                                                                 NSSet setWithArray:
                                                                @[
                                                                  @"application/json",
                                                                  @"text/html",
                                                                  @"text/json",
                                                                  @"text/plain",
                                                                  @"text/javascript",
                                                                  @"text/xml",
                                                                  @"image/*"
                                                                  ]
                                                                 ];
    });
    
    return httpManager;
}

#pragma makr - 开始监听程序在运行中的网络连接变化
+ (void)startMonitoring
{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                
                [LSNetworking sharedLSNetworking].networkStats=StatusUnknown;
                
                break;
                
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                
                [LSNetworking sharedLSNetworking].networkStats=StatusNotReachable;
                
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                
                [LSNetworking sharedLSNetworking].networkStats=StatusReachableViaWWAN;
                
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                
                [LSNetworking sharedLSNetworking].networkStats=StatusReachableViaWiFi;
                
                break;
        }
    }];
    
    [mgr startMonitoring];
}

+ (LSNetworkStatu)checkNetStatus {
    
    [self startMonitoring];
    
    if ([LSNetworking sharedLSNetworking].networkStats == StatusReachableViaWiFi) {
        
        return StatusReachableViaWiFi;
        
    } else if ([LSNetworking sharedLSNetworking].networkStats == StatusNotReachable) {
        
        return StatusNotReachable;
        
    } else if ([LSNetworking sharedLSNetworking].networkStats == StatusReachableViaWWAN) {
        
        return StatusReachableViaWWAN;
        
    } else {
        
        return StatusUnknown;
        
    }
    
}


+ (BOOL) isHaveNetwork {
    
//    Reachability *conn = [Reachability reachabilityForInternetConnection];
//    
//    if ([conn currentReachabilityStatus] == NotReachable) {
//        
//        return NO;
//        
//    } else {
//        
        return YES;
//    }
}


+ (NSString *)strUTF8Encoding:(NSString *)str{
    
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)dealloc
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

@end