//
//  imMesTableVC.h
//  mesada
//
//  Created by claudio on 11/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//


#define APP ((imAppDelegate *)[[UIApplication sharedApplication] delegate])
#import <UIKit/UIKit.h>
#import "imMesViewCell.h"
#import <MessageUI/MFMailComposeViewController.h>


@interface imMesTableVC : UITableViewController <imMesViewCellDelegate,MSCMoreOptionTableViewCellDelegate, MFMailComposeViewControllerDelegate>



@end
