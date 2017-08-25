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
