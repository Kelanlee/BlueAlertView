//
//  BlueAlertView.h
//  BlueAlertViewDemo
//
//  Created by LiQiliang on 15/7/25.
//  Copyright (c) 2015年 LiQiliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
@interface BlueAlertView : NSObject
+(void)ShowMessageWindowsWithTitle:(NSString *)title Message:(NSString *)message ButtonCancelText:(NSString *)CancelButtonStr ButtonComlpeteText:(NSString *)completeButtonStr Comlpete:(void(^)())block;
+(void)ShowMessageWindowsWithTitle:(NSString *)title Message:(NSString *)message ButtonText:(NSString *)buttonStr Comlpete:(void(^)())block;
+(void)ShowMessageWindowsWithTitle:(NSString *)title Message:(NSString *)message Comlpete:(void(^)())block;
@end
