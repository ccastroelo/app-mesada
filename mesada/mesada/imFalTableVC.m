//
//  imFalTableVC.m
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imFalTableVC.h"
#import "imGrupoFaltas.h"
#import "imFalta.h"
#import "imFalViewCell.h"
#import "imFalCadVC.h"


@interface imFalTableVC ()

@property (strong, nonatomic) NSNumberFormatter *numberFormater;

@end

@implementation imFalTableVC

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

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.numberFormater = [[NSNumberFormatter alloc] init];
    [self.numberFormater setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *cifrao = [NSString stringWithFormat: @"%@ ", self.numberFormater.currencySymbol];
    self.numberFormater.currencySymbol = cifrao;

}
- (void)viewWillDisappear:(BOOL)animated
{
    [[imGrupoFaltas grupo] save];
    [super viewWillDisappear:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self tableView] reloadData];
    [super viewWillAppear:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     return [[imGrupoFaltas grupo] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    imFalViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"faltaCell"];
	imFalta *itemLista = [[imGrupoFaltas grupo] objectAtIndex:indexPath.row];
	cell.regraLabel.text = itemLista.descricao;
    if (itemLista.valor <= 0) {
        	cell.detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Desconto: %@",@"tipo"), [self.numberFormater stringFromNumber:[NSNumber numberWithFloat: itemLista.valor]]];
    }else{
        	cell.detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Recompensa: %@",@"tipo"), [self.numberFormater stringFromNumber:[NSNumber numberWithFloat: itemLista.valor]]];
    }
    cell.idFalta = itemLista.idFalta;
    return cell;

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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
        [[imGrupoFaltas grupo] removeObjectAtIndex:[indexPath row]];
        
        //  Animate deletion
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [[self tableView] deleteRowsAtIndexPaths:indexPaths
                                withRowAnimation:UITableViewRowAnimationFade];
    }
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    imFalta *itemLista = [[imGrupoFaltas grupo] objectAtIndex:sourceIndexPath.row];
    [[imGrupoFaltas grupo] removeMoveObjectAtIndex:sourceIndexPath.row];
    [[imGrupoFaltas grupo] addMoveObject:itemLista AtIndex:destinationIndexPath.row];
//    [[imGrupoFaltas grupo] exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if([[segue identifier] isEqualToString:@"alteracao"]){
        [[segue destinationViewController] setFalta:[[imGrupoFaltas grupo] objectAtIndex:indexPath.row]];
    }else{
        [[segue destinationViewController] setFalta:nil];
    }
    // Pass the selected object to the new view controller.
}



@end
