//
//  imSenCadVC.h
//  mesada
//
//  Created by claudio on 17/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface imSenCadVC : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *senha;
@property (strong, nonatomic) IBOutlet UITextField *confirmacao;
- (void)desativar;
- (void)ativar;
- (IBAction)cancelar:(id)sender;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imgSenha;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imgConfirmacao;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *aviso;
@property (strong, nonatomic) id password;

@end
