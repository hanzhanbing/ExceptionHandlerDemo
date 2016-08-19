# ExceptionHandlerDemo

参考博客: iOS 中捕获程序崩溃日志
http://blog.sina.com.cn/s/blog_b71d24920101ky2d.html


/*
*
1. 将崩溃信息持久化在本地，下次程序启动时，将崩溃信息作为日志发送给开发者。
2. 通过邮件发送给开发者。 不过此种方式需要得到用户的许可，因为iOS不能后台发送短信或者邮件，会弹出发送邮件的界面，只有用户点击了发送才可发送。 不过，此种方式最符合苹果的以用户至上的原则。
*
*/


/******************SMTP使用示例*******************/

SKPSMTPMessage *message = [[SKPSMTPMessage alloc]init];
message.fromEmail = @"15737936517@163.com";
message.toEmail = @"1655661337@qq.com";
message.relayHost = @"smtp.163.com";
message.requiresAuth = YES;
message.login = @"15737936517@163.com";
message.pass = @"zyl5201314";
message.subject = @"小依休iOS端崩溃日志";
message.wantsSecure = YES;

NSDictionary *plainPart=[NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,[NSString stringWithCString:"测试正文" encoding:NSUTF8StringEncoding],kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey, nil];

[message setParts:[NSArray arrayWithObjects:plainPart, nil]];
message.delegate = self;
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
[message send];
});


#pragma mark - SKPSMTPMessageDelegate
-(void)messageSent:(SKPSMTPMessage *)message {
NSLog(@"%@",message);
}

-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error {
NSLog(@"%@\n%@",message,[error localizedDescription]);
}


/***************通过弹出系统自带的发送邮件的界面******************/

/**
*  把异常崩溃信息发送至开发者邮件
*/
NSMutableString *mailUrl = [NSMutableString string];
[mailUrl appendString:@"mailto:1655661337@qq.com"];
[mailUrl appendString:@"?subject=程序异常崩溃，请配合发送异常报告，谢谢合作！"];
[mailUrl appendFormat:@"&body=%@", content];
// 打开地址
NSString *mailPath = [mailUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailPath]];


/******************带参通知****************/

//通过通知中心发送通知
[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Exception" object:nil userInfo:@{@"exception":content}]];

//接收通知
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendException:) name:@"Exception" object:nil];

//处理
#pragma mark - 自动将程序崩溃日志发送到设定的邮箱
- (void)sendException:(NSNotification *)content {

SKPSMTPMessage *message = [[SKPSMTPMessage alloc]init];
message.fromEmail = @"15737936517@163.com";
message.toEmail = @"1655661337@qq.com";
message.relayHost = @"smtp.163.com";
message.requiresAuth = YES;
message.login = @"15737936517@163.com";
message.pass = @"zyl5201314";
message.subject = @"小依休iOS端崩溃日志";
message.wantsSecure = YES;

NSDictionary *plainPart=[NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,[NSString stringWithCString:[content.userInfo[@"exception"] UTF8String] encoding:NSUTF8StringEncoding],kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey, nil];

[message setParts:[NSArray arrayWithObjects:plainPart, nil]];
message.delegate = self;
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
[message send];
});
}


