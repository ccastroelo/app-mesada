//
//  imMesTableVC.m
//  mesada
//
//  Created by claudio on 11/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//



#import "imMesTableVC.h"
#import "imGrupoMesadeiros.h"
#import "imMesadeiro.h"
#import "imLanVC.h"
#import "imGrupoLancamentos.h"
#import "imMesViewCell.h"
#import "imLoginVC.h"
#import "SFHFKeychainUtils.h"
#import "imMesCadVC.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "imAppDelegate.h"
#import <Dropbox/Dropbox.h>



@interface imMesTableVC ()

@property (strong, nonatomic) NSNumberFormatter *numberFormater;
@property (nonatomic) int idMesadeiroZerarLancamento;
@property (nonatomic, strong) DBDatastore *datastore;

@end

@implementation imMesTableVC 


- (void)pedirSenha: (NSNotification *) notification{
    NSError *error;
    id password = [SFHFKeychainUtils getPasswordForUsername:@"br.eti.claudiocastro.mesada" andServiceName:@"senha2" error:&error];
    if(password){
        [self performSelector:@selector(chamaSenha) withObject:nil afterDelay:0.1];
    }

}
- (void) chamaSenha
{
    imLoginVC *myNewVC = [[imLoginVC alloc] init];
    
    // do any setup you need for myNewVC
    [self presentViewController:myNewVC animated:YES completion: nil];
}



- (void)deletePList {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"mesadeiros.plist"];
    
    NSError *error;
    if(![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
    {
   //     NSLog(@"houve um erro 1");
    }
    NSString *path2 = [documentsDirectory stringByAppendingPathComponent:@"faltas.plist"];
    
    NSError *error2;
    if(![[NSFileManager defaultManager] removeItemAtPath:path2 error:&error2])
    {
   //     NSLog(@"houve um erro 2");
    }

    NSString *path3 = [documentsDirectory stringByAppendingPathComponent:@"lancamentos.plist"];
    
    NSError *error3;
    if(![[NSFileManager defaultManager] removeItemAtPath:path3 error:&error3])
    {
   //     NSLog(@"houve um erro 3");
    }

    
    
}


#pragma mark -
#pragma mark ViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.datastore = [[imGrupoMesadeiros grupo] datastore];
    [[imGrupoMesadeiros grupo] carregaArray];
    
   // [self deletePList];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.numberFormater = [[NSNumberFormatter alloc] init];
    [self.numberFormater setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.numberFormater.currencySymbol = [NSString stringWithFormat: @"%@ ", self.numberFormater.currencySymbol];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(pedirSenha:) name:@"appativa" object: nil];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.allowsSelectionDuringEditing = YES;

    
}

