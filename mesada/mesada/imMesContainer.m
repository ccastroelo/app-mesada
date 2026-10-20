//
//  imMesContainer.m
//  mesada
//
//  Created by Claudio on 19/11/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imMesContainer.h"

@interface imMesContainer ()

@end

@implementation imMesContainer

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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setMesadeiro: self.mesadeiro];
}

@end
