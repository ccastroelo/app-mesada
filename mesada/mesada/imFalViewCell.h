//
//  imFalViewCell.h
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface imFalViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *regraLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (nonatomic) int idFalta;

@end
