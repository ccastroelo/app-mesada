//
//  imSenCadVC.m
//  mesada
//
//  Created by claudio on 17/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imSenCadVC.h"
#import "SFHFKeychainUtils.h"

@interface imSenCadVC ()

@property (nonatomic) int evento;
 //   @property (nonatomic) bool executado;
@end

@implementation imSenCadVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.contentSize = CGSizeMake((self.view.frame.size.width-20)*2, 480.0f);
    //    self.scrollView.contentInset=UIEdgeInsetsMake(0.0, 50.0, 0.0, 50.0);
    // self.scrollView.scrollIndicatorInsets=UIEdgeInsetsMake(0.0, 50.0, 0.0, 50.0);
    [self.scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];

//    self.executado = NO;
    self.aviso.text = @"";
    self.senha.delegate = self;
    self.confirmacao.delegate = self;
    [self.senha becomeFirstResponder];
    NSError *error;
    self.password = [SFHFKeychainUtils getPasswordForUsername:@"br.eti.claudiocastro.mesada" andServiceName:@"senha2" error:&error];
    self.evento = 1;
    if(!self.password){
        self.evento = 0;
    }

}

- (void)viewDidLayoutSubviews{
/*    if (!self.executado) {
        self.executado = YES;
        self.scrollView.contentSize = CGSizeMake((self.view.frame.size.width-20)*2, 480.0f);
        //    self.scrollView.contentInset=UIEdgeInsetsMake(0.0, 50.0, 0.0, 50.0);
        // self.scrollView.scrollIndicatorInsets=UIEdgeInsetsMake(0.0, 50.0, 0.0, 50.0);
        [self.scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
    }  */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)desativar {
    NSError *error;
    if ([self.senha.text isEqualToString: self.password]) {
        [SFHFKeychainUtils deleteItemForUsername:@"br.eti.claudiocastro.mesada" andServiceName:@"senha2" error:&error];
        [self.senha resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        self.aviso.text = NSLocalizedString(@"Senha incorreta", @"Msg de senha incorreta");
        self.senha.text = @"";
        for (UIImageView *img in self.imgSenha){
            img.image = [UIImage imageNamed:@"traco"];
        }
    }
}

- (void)ativar {
    if ([self.senha.text isEqualToString: self.confirmacao.text]) {
            NSError *error;
            NSString *objectString = [NSString stringWithFormat:@"%@", self.senha.text];
            [SFHFKeychainUtils storeUsername:@"br.eti.claudiocastro.mesada" andPassword:objectString forServiceName:@"senha2" updateExisting:YES error:&error];
            [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        self.aviso.text = NSLocalizedString(@"As senhas não coincidem. Tente novamente.", @"Msg de senha não coincide");
        [self.confirmacao resignFirstResponder];
        self.confirmacao.text = @"";
        self.senha.text = @"";
        for (UIImageView *img in self.imgSenha){
            img.image = [UIImage imageNamed:@"traco"];
        }
        [self.scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
        [self.senha becomeFirstResponder];
    }
}
- (IBAction)cancelar:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldProcess = NO; //default to reject
    BOOL shouldMoveToNextField = NO; //default to remaining on the current field
    
    int insertStringLength = (int)[string length];
    if(insertStringLength == 0){ //backspace
        shouldProcess = YES; //Process if the backspace character was pressed
    }
    else {
        if([[textField text] length] < 4) {
            shouldProcess = YES; //Process if there is only 1 character right now
        }
    }
    
    //here we deal with the UITextField on our own
    if(shouldProcess){
        //grab a mutable copy of what's currently in the UITextField
        NSMutableString* mstring = [[textField text] mutableCopy];
        if([mstring length] == 3 && insertStringLength > 0){
            
            //nothing in the field yet so append the replacement string
            [mstring appendString:string];
            shouldMoveToNextField = YES;
        }
        else{
            //adding a char or deleting?
            if(insertStringLength > 0){
                [mstring insertString:string atIndex:range.location];
            }
            else {
                //delete case - the length of replacement string is zero for a delete
                [mstring deleteCharactersInRange:range];
            }
        }
        
        //set the text now
        [textField setText:mstring];
        int l = (int)mstring.length;
        for (int i = 0; i < 4; ++i) {
            if (textField.tag == 1){
                [[self.imgSenha objectAtIndex:i] setImage: [UIImage imageNamed:(i < l) ? @"bola" : @"traco" ]];
            } else if (textField.tag == 2) {
                [[self.imgConfirmacao objectAtIndex:i] setImage: [UIImage imageNamed:(i < l) ? @"bola" : @"traco"]];
            }
        }
    
        
        if (shouldMoveToNextField) {
            if (self.evento == 0) {
                if (textField.tag == 1) {
                    for (UIImageView *img in self.imgConfirmacao){
                        img.image = [UIImage imageNamed:@"traco"];
                    }
                    [textField resignFirstResponder];
                    [self.confirmacao becomeFirstResponder];
                    [self.scrollView setContentOffset:CGPointMake(300.0f, 0.0f) animated:YES];

                }else if(textField.tag == 2){
                    [self ativar];
                }
            }else{
                [self desativar];
            }
            
        }
    }
    
    //always return no since we are manually changing the text field
    return NO;
}


@end
