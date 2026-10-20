//
//  imMesViewCell.m
//  mesada
//
//  Created by claudio on 16/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imMesViewCell.h"

@implementation imMesViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)clicouZeraLancamento:(id)sender
{
    if (self.cellDelegate != nil && [self.cellDelegate conformsToProtocol:@protocol(imMesViewCellDelegate)]) {
        if ([self.cellDelegate respondsToSelector:@selector(zeraLancamentos:)]) {
            [self.cellDelegate zeraLancamentos:self.idMesadeiro];
        }
    }
}
-(IBAction)clicouEnviaEmail:(id)sender
{
    if (self.cellDelegate != nil && [self.cellDelegate conformsToProtocol:@protocol(imMesViewCellDelegate)]) {
        if ([self.cellDelegate respondsToSelector:@selector(enviaEmail:)]) {
            [self.cellDelegate enviaEmail:self.idMesadeiro];
        }
    }
}
@end
