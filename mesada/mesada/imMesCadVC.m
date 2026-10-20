//
//  imMesCadVC.m
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imMesCadVC.h"
#import "imMesadeiro.h"
#import "imGrupoMesadeiros.h"

#define MAX_LENGTH 9
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

@interface imMesCadVC ()

@property (nonatomic) float keyboardHeight;
@property (nonatomic) float originalScrollerOffsetY;
@property (assign, nonatomic) int maximumFractionDigits;
@property (strong, nonatomic) NSString* decimalSeparator;

@end

@implementation imMesCadVC


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
	// Do any additional setup after loading the view.
    
    // Set up the scroll view.
    self.scroller.contentSize = CGSizeMake(320.0, 600.0);
    self.scroller.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.maximumFractionDigits = (int)numberFormatter.maximumFractionDigits;
    self.decimalSeparator = numberFormatter.decimalSeparator;
    self.txtValorMesada.delegate = self;
    self.email.delegate = self;
    self.txtNome.delegate = self;
    self.txtValorMesada.text =[NSString localizedStringWithFormat:@"%.2f", 0.0];
    if (self.mesadeiro) {
        self.txtNome.text = self.mesadeiro.nome;
        self.txtValorMesada.text =[NSString localizedStringWithFormat:@"%.2f", self.mesadeiro.valorMesadaInicial];
        self.email.text = self.mesadeiro.email;
        self.foto.image = self.mesadeiro.foto;
    }
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.txtNome becomeFirstResponder];
    [super viewDidAppear:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewWillDisappear:YES];
}

- (IBAction)cancelar:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cadastrar:(id)sender {
    NSString *valor = [self.txtValorMesada.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
    if(!self.mesadeiro){
        imMesadeiro *novoItem = [[imMesadeiro alloc] init];
        novoItem.idMesadeiro = [[imGrupoMesadeiros grupo] maiorId] + 1;
        novoItem.nome = self.txtNome.text;
        novoItem.valorMesadaInicial = [valor floatValue];
        novoItem.foto = [self.foto.image copy];
        novoItem.email = self.email.text;
        [[imGrupoMesadeiros grupo] addObject: novoItem];
    }else{
        self.mesadeiro.nome = self.txtNome.text;
        self.mesadeiro.valorMesadaInicial = [valor floatValue];
        self.mesadeiro.foto = [self.foto.image copy];
        self.mesadeiro.email = self.email.text;
    }
    
    [[imGrupoMesadeiros grupo] save];
    [self.txtNome resignFirstResponder];
    [self cancelar:nil];
}

- (IBAction)selecionaFoto:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo{
    
    self.foto.image = img;
    [picker dismissViewControllerAnimated:YES completion:NULL];

    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
    // get current cursor position
    if (textField.tag == 3) {
        UITextRange* selectedRange = [textField selectedTextRange];
        UITextPosition* start = textField.beginningOfDocument;
        NSInteger cursorOffset = [textField offsetFromPosition:start toPosition:selectedRange.start];
        // Update the string in the text input
        NSMutableString* currentString = [NSMutableString stringWithString:textField.text];
        NSUInteger currentLength = currentString.length;
        [currentString replaceCharactersInRange:range withString:string];
        // Strip out the decimal separator
        [currentString replaceOccurrencesOfString:self.decimalSeparator withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [currentString length])];
        // Generate a new string for the text input
        int currentValue = [currentString intValue];
        double minorUnitsPerMajor = pow(10, self.maximumFractionDigits);
        NSString* newString = [NSString localizedStringWithFormat:@"%.2f", (currentValue / minorUnitsPerMajor)];
        if (newString.length <= MAX_LENGTH) {
            textField.text = newString;
            // if the cursor was not at the end of the string being entered, restore cursor position
            if (cursorOffset != currentLength) {
                int lengthDelta = (int)(newString.length - currentLength);
                int newCursorOffset = (int)MAX(0, MIN(newString.length, cursorOffset + lengthDelta));
                UITextPosition* newPosition = [textField positionFromPosition:textField.beginningOfDocument offset:newCursorOffset];
                UITextRange* newRange = [textField textRangeFromPosition:newPosition toPosition:newPosition];
                [textField setSelectedTextRange:newRange];
            }
        }
        return NO;
    } else {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    float scrollGap = 375;
    if (IS_IPHONE5) {
        scrollGap = 535;
    }
    if (self.keyboardHeight) {
        float viewWidth = self.view.frame.size.width;
        float viewHeight = self.view.frame.size.height;
        float scrollOrigemY = textField.frame.origin.y;
        CGRect viewableAreaFrame = CGRectMake(0.0, 0.0, viewWidth, viewHeight - scrollOrigemY - self.keyboardHeight);
        CGRect txtDemoFrame = textField.frame;
        if (!CGRectContainsRect(viewableAreaFrame, txtDemoFrame))
        {
            float scrollPointY = viewHeight - self.keyboardHeight + (scrollOrigemY-scrollGap);
            self.originalScrollerOffsetY = self.scroller.contentOffset.y;
            [self.scroller setContentOffset:CGPointMake(0.0, scrollPointY) animated:YES];
        }
    }
}


-(void)keyboardWasShown:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    CGSize keyboardSize = [[keyboardInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.keyboardHeight = keyboardSize.height;
}

-(void)keyboardWillHide:(NSNotification *)notification{
    [self.scroller setContentOffset:CGPointMake(0.0, self.originalScrollerOffsetY) animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField.tag==1)
    {
        [self.email becomeFirstResponder];
    }else if (textField.tag==2)
    {
        [self.txtValorMesada becomeFirstResponder];
    }
    return TRUE;
}


@end
