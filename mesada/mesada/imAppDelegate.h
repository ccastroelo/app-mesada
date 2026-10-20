//
//  imAppDelegate.h
//  mesada
//
//  Created by claudio on 11/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface imAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MFMailComposeViewController *globalMailComposer;

-(void)cycleTheGlobalMailComposer;

@end
