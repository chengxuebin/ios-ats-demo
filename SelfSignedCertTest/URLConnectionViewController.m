//
//  ViewController.m
//  CronetTest
//
//  Created by CHENGXUEBIN on 2020/7/20.
//  Copyright © 2020 CHENGXUEBIN. All rights reserved.
//

#import "URLConnectionViewController.h"
#import <WebKit/WebKit.h>

@interface URLConnectionViewController ()<NSURLConnectionDelegate>{
    NSURLRequest *request;
    NSMutableData *receivedData;
    NSURLConnection *connection;
    NSURL *url;
}

@property (weak, nonatomic) IBOutlet WKWebView *myWebView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtn;

@end

@implementation URLConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self reloadRequest];
}

- (IBAction)buttonClicked:(id)sender {
    [_myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];

    // 延时1s重新请求，以便看到刷新
    [self performSelector:@selector(reloadRequest) withObject:nil afterDelay:1.0];
}

// 异步请求
- (void)reloadRequest {
    // 初始化“receivedData”保存接收的数据
    receivedData = [NSMutableData dataWithCapacity:0];
    
    // 1.请求路径
    NSURL *url = [NSURL URLWithString:@"https://self-signed.badssl.com/"];
    
    // 2.创建请求对象
    request = [NSURLRequest requestWithURL:url];
    
    // 3.异步发送请求
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    NSLog(@"didReceiveAuthenticationChallenge %@ %zd", [[challenge protectionSpace] authenticationMethod], (ssize_t) [challenge previousFailureCount]);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        [[challenge sender]  useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        [[challenge sender]  continueWithoutCredentialForAuthenticationChallenge: challenge];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {

    // 释放数据对象
    connection = nil;
    receivedData = nil;

    // 通知用户
    NSLog(@"连接失败! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    NSLog(@"Succeeded! Received %lu bytes of data",[receivedData length]);

    NSString *html = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
    [self.myWebView loadHTMLString:html baseURL:url];
    // 释放数据对象
    connection = nil;
    receivedData = nil;
}
@end
