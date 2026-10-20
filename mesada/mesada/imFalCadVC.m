//
//  imFalCadVC.m
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imFalCadVC.h"
#import "imFalta.h"
#import "imGrupoFaltas.h"

#define MAX_LENGTH 7
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

@interface imFalCadVC ()

@property (assign, nonatomic) int maximumFractionDigits;
@property (strong, nonatomic) NSString* decimalSeparator;
@property (nonatomic) float keyboardHeight;
@property (nonatomic) float originalScrollerOffsetY;


@end

@implementation imFalCadVC

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
    
    self.scroller.contentSize = CGSizeMake(320.0, 600.0);
    self.scroller.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
	// Do any additional setup after loading the view.
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.maximumFractionDigits = (int)numberFormatter.maximumFractionDigits;
    self.decimalSeparator = numberFormatter.decimalSeparator;
    self.txtDescricao.delegate = self;
    self.txtValor.delegate = self;
}

-(void) viewDidAppear:(BOOL)animated
{
    [self.txtDescricao becomeFirstResponder];
    [super viewDidAppear:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.segmentControl.selectedSegmentIndex = 1;
    self.segmentControl.selectedSegmentIndex = 0;
    if (self.falta) {
        self.txtDescricao.text = self.falta.descricao;
        self.txtValor.text =[NSString localizedStringWithFormat:@"%.2f", self.falta.valor];
        if (self.falta.valor > 0) {
            self.segmentControl.selectedSegmentIndex = 1;
        }
    }else{
        self.txtValor.text =[NSString localizedStringWithFormat:@"-%.2f", 0.0];
    }
    [super viewWillAppear:YES];
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
    if (textField.tag == 11) {
        // get current cursor position
        BOOL negativo = NO;
        UITextRange* selectedRange = [textField selectedTextRange];
        UITextPosition* start = textField.beginningOfDocument;
        NSInteger cursorOffset = [textField offsetFromPosition:start toPosition:selectedRange.start];
        // Update the string in the text input
        NSMutableString* currentString = [NSMutableString stringWithString:textField.text];
        NSUInteger currentLength = currentString.length;
        [currentString replaceCharactersInRange:range withString:string];
        // Strip out the decimal separator
        [currentString replaceOccurrencesOfString:self.decimalSeparator withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [currentString length])];
        
        // mudanca aqui para o sinal de menos.
        NSRange rangeNegativo = [currentString rangeOfString:@"-"];
        if (rangeNegativo.location != NSNotFound){
            //        int comprimento = currentLength + 1 ;
            //        currentLength = comprimento;
            negativo = YES;
            
            [currentString replaceOccurrencesOfString:@"-" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [currentString length])];
        }
        
        
        
        // Generate a new string for the text input
        int currentValue = [currentString intValue];
        double minorUnitsPerMajor = pow(10, self.maximumFractionDigits);
        
        // mudado aqui tb
        NSString* newString;
        if (negativo) {
            newString = [NSString localizedStringWithFormat:@"-%.2f", (currentValue / minorUnitsPerMajor)];
        }else{
            newString = [NSString localizedStringWithFormat:@"%.2f", (currentValue / minorUnitsPerMajor)];
        }
        
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
    }else{
        return YES;
    }
}


- (IBAction)debitoOuCredito:(UISegmentedControl *)sender {
    NSMutableString  *valor = [NSMutableString stringWithString:self.txtValor.text];
    [valor replaceOccurrencesOfString:@"-" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [valor length])];
    if (sender.selectedSegmentIndex == 0) {
            self.txtValor.text = [NSString stringWithFormat:@"-%@",valor];
    }else{
            self.txtValor.text = valor;
    }
}

- (IBAction)cadastrar:(id)sender {
    [self.txtDescricao resignFirstResponder];
    [self.txtValor resignFirstResponder];
    NSString *valor = [self.txtValor.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
    if (!self.falta) {
        imFalta *novoItem = [[imFalta alloc] init];
        novoItem.idFalta = [[imGrupoFaltas grupo] maiorId] + 1;
        novoItem.descricao = self.txtDescricao.text;
        novoItem.valor = [valor floatValue];
        [[imGrupoFaltas grupo] addObject: novoItem];
    }else{
        self.falta.valor =  [valor floatValue];
        self.falta.descricao = self.txtDescricao.text;
    }
    [[imGrupoFaltas grupo] save];

    [self cancelar:nil];
}

- (IBAction)cancelar:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    float scrollGap = 375;
    if (IS_IPHONE5) {
        scrollGap = 550;
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField.tag==10)
    {
        
        [self.txtValor becomeFirstResponder];
    }
    return TRUE;
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


@end