-(void)viewDidAppear:(BOOL)animated{
    if ([self dataStoreID]){
        // Observe changes to datastore (possibly from other devices)
        __weak typeof(self) weakSelf = self;
        [self.datastore addObserver:self block:^() {
            if (weakSelf.datastore.status.incoming) {
                // Sync with updated data and reload
                [weakSelf.datastore sync:nil];
                [weakSelf.tableView reloadData];
                
                // Update title if needed
              //  weakSelf.title = weakSelf.datastore.title;
            }
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Stop listening for changes to the datastores
    if ([self dataStoreID]){
        [[DBDatastoreManager sharedManager] removeObserver:self];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [[self tableView] reloadData];
    [super viewWillAppear:YES];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[imGrupoMesadeiros grupo] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    imMesViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	imMesadeiro *itemLista = [[imGrupoMesadeiros grupo] objectAtIndex:indexPath.row];
	cell.txtNome.text = itemLista.nome;
	cell.txtMesada.text = [NSString stringWithFormat:NSLocalizedString(@"Mesada: %@", @"Mesada"), [self.numberFormater stringFromNumber:[NSNumber numberWithFloat: itemLista.valorMesadaInicial]]];
    cell.txtSaldo.text =  [NSString stringWithFormat:NSLocalizedString(@"Saldo: %@", @"Saldo"), [self.numberFormater stringFromNumber:[NSNumber numberWithFloat: [itemLista saldo]]]];
    cell.foto.image = itemLista.foto;
    cell.idMesadeiro = itemLista.idMesadeiro;
    cell.delegate = self;
    cell.tag = indexPath.row;
    
    

    return cell;
}


/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
*/
//



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSInteger indice = [indexPath row];
        [[imGrupoMesadeiros grupo] removeObjectAtIndex:indice];
        [[imGrupoMesadeiros grupo] save];
        
        //  Animate deletion
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [[self tableView] deleteRowsAtIndexPaths:indexPaths
                                withRowAnimation:UITableViewRowAnimationFade];
       
    }
}


- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toIndexPath:(NSIndexPath *)targetIndexPath
{
    NSUInteger sourceIndex = [sourceIndexPath row];
    NSUInteger targetIndex = [targetIndexPath row];
    
    if (sourceIndex != targetIndex)
    {
        [[imGrupoMesadeiros grupo] exchangeObjectAtIndex:sourceIndex
                                     withObjectAtIndex:targetIndex];
        [[imGrupoMesadeiros grupo] save];
    }
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if([[segue identifier] isEqualToString:@"lancamento"]){
            [[segue destinationViewController] setMesadeiro:[[imGrupoMesadeiros grupo] objectAtIndex:indexPath.row]];
    }else{
        [segue destinationViewController];
    }
    // Pass the selected object to the new view controller.
}


#pragma mark viewcelldelegate

- (void)tableView:(UITableView *)tableView editOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath
{
    imMesCadVC *myNewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"cadMesadeiro"];
    [myNewVC setMesadeiro:[[imGrupoMesadeiros grupo] objectAtIndex:indexPath.row]];
    [self presentViewController:myNewVC animated:YES completion: nil];
    // do any setup you need for myNewVC
}


- (void)tableView:(UITableView *)tableView configOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath
{
    int idMesadeiro = [[imGrupoMesadeiros grupo] objectAtIndex:indexPath.row].idMesadeiro;
    NSString *titulo = [NSString stringWithFormat:@"%@", [[imGrupoMesadeiros grupo] objetoComId:idMesadeiro].nome];
    self.idMesadeiroZerarLancamento = idMesadeiro;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titulo message:NSLocalizedString(@"Zerar lançamentos para essa mesada?", @"Zerar lançamentos para essa mesada?") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancelar", @"Cancelar") otherButtonTitles: @"OK", NSLocalizedString(@"Zerar todas Mesadas", @"Zerar todas Mesadas"), nil];
    alert.tag = 1;
    [self setEditing:NO animated:YES];
    [alert show];
}

- (void)tableView:(UITableView *)tableView mailOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath
{
    int idMesadeiro = [[imGrupoMesadeiros grupo] objectAtIndex:indexPath.row].idMesadeiro;
    imMesadeiro *mesadeiro = [[imGrupoMesadeiros grupo] objetoComId:idMesadeiro];
    NSString *body = [[imGrupoLancamentos grupo] montaEmailParaMesadeiro:idMesadeiro];

    NSString *toAddress = mesadeiro.email;
    APP.globalMailComposer.mailComposeDelegate = self;
    if ( [MFMailComposeViewController canSendMail] ) {
        [APP.globalMailComposer setToRecipients:[NSArray arrayWithObjects:toAddress,nil]];
        [APP.globalMailComposer setSubject:NSLocalizedString(@"Mesada", @"Mesada")];
        [APP.globalMailComposer setMessageBody:body isHTML:YES];
        [self presentViewController:APP.globalMailComposer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro" message:NSLocalizedString(@"Não é possível enviar email deste dispositivo", @"Não é possível enviar email deste dispositivo") delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        [APP cycleTheGlobalMailComposer];
    }
}

- (void)tableView:(UITableView *)tableView deleteOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
}

- (void) alertView: (UIAlertView*) alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            [[imGrupoLancamentos grupo] zeraLancamentosParaMesadeiro:self.idMesadeiroZerarLancamento];
        }
        if (buttonIndex == 2) {
            [[imGrupoLancamentos grupo] zeraTodosLancamentos];
        }
        [[self tableView] reloadData];
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:^{
        [APP cycleTheGlobalMailComposer];
    }];
    
}

-(NSString *)dataStoreID{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *dataStoreID = [defaults objectForKey:@"dataStoreID"];
    return dataStoreID;
}

/*- (DBDatastore *)datastore{
    if (!_datastore){
        _datastore = [[DBDatastoreManager sharedManager] openDatastore:[self dataStoreID] error:nil];
        [_datastore sync:nil];
    }
    return _datastore;
}*/

@end
