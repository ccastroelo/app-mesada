//
//  imMesCadVC.h
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "imMesadeiro.h"

@interface imMesCadVC : UIViewController <UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) imMesadeiro *mesadeiro;
@property (strong, nonatomic) IBOutlet UITextField *txtValorMesada;
@property (strong, nonatomic) IBOutlet UITextField *txtNome;
@property (strong, nonatomic) IBOutlet UIImageView *foto;
@property (strong, nonatomic) IBOutlet UIScrollView *scroller;

@property (strong, nonatomic) IBOutlet UITextField *email;


- (IBAction)cancelar:(id)sender;
- (IBAction)cadastrar:(id)sender;
- (IBAction)selecionaFoto:(id)sender;


@end
