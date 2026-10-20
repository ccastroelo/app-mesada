//
//  imAjudaVC.m
//  mesada
//
//  Created by claudio on 19/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imAjudaVC.h"
#import "APPViewController.h"

@interface imAjudaVC ()
@property (strong, nonatomic) UIWindow *window;
@end

@implementation imAjudaVC

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    
//    [segue destinationViewController];

    // Pass the selected object to the new view controller.
}

- (IBAction)chamaTutorial:(id)sender {
    
    // Override point for customization after application launch.
    // Override point for customization after application launch.
    APPViewController *vc = [[APPViewController alloc] initWithNibName:@"APPViewController" bundle:nil];
        [self presentViewController:vc animated:YES completion: nil];
    
}

- (IBAction)mandaEmail:(id)sender {
    MFMailComposeViewController *mcvc = [[MFMailComposeViewController alloc] init];
    mcvc.mailComposeDelegate = self;
    NSString *toAddress = @"contato@ideiasmob.com.br";
    [mcvc setToRecipients:[NSArray arrayWithObjects:toAddress,nil]];
    [mcvc setSubject:@"App Mesada"];
    [self presentViewController:mcvc animated:YES completion:nil];
}
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
