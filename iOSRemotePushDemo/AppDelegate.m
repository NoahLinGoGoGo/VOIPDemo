//
//  AppDelegate.m
//  iOSRemotePushDemo
//
//  Created by HSDM10 on 2018/11/28.
//  Copyright © 2018年 HSDM10. All rights reserved.
//

#import "AppDelegate.h"
#import "AVFoundation/AVFoundation.h"
#import <MediaPlayer/MediaPlayer.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s: %@", __FUNCTION__, launchOptions);
    [self voipRegistration];
    [self localPushRegistration];
    
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        // 这里添加本地通知处理代码，程序被杀死，点击通知后调用此程序
        
    }
    
    return YES;
}

#pragma mark - VOIP
// Register for VoIP notifications
- (void)voipRegistration {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    // Create a push registry object
    PKPushRegistry * voipRegistry = [[PKPushRegistry alloc] initWithQueue: mainQueue];
    // Set the registry's delegate to self
    voipRegistry.delegate = self;
    // Set the push type to VoIP
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

// Handle updated push credentials
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials: (PKPushCredentials *)credentials forType:(NSString *)type {
    // Register VoIP push token (a property of PKPushCredentials) with server
    NSString *token = [[[[credentials.token description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%s: %@  %@  token:%@", __FUNCTION__, credentials.token,type,token);
    
    
}

// Handle incoming pushes
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
    // Process the received push
    NSLog(@"%s: %@  %@", __FUNCTION__, payload.dictionaryPayload,type);
    NSString *voiceUrl = payload.dictionaryPayload[@"aps"][@"alert"];
    BOOL isActive = false;
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateActive: {
            isActive = true;
        }
            break;
        case UIApplicationStateInactive: {
            isActive = true;
        }
            break;
        case UIApplicationStateBackground: {
            isActive = false;
        }
            break;
        default:
            isActive = false;
            break;
    }
    
    if (!isActive){
        // local push
        [self sendLocalPush];
    }
    
    if (@available(iOS 10.0, *)) {
        [self playOnOnlineAudioWithUrlStr:voiceUrl];
    }
}

#pragma mark - LOCAL PUSH
- (void)localPushRegistration {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) { // iOS8
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication
          ] registerUserNotificationSettings:setting];
    }
}



- (void)sendLocalPush {
    NSString *title = @"微信";
    NSString *body = @"微信支付收款到账”";
    
    if (@available(iOS 10.0, *)) {
        // 1.创建通知内容
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        //        [content setValue:@(YES) forKeyPath:@"shouldAlwaysAlertWhileAppIsForeground"];
        content.sound = [UNNotificationSound defaultSound];
        content.title = title;
        content.body = body;
        
        
        // 2.设置通知附件内容
        //        NSError *error = nil;
        //        NSString *path = [[NSBundle mainBundle] pathForResource:@"Icon-60@1x-1" ofType:@"png"];
        //        UNNotificationAttachment *att = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
        //        if (error) {
        //            NSLog(@"attachment error %@", error);
        //        }
        //        content.attachments = @[att];
        content.launchImageName = @"LaunchImage";
        // 2.设置声音
        //        UNNotificationSound *sound = [UNNotificationSound soundNamed:@"sound01.wav"];// [UNNotificationSound defaultSound];
        //        content.sound = sound;
        
        // 3.触发模式
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
        
        // 4.设置UNNotificationRequest
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"LocalPushReqIdentifer" content:content trigger:trigger];
        
        // 5.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        }];
        
    } else {
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
        // 1.设置触发时间（如果要立即触发，无需设置）
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        
        // 2.设置通知标题
        localNotification.alertBody = body;
        
        
        // 3.设置提醒的声音
        localNotification.soundName = @"weixindaozhang.wav";// UILocalNotificationDefaultSoundName;
        
        
        // 4.在规定的日期触发通知
        //        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        // 4.立即触发一个通知
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

/// 程序没有被杀死（处于前台或后台），点击通知后会调用此程序
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // 这里添加处理代码
}

#pragma mark -
- (void)playOnOnlineAudioWithUrlStr:(NSString *)urlStr {
    NSError *error;
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:&error];
    if (error) {
        NSLog(@"%s  %@",__FUNCTION__,error.localizedDescription);
    }
    
    // 播放合成声音，这里用一段音频代替
    NSString *soundPath = [[NSBundle mainBundle]pathForResource:@"weixindaozhang" ofType:@"wav"];
    NSURL *soundUrl = [NSURL fileURLWithPath:soundPath];
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:soundUrl error:nil];
    //设置声音的大小
    self.audioPlayer.volume = 0.5;//范围为（0到1）；
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    
}
@end
