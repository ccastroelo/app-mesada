//
//  imMesViewCell.h
//  mesada
//
//  Created by claudio on 16/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSCMoreOptionTableViewCell.h"

@protocol imMesViewCellDelegate

@optional
-(void)zeraLancamentos:(int)idMesadeiro;
-(void)enviaEmail:(int)idMesadeiro;

@end


@interface imMesViewCell : MSCMoreOptionTableViewCell
@property (strong, nonatomic) IBOutlet UILabel *txtMesada;
@property (strong, nonatomic) IBOutlet UILabel *txtSaldo;
@property (strong, nonatomic) IBOutlet UILabel *txtNome;
@property (strong, nonatomic) IBOutlet UIImageView *foto;
@property (nonatomic) int idMesadeiro;

@property (weak, nonatomic) IBOutlet id cellDelegate;

-(IBAction)clicouZeraLancamento:(id)sender;
-(IBAction)clicouEnviaEmail:(id)sender;

@end


