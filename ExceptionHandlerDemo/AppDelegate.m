//
//  AppDelegate.m
//  ExceptionHandlerDemo
//
//  Created by hanzhanbing on 16/8/2.
//  Copyright © 2016年 asj. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    //捕获异常崩溃信息
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    //程序启动时，检查本地有没有崩溃信息，如果有将崩溃信息作为日志发送给开发者
    NSString *exceptionContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExceptionContent"];
    if (exceptionContent.length>0) {
        [self sendException:exceptionContent];
    }
    
    return YES;
}

void UncaughtExceptionHandler(NSException *exception) {
    /**
     *  获取异常崩溃信息
     */
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *content = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[callStack componentsJoinedByString:@"\n"]];
    
    //将崩溃信息持久化在本地，下次程序启动时，将崩溃信息作为日志发送给开发者。
    [[NSUserDefaults standardUserDefaults] setObject:content forKey:@"ExceptionContent"];
}

#pragma mark - 自动将程序崩溃日志发送到设定的邮箱
- (void)sendException:(NSString *)content {
    
    SKPSMTPMessage *message = [[SKPSMTPMessage alloc]init];
    message.fromEmail = @"15737936517@163.com";
    message.toEmail = @"1655661337@qq.com";
    message.relayHost = @"smtp.163.com";
    message.requiresAuth = YES;
    message.login = @"15737936517@163.com";
    message.pass = @"zyl5201314";
    message.subject = @"小依休iOS端崩溃日志";
    message.wantsSecure = YES;
    
    NSDictionary *plainPart=[NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,[NSString stringWithCString:[content UTF8String] encoding:NSUTF8StringEncoding],kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey, nil];
    
    [message setParts:[NSArray arrayWithObjects:plainPart, nil]];
    message.delegate = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [message send];
    });
}

#pragma mark - SKPSMTPMessageDelegate
-(void)messageSent:(SKPSMTPMessage *)message {
    NSLog(@"%@",message);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ExceptionContent"];
}

-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error {
    NSLog(@"%@\n%@",message,[error localizedDescription]);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
