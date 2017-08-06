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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
