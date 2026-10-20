//
//  imLanVC.h
//  mesada
//
//  Created by claudio on 18/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "imMesadeiro.h"
#import "AudioToolbox/AudioServices.h"

@interface imLanVC : UIViewController{
    SystemSoundID sons[1];
}

- (IBAction)leftSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)rightSwipe:(UISwipeGestureRecognizer *)sender;

@property (strong, nonatomic) imMesadeiro *mesadeiro;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *mesada;
@property (strong, nonatomic) IBOutlet UILabel *saldo;
@property (strong, nonatomic) IBOutlet UILabel *nome;

@end
