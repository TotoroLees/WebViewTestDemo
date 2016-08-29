//
//  UIWebViewController.m
//  WebViewTestDemo
//
//  Created by Totoro.Lee on 16/8/27.
//  Copyright © 2016年 Totoro.Lee. All rights reserved.
//

#import "UIWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>


/**
 *
    如果创建一个对象,通过JSContext引用到JavaScript中被使用,当控制器不再使用该对象的时候就会将引用计数归0,而这时JavaScript访问则会出错.
 *
 */

/**
 *  制定协议(遵循 JSExport协议)
 */

@protocol JSObjcProtocol <JSExport>

/**
 *  商品详情页面返回按钮
 */
- (void)goBack;

/**
 *  购物车界面编辑按钮
 */
- (void)edit;

/**
 *  支付订单界面确认支付按钮 以及三种传值方式
 */
- (void)pay:(NSString *)payInfo;

- (void)payInfoUserID:(NSString *)userid withUserName:(NSString *)userName;

JSExportAs(payInfoOrder, - (void)payInfoOrder:(NSString *)order withPayType:(NSString *)type);

@end

//控制器遵守协议之后, 协议中的方法都需要实现.
@interface UIWebViewController ()<UIWebViewDelegate,JSObjcProtocol>

@property (strong, nonatomic) IBOutlet UIWebView *webView;

//为JavaScript提供运行环境
@property (strong ,nonatomic) JSContext *jsContext;

@end

@implementation UIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    //加载本地的HTML
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"shopsDetail_UIWebView" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //获取当前加载完成网页的上下文环境
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //将设置的标识符注入 由控制器接收
    
    //JavaScriptCore框架会通过class_copyProtocolList方法找到类所遵循的协议，然后再对每个协议通过protocol_copyProtocolList检查它是否遵循JSExport协议进而将方法反映到JavaScript之中。
    //直白的说就是 调用本地方法之后从协议中取出相对应的方法在JavaScript中调用.
    self.jsContext[@"App"] = self;
    
    //异常处理,在JSContext中执行的JavaScript如果出现异常，只会被JSContext捕获并存储在exception属性上，而不会向外抛出。时时刻刻检查JSContext对象的exception是否不为nil显然是不合适，更合理的方式是给JSContext对象设置exceptionHandler，它接受的是^(JSContext *context, JSValue *exceptionValue)形式的Block。其默认值就是将传入的exceptionValue赋给传入的context的exception属性.
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
}

/**
 *  App.goBack()
 */
- (void)goBack{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

/**
 *  App.edit();
 */
- (void)edit{
    NSLog(@"点击编辑按钮");
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
    });
}


/**
 *  var payInfo = JSON.stringify({"order": "订单号", "payType": "支付方式", "userID": "用户ID"});
 *  javascript:App.pay(payInfo);
 */
- (void)pay:(NSString *)payInfo{
    
    NSLog(@"订单信息: %@",payInfo);
    
    JSValue *payCallback = self.jsContext[@"payCallBack"];
    [payCallback callWithArguments:@[@"支付成功"]];
}

/**
 *  App.payInfoUserIDWithUserName("用户ID","用户名字");
 */
- (void)payInfoUserID:(NSString *)userid withUserName:(NSString *)userName{
    NSLog(@"%@,%@",userid,userName);
}

/**
 *  App.payInfoOrder("订单号","支付方式");
 */
- (void)payInfoOrder:(NSString *)order withPayType:(NSString *)type{
    NSLog(@"%@,%@",order,type);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //获取当前加载网页的地址,可根据判断做相应的处理
    NSString *requestString = [[[request URL]absoluteString]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //商品详情
    if ([requestString rangeOfString:@"shopsDetail_UIWebView"].location != NSNotFound) {
        
    }

    return YES;
}

@end
