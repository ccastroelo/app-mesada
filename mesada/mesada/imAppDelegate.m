//
//  imAppDelegate.m
//  mesada
//
//  Created by claudio on 11/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imAppDelegate.h"
#import "Flurry.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Dropbox/Dropbox.h>
#import "imGrupoMesadeiros.h"

@interface imAppDelegate()

@property (nonatomic, strong) DBDatastore *datastore;

@end

@implementation imAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
        // Override point for customization after application launch.
        DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:@"q813ua1szk6qb3u" secret:@"czkqe5gzjr3oyle"];
        [DBAccountManager setSharedManager:accountManager];
    
        DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    
        if (account) {
            // Use Dropbox datastores
            [DBDatastoreManager setSharedManager:[DBDatastoreManager managerForAccount:account]];
            // Delete the row from the data source
/*            NSArray *datastores = [[DBDatastoreManager sharedManager] listDatastores:nil];
            for (DBDatastoreInfo *datastoreInfo in datastores) {
                [[DBDatastoreManager sharedManager] deleteDatastore:datastoreInfo.datastoreId error:nil];
            }  */
        } else {
            // Use local datastores
   //         [DBDatastoreManager setSharedManager:[DBDatastoreManager localManagerForAccountManager:[DBAccountManager sharedManager]]];
        }

    
    
    [Flurry setCrashReportingEnabled:YES];
    //note: iOS only allows one crash reporting tool per app; if using another, set to: NO
    [Flurry startSession:@"59JXRF6FW6PR8HWN82QS"];
    [self cycleTheGlobalMailComposer];
    
    [[UITabBar appearance] setTintColor: [UIColor colorWithRed:143.0/255 green:0.0/255 blue:2.0/255 alpha:1.0]];
    
    return YES;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *action = [url lastPathComponent];
    
    if ([action isEqualToString:@"connect"]) {
        // Account linked to Dropbox -- db-gmd9bz0ihf8t30o://1/connect
        DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
        
        if (account) {
            // App linked successfully!
            NSLog(@"Linkado com o remoto - delegate 1");
            [DBDatastoreManager setSharedManager:[DBDatastoreManager managerForAccount:account]];

            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *dataStoreID = [defaults objectForKey:@"dataStoreID"];
            if (!dataStoreID) {
                self.datastore = [[DBDatastoreManager sharedManager] createDatastore:nil];
                [self.datastore setRoleForPrincipal:DBPrincipalPublic to:DBRoleEditor];
                [[imGrupoMesadeiros grupo] setDatastore:self.datastore];
                [[imGrupoMesadeiros grupo] converteMesadeiros];
                
                [defaults setObject:self.datastore.datastoreId forKey:@"dataStoreID"];
                [defaults synchronize];
                NSLog(@"%@", self.datastore.datastoreId );
            }else{
                // Use Dropbox datastores
                [DBDatastoreManager setSharedManager:[DBDatastoreManager managerForAccount:account]];
                self.datastore = [[DBDatastoreManager sharedManager] openDatastore:dataStoreID error:nil];
                [[imGrupoMesadeiros grupo] setDatastore:self.datastore];
                NSLog(@"%@", dataStoreID);
            }

            
            [[imGrupoMesadeiros grupo] carregaArray];
            
            UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
            [tabBar setSelectedIndex:0];
            

            return YES;
        }
    } else if ([action isEqualToString:@"cancel"]) {
        // Do nothing if user cancels login
    } else {
        // Shared datastore -- Lists://
        NSString *datastoreId = [url host];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:datastoreId forKey:@"dataStoreID"];
        [defaults synchronize];

        NSLog(@"Opening datastore ID: %@", datastoreId);
        
        // Return to root view controller
        //   UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        //   [navigationController popToRootViewControllerAnimated:NO];
        UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
        [tabBar setSelectedIndex:3];
        
        DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
        
        if (account) {
            // Go to the shared list (will open the list)
            if ([DBDatastore isValidShareableId:datastoreId]) {
                
                NSLog(@"Recebeu o link para linkar");
                UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
                [tabBar setSelectedIndex:0];
                //          DBListViewController *viewController = (DBListViewController *)[navigationController.storyboard instantiateViewControllerWithIdentifier:@"DBListViewController"];
                //        viewController.datastoreId = datastoreId;
                
                //      [navigationController pushViewController:viewController animated:NO];
            } else {
                // Notify user that this isn't a valid link
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                                message:@"Invalid List link."
                                                               delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
                [alert show];
            }
        } else {
            // Notify user to link with Dropbox
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Link to Dropbox"
                                                            message:@"To accept a shared list you'll need to link to Dropbox first."
                                                           delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            [alert show];
        }
        
        return YES;
    }
    
    return NO;
}


-(void)cycleTheGlobalMailComposer
{
    // we are cycling the damned GlobalMailComposer... due to horrible iOS issue
    self.globalMailComposer = nil;
    self.globalMailComposer = [[MFMailComposeViewController alloc] init];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    [[NSNotificationCenter defaultCenter] postNotificationName:@"appativa" object:nil userInfo:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
