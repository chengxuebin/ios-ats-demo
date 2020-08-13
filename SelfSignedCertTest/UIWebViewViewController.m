//
//  ViewController.m
//  CronetTest
//
//  Created by CHENGXUEBIN on 2020/7/20.
//  Copyright © 2020 CHENGXUEBIN. All rights reserved.
//

#import "UIWebViewViewController.h"

@interface UIWebViewViewController ()<UIWebViewDelegate, NSURLConnectionDelegate> {
    BOOL _Authenticated;
    NSURLRequest *_FailedRequest;
}

@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtn;

@end

@implementation UIWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    [self.myWebView loadRequest:request];
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL result = _Authenticated;
    if (!_Authenticated) {
        _FailedRequest = request;
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return result;
}


-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"didReceiveAuthenticationChallenge %@ %zd", [[challenge protectionSpace] authenticationMethod], (ssize_t) [challenge previousFailureCount]);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        [[challenge sender]  useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        [[challenge sender]  continueWithoutCredentialForAuthenticationChallenge: challenge];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)pResponse {
    _Authenticated = YES;
    [connection cancel];
    [_myWebView loadRequest:_FailedRequest];
}

@end
