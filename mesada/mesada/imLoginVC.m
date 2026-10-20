//
//  imLoginVC.m
//  mesada
//
//  Created by claudio on 17/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imLoginVC.h"
#import "SFHFKeychainUtils.h"

@interface imLoginVC ()
@property (strong, nonatomic) IBOutlet UILabel *txtDigiteSenha;
@property (nonatomic) int contador;
@end

@implementation imLoginVC

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
    self.txtDigiteSenha.text = NSLocalizedString(@"Digite sua senha:", @"Msg para digitar a senha");
    self.titulo.title = NSLocalizedString(@"Mesada", @"Titulo da tela");
    self.contador = 0;
    self.senha.delegate = self;
    
    [self.senha becomeFirstResponder];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clicouOk
{
        NSError *error;
        id password = [SFHFKeychainUtils getPasswordForUsername:@"br.eti.claudiocastro.mesada" andServiceName:@"senha2" error:&error];
        if ([self.senha.text isEqualToString:(NSString *)password]){
            [self.senha resignFirstResponder];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{

            if (self.contador>2) {
                exit(0);
            }else{
                ++self.contador;
                for (UIImageView *img in self.imgSenha){
                    img.image = [UIImage imageNamed:@"traco"];
                }
                self.aviso.text = [NSString stringWithFormat:NSLocalizedString(@"Senha incorreta (tentativa %d)\n Após 3 tentativas o app será fechado.", @"Msg de senha incorreta"),self.contador];
                self.senha.text = @"";
            }
        }
        
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
                [[self.imgSenha objectAtIndex:i] setImage: [UIImage imageNamed:(i < l) ? @"bola" : @"traco" ]];
        }
        if (shouldMoveToNextField) {
                [self clicouOk];
        }
    }
    //always return no since we are manually changing the text field
    return NO;
}


@end
