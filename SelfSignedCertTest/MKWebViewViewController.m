//
//  ViewController.m
//  CronetTest
//
//  Created by CHENGXUEBIN on 2020/7/20.
//  Copyright © 2020 CHENGXUEBIN. All rights reserved.
//

#import "MKWebViewViewController.h"

@interface MKWebViewViewController ()<WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *myWebView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtn;

@end

@implementation MKWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _myWebView.navigationDelegate=self;
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
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 3.异步发送请求
    [_myWebView loadRequest:request];
}

#pragma mark: WKWebView的https配置
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
   NSLog(@"didReceiveAuthenticationChallenge %@ %zd", [[challenge protectionSpace] authenticationMethod], (ssize_t) [challenge previousFailureCount]);
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        NSURLCredential * credential = [[NSURLCredential alloc] initWithTrust:[challenge protectionSpace].serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}

@end
