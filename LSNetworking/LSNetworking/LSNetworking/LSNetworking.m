//
//  LSNetworking.m
//  LSNetworking
//
//  Created by WangBiao on 2017/6/17.
//  Copyright © 2017年 LSRain. All rights reserved.
//

#import "LSNetworking.h"

#ifdef DEBUG
# define LSLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define LSLog(...)
#endif

#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

static NSMutableArray<NSURLSessionDataTask *> *tasks;
static BOOL _isDebugLog;
@implementation LSNetworking


- (void)dealloc{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

+ (LSNetworking *)sharedNetworking{
    static LSNetworking *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[LSNetworking alloc] init];
    });
    
    return handler;
}

+ (void)openDebugLog{
    _isDebugLog = YES;
}

+ (NSMutableArray *)tasks{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tasks = [[NSMutableArray alloc] init];
    });
    
    return tasks;
}

+ (LSURLSessionTask *)getOrPostWithType:(LSHTTPMethod)httpMethod
                                WithUrl:(NSString *)url
                                 params:(NSDictionary *)params
                                success:(LSResponseSuccess)success
                                   fail:(LSResponseFail)fail{
    return [self baseRequestType:httpMethod url:url params:params success:success fail:fail];
}

+ (AFHTTPSessionManager *)getAFManager{
    static AFHTTPSessionManager *httpManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        httpManager = [AFHTTPSessionManager manager];
        
        // Set the return data to json
        httpManager.responseSerializer = [AFJSONResponseSerializer serializer];
        httpManager.requestSerializer  = [AFHTTPRequestSerializer serializer];
        
        // Set NSData
        // httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        httpManager.requestSerializer.stringEncoding          = NSUTF8StringEncoding;
        httpManager.requestSerializer.timeoutInterval         = 30;
        httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:
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

+ (LSURLSessionTask *)baseRequestType:(LSHTTPMethod)type url:(NSString *)url params:(NSDictionary *)params success:(LSResponseSuccess)success fail:(LSResponseFail)fail{
    // Is there any Chinese in the address?
    NSString *urlStr = [NSURL URLWithString:url] ? url : [self strUTF8Encoding:url];
    
    AFHTTPSessionManager *manager = [self getAFManager];
    LSURLSessionTask *sessionTask = nil;
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

#pragma makr - Start listening for changes in the network connection during running

+ (void)checkNetStatusWithBlock:(LSNetworkStatus)networkStatus{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                networkStatus ? networkStatus(StatusUnknown) : nil;
                LSLog(@"Unknown network...");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                networkStatus ? networkStatus(StatusNotReachable) : nil;
                LSLog(@"No internet...");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatus ? networkStatus(StatusReachableViaWWAN) : nil;
                LSLog(@"Mobile phone network...");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatus ? networkStatus(StatusReachableViaWiFi) : nil;
                LSLog(@"WIFI...");
                break;
        }
    }];
    [mgr startMonitoring];
}

+ (BOOL)isNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (LSURLSessionTask *)uploadWithImages:(NSArray *)imageArr
                                   url:(NSString *)url
                              filename:(NSString *)filename
                                 names:(NSArray *)nameArr
                                params:(NSDictionary *)params
                              progress:(LSUploadProgress)progress
                               success:(LSResponseSuccess)success
                                  fail:(LSResponseFail)fail{
    // Is there any Chinese in the address?
    NSString *urlStr = [NSURL URLWithString:url] ? url : [self strUTF8Encoding:url];
    
    AFHTTPSessionManager *manager         = [self getAFManager];
    __block LSURLSessionTask *sessionTask = [manager POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i = 0; i < imageArr.count; i ++) {
            UIImage *image    = (UIImage *)imageArr[i];
            NSData *imageData = UIImageJPEGRepresentation(image,1.0);
            NSString *imageFileName = filename;
            if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat       = @"yyyyMMddHHmmss";
                NSString *str              = [formatter stringFromDate:[NSDate date]];
                imageFileName              = [NSString stringWithFormat:@"%@.png", str];
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

+ (LSURLSessionTask *)downloadWithUrl:(NSString *)url
                           saveToPath:(NSString *)saveToPath
                             progress:(LSDownloadProgress)progressBlock
                              success:(LSResponseSuccess)success
                              failure:(LSResponseFail)fail{
    if (url == nil) {
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
                // Returns the full path
                success([filePath path]);
            }
        } else {
            if (fail) {
                fail(error);
            }
        }
    }];
    // start download
    [sessionTask resume];
    if (sessionTask) {
        [[self tasks] addObject:sessionTask];
    }
    
    return sessionTask;
}

