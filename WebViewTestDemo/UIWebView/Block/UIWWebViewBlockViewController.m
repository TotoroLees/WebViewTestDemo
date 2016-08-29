//
//  UIWWebViewBlockViewController.m
//  WebViewTestDemo
//
//  Created by Totoro.Lee on 16/8/27.
//  Copyright © 2016年 Totoro.Lee. All rights reserved.
//

#import "UIWWebViewBlockViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

/**
 *  使用协议的方式注入的交互对象为控制器self，这样JSContext环境引用控制器self，在退出控制器的时候，因为控制器self被JSContext引用而不释放，而JSContext只有等控制器释放了才能随之释放，所以就引起了循环引用，造成内存泄露。
 */

@interface UIWWebViewBlockViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong ,nonatomic) JSContext *context;

@end

@implementation UIWWebViewBlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.delegate = self;
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"shopsDetail_UIWebView_Block" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //获取网页上下文环境
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    __weak typeof(self)  weakSelf = self;
    //Block可以传入JSContext中当做JavaScript的方法使用
    self.context[@"goBack"] = ^() {
        NSLog(@"点击返回按钮");
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    };
    
    self.context[@"goShopping"] = ^() {
        NSLog(@"点击购物车按钮");
        //获取参数列表
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            NSLog(@"%@", jsVal);
        }
        //获取当前调用该方法的对象
        JSValue *this = [JSContext currentThis];
        NSLog(@"this: %@",this);

        [weakSelf go];
    };
}

- (void)go{
    //将参数传进去来调用方法
    [self.context evaluateScript:@"go('商品3')"];
}

@end
