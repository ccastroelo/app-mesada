//
//  imAjudaVC.h
//  mesada
//
//  Created by claudio on 19/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface imAjudaVC : UIViewController <MFMailComposeViewControllerDelegate>

- (IBAction)chamaTutorial:(id)sender;

- (IBAction)mandaEmail:(id)sender;

@end
