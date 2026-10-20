//
//  imLanVC.m
//  mesada
//
//  Created by claudio on 18/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imLanVC.h"
#import "imGrupoLancamentos.h"
#import "imLancamento.h"
#import "imLanViewCell.h"
#import "imGrupoFaltas.h"
#import "AudioToolbox/AudioServices.h"

@interface imLanVC ()

@property (strong, nonatomic) NSNumberFormatter *numberFormater;
@property (nonatomic) NSInteger numeroDeLinhasNaSecao;

@end

@implementation imLanVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Editar", @"Editar");
    
    
    self.numberFormater = [[NSNumberFormatter alloc] init];
    [self.numberFormater setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.numberFormater.currencySymbol = [NSString stringWithFormat: @"%@ ", self.numberFormater.currencySymbol];

    self.nome.text = self.mesadeiro.nome;
    self.mesada.text = [NSString stringWithFormat:NSLocalizedString(@"Mesada: %@", @"Mesada"), [self.numberFormater stringFromNumber:[NSNumber numberWithFloat: self.mesadeiro.valorMesadaInicial]]  ];
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"clique" ofType:@"aiff"];
    CFURLRef soundURL = (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(soundURL, &sons[0]);
    
    
}



- (void) viewWillDisappear:(BOOL)animated
{
    [[imGrupoLancamentos grupo] save];
    [super viewWillDisappear:YES];
}
- (void) viewWillAppear:(BOOL)animated
{
    [[self tableView] reloadData];
    self.saldo.text = [NSString stringWithFormat:NSLocalizedString(@"Saldo: %@", @"Saldo"), [self.numberFormater stringFromNumber:[NSNumber numberWithFloat: [self.mesadeiro saldo]]]];
    [super viewWillAppear:YES];
}


#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath*)indexPath {
    CGFloat result;
    if (indexPath.row == 0 || indexPath.row == (self.numeroDeLinhasNaSecao-1)) {
        result = 27;
    } else {
        result = 64;
    }
    return result;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.numeroDeLinhasNaSecao = [[imGrupoLancamentos grupo] countWithMesadeiro:self.mesadeiro.idMesadeiro] + 2;
    return self.numeroDeLinhasNaSecao;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int feedIndex = (int)indexPath.row;
    if(feedIndex == 0 || feedIndex == (self.numeroDeLinhasNaSecao-1)) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellSetas"];
        cell.tag = 0;
        return cell;
    }else{
        imLanViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        imLancamento *itemLista = [[imGrupoLancamentos grupo] objectAtIndex:feedIndex-1 withMesadeiro:self.mesadeiro.idMesadeiro];
        imFalta *falta = [[imGrupoFaltas grupo] objetoComId:itemLista.idFalta];
        cell.descricao.text = falta.descricao;
        cell.quantidade.text = [NSString stringWithFormat:@"%d",itemLista.quantidade];
        if (falta.valor <= 0) {
            cell.desconto.text = [NSString stringWithFormat:NSLocalizedString(@"Desconto: %@", @"Desconto"), [self.numberFormater stringFromNumber:[NSNumber numberWithFloat: falta.valor]]];
        }else{
            cell.desconto.text = [NSString stringWithFormat:NSLocalizedString(@"Recompensa: %@", @"Recompensa"), [self.numberFormater stringFromNumber:[NSNumber numberWithFloat: falta.valor]]];
        }
        // Configure the cell...
//        cell.quantidade.hidden = NO;
        cell.tag = 1;
        return cell;
    }
}


#pragma mark actions

- (IBAction)leftSwipe:(UISwipeGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    imLancamento *lancamento = [[imGrupoLancamentos grupo] objectAtIndex:indexPath.row-1 withMesadeiro:self.mesadeiro.idMesadeiro];
    int qtd = lancamento.quantidade;
    if(qtd > 0){
        AudioServicesPlaySystemSound(sons[0]);
        [UIView animateWithDuration:1.0 animations:^{ cell.backgroundColor = [UIColor redColor]; } completion:^(BOOL finished){
            [UIView animateWithDuration:0.2 animations:^{ cell.backgroundColor = [UIColor whiteColor]; } completion:nil];
        }];
        lancamento.quantidade = qtd - 1;
        [[self tableView] reloadData];
    }
    [[imGrupoLancamentos grupo] save];
    self.saldo.text = [NSString stringWithFormat:NSLocalizedString(@"Saldo: %@", @"Saldo"), [self.numberFormater stringFromNumber:[NSNumber numberWithFloat: [self.mesadeiro saldo]]]];
}

