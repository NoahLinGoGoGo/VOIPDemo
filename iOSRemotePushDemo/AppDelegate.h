//
//  AppDelegate.h
//  iOSRemotePushDemo
//
//  Created by HSDM10 on 2018/11/28.
//  Copyright © 2018年 HSDM10. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PushKit/PushKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate,PKPushRegistryDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

