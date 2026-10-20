//
//  APPChildViewController.m
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

#import "APPChildViewController.h"

@interface APPChildViewController ()
 @property (strong, nonatomic) NSArray *tutorial;
@end

@implementation APPChildViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (IS_IPHONE5) {
        self.tutorial = [NSArray arrayWithObjects:@"tela1", @"tela2",@"tela3", @"tela4", nil];
    }else{
        self.tutorial = [NSArray arrayWithObjects:@"tela41", @"tela42",@"tela43", @"tela44", nil];
    }
    [self.fechar setTitle:NSLocalizedString(@"Fechar Tutorial", @"Fechar Tutorial") forState: UIControlStateNormal];
}

- (void) viewWillAppear:(BOOL)animated
{
    //  NSString        *all = [self.dataObjectImagem description];
    NSString        *all = [[self.tutorial objectAtIndex: self.index] description];
    NSString        *name = [all stringByDeletingPathExtension];
    NSString        *file = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];
    self.fundo.image = image;
    if (self.index < 3) {
        self.fechar.hidden = YES;
    }else{
        self.fechar.hidden = NO;
    }
    [super viewWillAppear:YES];
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (IBAction)fechaTutorial:(id)sender {
                [self dismissViewControllerAnimated:YES completion:nil];
}
@end