- (IBAction)rightSwipe:(UISwipeGestureRecognizer *)sender {
    AudioServicesPlaySystemSound(sons[0]);
    CGPoint location = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:1.0 animations:^{ cell.backgroundColor = [UIColor greenColor]; } completion:^(BOOL finished){
        [UIView animateWithDuration:0.2 animations:^{ cell.backgroundColor = [UIColor whiteColor]; } completion:nil];
    }];

    imLancamento *lancamento = [[imGrupoLancamentos grupo] objectAtIndex:indexPath.row-1 withMesadeiro:self.mesadeiro.idMesadeiro];
    int qtd = lancamento.quantidade;
    lancamento.quantidade = qtd + 1;
    [[self tableView] reloadData];
    [[imGrupoLancamentos grupo] save];
    self.saldo.text = [NSString stringWithFormat:NSLocalizedString(@"Saldo: %@", @"Saldo"), [self.numberFormater stringFromNumber:[NSNumber numberWithFloat: [self.mesadeiro saldo]]]];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
/*    if ([self celulaNormal:indexPath]) {
        imLanViewCell *cell = (imLanViewCell *)[self.tableView cellForRowAtIndexPath: indexPath];
        if (self.tableView.editing) {
            cell.quantidade.hidden = YES;
        }
    } */
    return [self celulaNormal:indexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
                                                toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSLog(@"%ld, %ld", (long)sourceIndexPath.row, (long)destinationIndexPath.row);
    if ([self celulaNormal:sourceIndexPath] && [self celulaNormal:destinationIndexPath]) {
        NSLog(@"%ld, %ld", (long)sourceIndexPath.row, (long)destinationIndexPath.row);
        imLancamento *sourceObject = [[imGrupoLancamentos grupo] objectAtIndex:sourceIndexPath.row-1 withMesadeiro:self.mesadeiro.idMesadeiro];
        imLancamento *targetObject = [[imGrupoLancamentos grupo] objectAtIndex:destinationIndexPath.row-1 withMesadeiro:self.mesadeiro.idMesadeiro];
        [[imGrupoLancamentos grupo] exchangeObject:sourceObject withObject:targetObject];
    }else{
            [self.tableView endUpdates];
            [self.tableView setEditing:NO animated:YES];
            self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Editar", @"Editar");
            [self.tableView reloadData];
    }

}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self celulaNormal:indexPath] && tableView.editing;
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    if (self.tableView.editing) {
        [self.tableView setEditing:!editing animated:animated];
        [[imGrupoLancamentos grupo] save];
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Editar", @"Editar");
    }else{
        [self.tableView setEditing:editing animated:animated];
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done", @"Done");
    }
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        imLancamento *targetObject = [[imGrupoLancamentos grupo] objectAtIndex:indexPath.row-1 withMesadeiro:self.mesadeiro.idMesadeiro];
        
        [[imGrupoLancamentos grupo] removeObject:targetObject];
        
        //  Animate deletion
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [[self tableView] deleteRowsAtIndexPaths:indexPaths
                                withRowAnimation:UITableViewRowAnimationFade];
    }
}

/*-(void)ativaQuantidade{
    if (!self.tableView.editing) {
        for (int i = 0; i < self.numeroDeLinhasNaSecao; i++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            if ([self celulaNormal:indexPath]) {
                imLanViewCell *cell = (imLanViewCell *)[self.tableView cellForRowAtIndexPath: indexPath];
                cell.quantidade.hidden = NO;
            }
        }
    }
}

-(void)endUpdates{

}*/


-(bool)celulaNormal:(NSIndexPath *)indexPath{
    return !(indexPath.row == 0 || indexPath.row == (self.numeroDeLinhasNaSecao-1));
}

@end
