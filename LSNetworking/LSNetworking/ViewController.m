//
//  ViewController.m
//  LSNetworking
//
//  Created by WangBiao on 2017/6/17.
//  Copyright © 2017年 LSRain. All rights reserved.
//

/**
 pod 'AFNetworking', '~> 3.1.0'
 */

#import "ViewController.h"
#import "LSNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    // Detects network status
    [LSNetworking checkNetStatusWithBlock:^(LSNetworkStatusType status) {
        NSLog(@"current netWork: %zd", status);
    }];
    
    /*
     Whether there is a network
     - Where the delay of 0.1s and then the implementation is because the program has just started, may be related to the completion of the network service has not yet completed (also may be AFN BUG)
     - Cause the demo to detect the network status is not correct, this is only to demonstrate the functionality of the demo, in actual use can be used directly to determine the one-time network, do not have to do delay delay operation
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"\n Whether there is a network ~> %zd", [LSNetworking isNetwork]);
    });

    /*
     demo 
        - Please replace the correct URL and parameters
        - You should use a correct URL to return to json format, the following address is returned to a HTML rather than json.
        - If your URL contains parameters, then you can use it like this
            NSDictionary *sendDic = @{
                                        @"sendParameTestKey" : @"sendParameTestValue"
            };
     */
    NSString *sendURL = @"https://www.baidu.com";
    [LSNetworking getOrPostWithType:GET WithUrl:sendURL params:nil success:^(id response) {
        // you can do the data processing here ...
        NSLog(@"Test response: %@", response);
    } fail:^(NSError *error) {
        // Abnormal data processing
        NSLog(@"error Message: %@", error);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
