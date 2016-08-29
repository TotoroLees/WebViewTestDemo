//
//  WKWebViewController.m
//  WebViewTestDemo
//
//  Created by Totoro.Lee on 16/8/27.
//  Copyright © 2016年 Totoro.Lee. All rights reserved.
//

#import "WKWebViewController.h"

#import <WebKit/WebKit.h>

@interface WKWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (strong ,nonatomic) WKWebView *webView;

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化
    //_webView = [[WKWebView alloc]initWithFrame:self.view.bounds];
    
    //带有设置选项的初始化
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
    _webView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:configuration];
    
    //设置代理
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    
    //加载本地的HTML
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"shopsDetail_WKWebView" withExtension:@"html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    [self.view addSubview:_webView];
    
    //添加一个名称,可以在JS中通过这个名称发送消息
    [[_webView configuration].userContentController addScriptMessageHandler:self name:@"goBackApp"];
    [[_webView configuration].userContentController addScriptMessageHandler:self name:@"goShoppingApp"];
}

/**
 *  WKScriptMessageHandler协议中必须要实现的方法
    用来接收JS端通过window.webkit.messageHandlers.{Name}.postMessage()方法发送的消息并做相应处理
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"方法名 %@，传回参数 %@",message.name,message.body);
    
    //根据方法名来区分
    if ([message.name isEqual:@"goBackApp"]) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if ([message.name isEqual:@"goShoppingApp"]){
        //调用JS中的方法并将参数传递到JS中
        [self.webView evaluateJavaScript:@"altertFromOC('商品1,商品2')" completionHandler:nil];
    }
}

/**
 *  WKUIDelegate 代理方法
    用来监听webView中的alert方法
 *
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    //调用原生的alert方法
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

/**
 *  WKNavigationDelegate 代理方法
 */

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
//    [ProgressHUDManager showWithStatus:@"加载中"];
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
//    [ProgressHUDManager dismiss];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(nonnull NSError *)error{
//    [ProgressHUDManager showErrorWithStatus:@"网络错误"];
}

@end
