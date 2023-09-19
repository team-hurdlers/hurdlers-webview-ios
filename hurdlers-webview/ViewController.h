//
//  ViewController.h
//  hurdlers-webview
//
//  Created by 유준혁 on 2023/09/18.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <Firebase.h>

@interface ViewController : UIViewController <WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;

- (NSMutableDictionary *)iterateJsonAndAddToDictionary:(NSDictionary *)jsonObject;
- (NSDictionary *)googleAnalyticsItemParamToDictionary:(NSArray *)itemsArray;

@end

