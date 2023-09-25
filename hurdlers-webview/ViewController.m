//
//  ViewController.m
//  hurdlers-webview
//
//  Created by 유준혁 on 2023/09/18.
//

#import "ViewController.h"

@interface ViewController ()

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRApp configure];

    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"firebase"];
    
    NSURL *url = [NSURL URLWithString:@"http://118.67.142.80"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.body[@"command"] isEqual:@"setUserProperty"]) {
        [FIRAnalytics setUserPropertyString:message.body[@"value"] forName:message.body[@"name"]];
    } else if ([message.body[@"command"] isEqual:@"logEvent"]) {
        NSDictionary *params = [self iterateJsonAndAddToDictionary:message.body[@"parameters"]];
        [FIRAnalytics logEventWithName:message.body[@"name"] parameters:params];
    }
}

- (NSMutableDictionary *)iterateJsonAndAddToDictionary:(NSDictionary *)jsonObject {
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    
    for (NSString *key in jsonObject) {
        id value = jsonObject[key];

        if ([key isEqualToString:@"items"] && [value isKindOfClass:[NSArray class]]) {
            NSArray *itemsArray = (NSArray *)value;
            NSArray *processedItems = [self googleAnalyticsItemsToDictionaries:itemsArray];
            [item setObject:processedItems forKey:@"items"];
        } else if ([key isEqualToString:@"value"]) {
            NSNumber *numberValue = nil;
            
            if ([value isKindOfClass:[NSString class]]) {
                numberValue = @([(NSString *)value doubleValue]);
            } else if ([value isKindOfClass:[NSNumber class]]) {
                numberValue = (NSNumber *)value;
            }
            
            if (numberValue) {
                [item setObject:numberValue forKey:@"value"];
            } else {
                NSLog(@"Failed to parse 'value' as a number: %@", value);
            }
        } else if ([value isKindOfClass:[NSString class]]) {
            [item setObject:value forKey:key];
        } else {
            // For unexpected data types, you can log or handle them accordingly.
            NSLog(@"Unexpected data type for key %@: %@", key, [value class]);
        }
    }

    return item;
}


- (NSArray *)googleAnalyticsItemsToDictionaries:(NSArray *)itemsArray {
    NSMutableArray *items = [NSMutableArray array];
    
    NSDictionary *keyMapping = @{
        @"item_id": kFIRParameterItemID,
        @"item_name": kFIRParameterItemName,
        @"item_category": kFIRParameterItemCategory,
        @"item_category2": kFIRParameterItemCategory2,
        @"item_category3": kFIRParameterItemCategory3,
        @"item_category4": kFIRParameterItemCategory4,
        @"item_variant": kFIRParameterItemVariant,
        @"item_brand": kFIRParameterItemBrand,
        @"price": kFIRParameterPrice,
        @"quantity": kFIRParameterQuantity,
        @"discount": kFIRParameterDiscount
    };
    
    for (id itemObj in itemsArray) {
        if (![itemObj isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Unexpected item type in itemsArray: %@", [itemObj class]);
            continue;
        }
        
        NSDictionary *itemJson = (NSDictionary *)itemObj;
        NSMutableDictionary *itemDict = [NSMutableDictionary dictionary];
        
        for (NSString *key in keyMapping) {
            id value = itemJson[key];
            NSString *firebaseKey = keyMapping[key];

            if ([value isKindOfClass:[NSString class]]) {
                [itemDict setObject:value forKey:firebaseKey];
            } else if ([value isKindOfClass:[NSNumber class]]) {
                [itemDict setObject:@([value doubleValue]) forKey:firebaseKey];
            }
        }

        [items addObject:itemDict];
    }

    return [items copy];
}

@end


