//
//  imFalCadVC.h
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "imFalta.h"

@interface imFalCadVC : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) imFalta *falta;
@property (strong, nonatomic) IBOutlet UITextField *txtDescricao;
@property (strong, nonatomic) IBOutlet UITextField *txtValor;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) IBOutlet UIScrollView *scroller;

- (IBAction)debitoOuCredito:(UISegmentedControl *)sender;
- (IBAction)cadastrar:(id)sender;
- (IBAction)cancelar:(id)sender;

@end
