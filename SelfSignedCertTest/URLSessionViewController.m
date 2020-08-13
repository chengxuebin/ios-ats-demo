//
//  ViewController.m
//  CronetTest
//
//  Created by CHENGXUEBIN on 2020/7/20.
//  Copyright © 2020 CHENGXUEBIN. All rights reserved.
//

#import "URLSessionViewController.h"

@interface URLSessionViewController ()<NSURLSessionDelegate>{
    NSURLRequest *request;
}

@property (weak, nonatomic) IBOutlet WKWebView *myWebView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtn;

@end

@implementation URLSessionViewController

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
    // 1.请求路径
    NSURL *url = [NSURL URLWithString:@"https://self-signed.badssl.com/"];
    
    // 2.创建请求对象
    request = [NSURLRequest requestWithURL:url];
    
    NSLog(@"send request:%@",url.absoluteURL);
    
    // 3.异步发送请求
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:Nil];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Response:%@",html);
            [self.myWebView loadHTMLString:html baseURL:url];
            });
    }];
    [task resume];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
  if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
      
      if([challenge.protectionSpace.host isEqualToString: [request URL].host ]){
          
          NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
          completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
  }
}

@end
