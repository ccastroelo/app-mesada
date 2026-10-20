//
//  imLoginVC.h
//  mesada
//
//  Created by claudio on 17/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface imLoginVC : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *senha;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imgSenha;
@property (strong, nonatomic) IBOutlet UILabel *aviso;
@property (weak, nonatomic) IBOutlet UINavigationItem *titulo;

@end