# pragma mark - uploadFile

+ (NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                             parameters:(NSDictionary *)parameters
                                   name:(NSString *)name
                               filePath:(NSString *)filePath
                               progress:(LSHttpProgress)progress
                                success:(LSResponseSuccess)success
                                failure:(LSResponseFail)failure{
    NSURLSessionTask *sessionTask = [[self getAFManager] POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
        (failure && error) ? failure(error) : nil;
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        // Upload progress
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        LSLog(@"%@",_isDebugLog ? NSStringFormat(@"responseObject = %@",[self jsonToString:responseObject]) : @"LSNetworking Log printing has been turned off");
        
        [[self tasks] removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LSLog(@"%@",_isDebugLog ? NSStringFormat(@"error = %@",error) : @"LSNetworking Log printing has been turned off");
        
        [[self tasks] removeObject : task];
        failure ? failure(error) : nil;
    }];
    sessionTask ? [[self tasks] addObject:sessionTask] : nil ;
    
    return sessionTask;
}

- (void)uploadFilesWithURLString:(NSString *)URLString
                  serverFileName:(NSString *)serverFileName
                       filePaths:(NSArray *)filePaths
                        textDict:(NSDictionary *)textDict{
    NSURL *URL = [NSURL URLWithString:URLString];
    
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:URL];
    requestM.HTTPMethod           = @"POST";
    // Request the contents of the first inside the Content-Type
    [requestM setValue:@"multipart/form-data; boundary=lsrequest" forHTTPHeaderField:@"Content-Type"];
    
    // Request body
    NSData *fromData = [self getfromDataServerFileName:serverFileName filePaths:filePaths textDict:textDict];
    
    [[[NSURLSession sharedSession] uploadTaskWithRequest:requestM fromData:fromData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil && data != nil) {
            // Deserialization
            NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            LSLog(@"%@",result);
        } else {
            LSLog(@"%@",error);
        }
    }] resume];
}

- (NSData *)getfromDataServerFileName:(NSString *)serverFileName filePaths:(NSArray *)filePaths textDict:(NSDictionary *)textDict{
    // Defines a container that splits the entire request body binary
    NSMutableData *dataM = [NSMutableData data];
    
    [filePaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // Staple the file before the binary string
        NSMutableString *stringM = [NSMutableString string];
        
        // The beginning of the file delimiter
        [stringM appendString:@"--lsrequest\r\n"];
        
        // form data
        [stringM appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n",serverFileName,[obj lastPathComponent]];
        
        // file type
        [stringM appendString:@"Content-Type: application/octet-stream\r\n"];
        
        // Line feed
        [stringM appendString:@"\r\n"];
        [dataM appendData:[stringM dataUsingEncoding:NSUTF8StringEncoding]];
        
        // Bind file to binary
        NSData *data = [NSData dataWithContentsOfFile:obj];
        [dataM appendData:data];
        
        // Stitching at the end
        NSString *end = @"\r\n";
        [dataM appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // The body of the request
    [textDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableString *stringM = [NSMutableString string];
        [stringM appendString:@"--lsrequest\r\n"];
        [stringM appendFormat:@"Content-Disposition: form-data; name=%@\r\n",key];
        [stringM appendString:@"\r\n"];
        [stringM appendFormat:@"%@\r\n",obj];
        [dataM appendData:[stringM dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    NSString *end = @"--lsrequest--";
    [dataM appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    return dataM.copy;
}

#pragma mark - Tools

+ (NSString *)jsonToString:(id)data{
    if(!data) { return nil; }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)strUTF8Encoding:(NSString *)str{
    return  [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:str]];
}

@end
