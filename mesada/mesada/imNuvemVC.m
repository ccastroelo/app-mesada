//
//  imNuvemVC.m
//  mesada
//
//  Created by Claudio on 05/03/15.
//  Copyright (c) 2015 ideiasmob. All rights reserved.
//

#import "imNuvemVC.h"
#import <Dropbox/Dropbox.h>


@interface imNuvemVC ()

@end

@implementation imNuvemVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)linkarComDropBox:(id)sender{
  
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    
    if (account == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Link to Dropbox
            [[DBAccountManager sharedManager] linkFromController:self];
        });
    } else {
        // Unlink from Dropbox
        [account unlink];
        
        // Shutdown and stop listening for changes to the datastores
        [[DBDatastoreManager sharedManager] shutDown];
        [[DBDatastoreManager sharedManager] removeObserver:self];
        
        // Use local datastores
        [DBDatastoreManager setSharedManager:[DBDatastoreManager localManagerForAccountManager:[DBAccountManager sharedManager]]];
        
        // No lists yet? Show row to add a list
        // self.isAddingList = [[[DBDatastoreManager sharedManager] listDatastores:nil] count] < 1;
        
        // Observe changes to datastore list (possibly from other devices)

        [[DBDatastoreManager sharedManager] addObserver:self block:^() {
            // Reload list of lists to get changes

        }];
    }
}



@end
