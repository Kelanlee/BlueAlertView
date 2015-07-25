//
//  BlueAlertView.m
//  BlueAlertViewDemo
//
//  Created by LiQiliang on 15/7/25.
//  Copyright (c) 2015年 LiQiliang. All rights reserved.
//

#import "BlueAlertView.h"
#define CornerRadius 5
@implementation BlueAlertView
static UIView *messageView;
static NSMutableArray *messageQueue;
static NSMutableArray *blockQueue;
static NSTimer *messageViewTimer;
+(void)SetRoundCorner:(id)view{
    UIView *currentView=(UIView *)view;
    
    [currentView.layer setCornerRadius:CornerRadius];
}
+(UIViewController *)CheckTopViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+(UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}
+(CGSize)CalculateTheSizeForString:(NSString *)str MaxSize:(CGSize)size Font:(UIFont*)font{
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    return [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
}
+(void)ShowMessageWindowsWithTitle:(NSString *)title Message:(NSString *)message Comlpete:(void(^)())block{
    [self ShowMessageWindowsWithTitle:title Message:message ButtonText:@"OK" Comlpete:block];
}
+(void)ShowMessageWindowsWithTitle:(NSString *)title Message:(NSString *)message ButtonText:(NSString *)buttonStr Comlpete:(void(^)())block
{
    [self ShowMessageWindowsWithTitle:title Message:message ButtonCancelText:nil ButtonComlpeteText:buttonStr Comlpete:block];
}
+(void)ShowMessageWindowsWithTitle:(NSString *)title Message:(NSString *)message ButtonCancelText:(NSString *)CancelButtonStr ButtonComlpeteText:(NSString *)completeButtonStr Comlpete:(void(^)())block{
    if (messageViewTimer== nil) {
        messageViewTimer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(CheckMessageViewIsOnTheTop) userInfo:nil repeats:YES];
    }
    if (messageQueue==nil) {
        messageQueue=[[NSMutableArray alloc]init];
    }
    if (blockQueue==nil) {
        blockQueue=[[NSMutableArray alloc]init];
    }
    if (block==NULL) {
        [blockQueue addObject:(^(){})];
    }else{
        [blockQueue addObject:block];
    }
    UIViewController *currentController=[self CheckTopViewController];
    UIView *newView =[[UIView alloc]initWithFrame:currentController.view.frame];
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestrueDoNothing)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [newView addGestureRecognizer:panRecognizer];    [newView setUserInteractionEnabled:YES];
    //background
    UIView *backgroundColorView=[[UIView alloc]initWithFrame:currentController.view.frame];
    [backgroundColorView setBackgroundColor:[UIColor blackColor]];
    [backgroundColorView setAlpha:0.6f];
    [backgroundColorView setUserInteractionEnabled:YES];
    backgroundColorView.tag=100;
    //message
    
    UILabel *messageLabel=[[UILabel alloc]init];
    [messageLabel setNumberOfLines:0];
    CGSize size=[self CalculateTheSizeForString:message MaxSize:CGSizeMake(280, 230) Font:messageLabel.font];
    [messageLabel setFrame:CGRectMake(10, 60, 280, size.height)];
    [messageLabel setText:message];
    //message View
    UIView* messageWindow=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 130+size.height)];
    messageWindow.center=newView.center;
    [messageWindow setBackgroundColor:[UIColor whiteColor]];
    [self SetRoundCorner:messageWindow];
    //Title
    UILabel *labelTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, 13, 280, 21)];
    [labelTitle setText:title];
    //breakline
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 50, 300, 1)];
    [lineView setBackgroundColor:[UIColor lightGrayColor]];
    //button
    UIView *buttonView=[[UIView alloc]initWithFrame:CGRectMake(10, 70+size.height, 280, 50)];
    [buttonView setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:146/255.0 blue:202/255.0 alpha:1.0f]];
    [self SetRoundCorner:buttonView];
    
    if (CancelButtonStr==nil) {
        
        UIButton *buttonOK=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 280, 50)];
        [buttonOK setTitle:completeButtonStr forState:UIControlStateNormal];
        [buttonView addSubview:buttonOK];
        [buttonOK addTarget:self action:@selector(DismissMessageViewWithBlock) forControlEvents:UIControlEventTouchUpInside];
    }else{
        
        UIButton *buttonOK=[[UIButton alloc]initWithFrame:CGRectMake(140, 0, 140, 50)];
        [buttonOK setTitle:completeButtonStr forState:UIControlStateNormal];
        UIButton *buttonCancel=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 140, 50)];
        [buttonCancel setTitle:CancelButtonStr forState:UIControlStateNormal];
        [buttonView addSubview:buttonOK];
        [buttonView addSubview:buttonCancel];
        [buttonOK addTarget:self action:@selector(DismissMessageViewWithBlock) forControlEvents:UIControlEventTouchUpInside];
        [buttonCancel addTarget:self action:@selector(DismissMessageView) forControlEvents:UIControlEventTouchUpInside];
        UIView *divider=[[UIView alloc]initWithFrame:CGRectMake(140, 0, 1, 50)];
        [divider setBackgroundColor:[UIColor whiteColor]];
        [buttonView addSubview:divider];
    }
    
    
    
    
    [messageWindow addSubview:labelTitle];
    [messageWindow addSubview:lineView];
    [messageWindow addSubview:messageLabel];
    [messageWindow addSubview:buttonView];
    [newView addSubview:backgroundColorView];
    [newView addSubview:messageWindow];
    if (messageView!=nil) {
        [messageQueue addObject:newView];
    }else{
        messageView=newView;
        [messageView setUserInteractionEnabled: YES];
        [currentController.view addSubview:messageView];
    }
    
}
+(void)gestrueDoNothing{
    return;
}
+(void)CheckMessageViewIsOnTheTop{
    if (messageView!=nil) {
        messageView.hidden=NO;
        messageView.alpha=1;
        messageView.userInteractionEnabled=YES;
        NSArray* viewArray= messageView.subviews;
        
        for (UIView* view in viewArray) {
            if (view.tag==100) {
                view.center=messageView.center;
                view.frame=messageView.frame;
                view.hidden=NO;
                view.userInteractionEnabled=YES;
            }
        }
        UIViewController *rootController=[self CheckTopViewController];
        if ([messageView superview]!=rootController.view) {
            [messageView removeFromSuperview];
            messageView.center=rootController.view.center;
            messageView.frame=rootController.view.frame;
            [rootController.view addSubview:messageView];
        }else{
            messageView.center=rootController.view.center;
            messageView.frame=rootController.view.frame;
            [rootController.view bringSubviewToFront:messageView];
        }
    }
}
+(void)DismissMessageViewWithBlock{
    [messageViewTimer invalidate];
    [UIView animateWithDuration:0.25f animations:^{
        [messageView setAlpha:0.0f];
        
    } completion:^(BOOL isFinish){
        if (isFinish) {
            void(^thisBlock)()=blockQueue[0];
            thisBlock();
            
            [messageView removeFromSuperview];
            [blockQueue removeObjectAtIndex:0];
            [messageQueue removeObject:messageView];
            UIViewController *currentController=[self CheckTopViewController];
            if (messageQueue.count>0) {
                messageView=messageQueue[0];
                [currentController.view addSubview:messageView];
                messageViewTimer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(CheckMessageViewIsOnTheTop) userInfo:nil repeats:YES];
            }else{
                messageView=nil;
                messageViewTimer=nil;
            }
            
        }
    }];
}
+(void)DismissMessageView{
    [messageViewTimer invalidate];
    [UIView animateWithDuration:0.25f animations:^{
        [messageView setAlpha:0.0f];
    } completion:^(BOOL isFinish){
        if (isFinish) {
            [messageView removeFromSuperview];
            [blockQueue removeObjectAtIndex:0];
            [messageQueue removeObject:messageView];
            UIViewController *currentController=[self CheckTopViewController];
            if (messageQueue.count>0) {
                messageView=messageQueue[0];
                [currentController.view addSubview:messageView];
                messageViewTimer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(CheckMessageViewIsOnTheTop) userInfo:nil repeats:YES];
            }else{
                messageView=nil;
                messageViewTimer=nil;
            }
            
        }
    }];
}

@end
