//
//  imGrupoLancamentos.m
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imGrupoLancamentos.h"
#import "imLancamento.h"
#import "imGrupoFaltas.h"
#import "imGrupoMesadeiros.h"
#import "imFalta.h"
#import "imMesadeiro.h"

@interface imGrupoLancamentos()

@end

@implementation imGrupoLancamentos


+ (imGrupoLancamentos *) grupo
{
    static imGrupoLancamentos *grupo = nil;
    if (!grupo) {
        grupo = [[super allocWithZone:nil] init];
    }
    return grupo;
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    return [self grupo];
}

#pragma mark lazy


- (NSMutableArray *)arrayObjeto
{
    if (!_arrayObjeto)
    {
        NSString *path = [[self class] pathForDocumentWithName:@"lancamentos.plist"];
        NSArray *objetoDicts = [NSMutableArray arrayWithContentsOfFile:path];
        
        if (!objetoDicts)
        {
            path = [[NSBundle mainBundle] pathForResource:@"lancamentos"
                                                   ofType:@"plist"];
            objetoDicts = [NSMutableArray arrayWithContentsOfFile:path];
        }
        
        _arrayObjeto = [[NSMutableArray alloc]
                        initWithCapacity:[objetoDicts count]];
        
        for (NSDictionary *currDict in objetoDicts)
        {
            imLancamento *objeto = [[imLancamento alloc] initWithDictionary:currDict];
            [_arrayObjeto addObject:objeto];
        }
    }
    return _arrayObjeto;
}


#pragma mark arrayfunction

- (void)atualiza
{
    [_arrayObjeto removeAllObjects];
    NSString *path = [[self class] pathForDocumentWithName:@"lancamentos.plist"];
    NSArray *objetoDicts = [NSMutableArray arrayWithContentsOfFile:path];
    
    if (!objetoDicts)
    {
        path = [[NSBundle mainBundle] pathForResource:@"lancamentos"
                                               ofType:@"plist"];
        objetoDicts = [NSMutableArray arrayWithContentsOfFile:path];
    }
    
    _arrayObjeto = [[NSMutableArray alloc]
                    initWithCapacity:[objetoDicts count]];
    
    for (NSDictionary *currDict in objetoDicts)
    {
        imLancamento *objeto = [[imLancamento alloc] initWithDictionary:currDict];
        [_arrayObjeto addObject:objeto];
    }
    
}


- (void)zeraTodosLancamentos
{
    for (imLancamento *objeto in self.arrayObjeto) {
        objeto.quantidade = 0;
    }
    [self save];

}

- (void)zeraLancamentosParaMesadeiro:(int)idMesadeiro
{
    for (imLancamento *objeto in self.arrayObjeto) {
        if (objeto.idMesadeiro == idMesadeiro) {
            objeto.quantidade = 0;
        }
    }
    [self save];
}


- (void)criaLancamentosParaMesadeiro: (int) idMesadeiro
{
    for (imFalta *objeto in [imGrupoFaltas grupo].arrayObjeto) {
        imLancamento *lancamento = [[imLancamento alloc] init];
        lancamento.idMesadeiro = idMesadeiro;
        lancamento.idFalta = objeto.idFalta;
        lancamento.idLancamento = [self maiorId]+1;
        [self.arrayObjeto addObject:lancamento];
    }
    [self save];
}
- (void)criaLancamentosParaFalta: (int) idFalta
{
    for (imMesadeiro *objeto in [imGrupoMesadeiros grupo].arrayObjeto) {
        imLancamento *lancamento = [[imLancamento alloc] init];
        lancamento.idMesadeiro = objeto.idMesadeiro;
        lancamento.idFalta = idFalta;
        lancamento.idLancamento = [self maiorId]+1;
        [self.arrayObjeto addObject:lancamento];
    }
    [self save];
}
- (void)deletaLancamentosParaMesadeiro: (int) idMesadeiro
{
    for (imLancamento *objeto in [self.arrayObjeto copy]) {
        if (objeto.idMesadeiro == idMesadeiro) {
            [self.arrayObjeto removeObject:objeto];
        }
    }
    [self save];
}
- (void)deletaLancamentosParaFalta: (int) idFalta
{
    for (imLancamento *objeto in [self.arrayObjeto copy]) {
        if (objeto.idFalta == idFalta) {
            [self.arrayObjeto removeObject:objeto];
        }
    }
    [self save];
}


- (imLancamento *)objectAtIndex: (NSUInteger)targetIndex withMesadeiro: (int)idMesadeiro
{
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"SELF.idMesadeiro == %d", idMesadeiro];
    NSArray *arrayFiltrado = [self.arrayObjeto filteredArrayUsingPredicate:predicate];
    return [arrayFiltrado objectAtIndex:targetIndex];
}

- (imLancamento *)objectAtIndex:(NSUInteger)targetIndex
{
    return [self.arrayObjeto objectAtIndex:targetIndex];
}

-(int)maiorId
{
    int idmax = 0;
    for(imLancamento *objeto in self.arrayObjeto){
        if(objeto.idLancamento > idmax){
            idmax = objeto.idLancamento;
        }
    }
    return idmax;

}



- (NSUInteger)countWithMesadeiro: (int)idMesadeiro
{
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"SELF.idMesadeiro == %d", idMesadeiro];
    NSArray *arrayFiltrado = [[self.arrayObjeto copy]filteredArrayUsingPredicate:predicate];
    return [arrayFiltrado count];
}

- (NSUInteger)count
{
    return [self.arrayObjeto count];
}

- (void)removeObject:(id)targetObject
{
    NSInteger targetIndex=[self.arrayObjeto indexOfObjectIdenticalTo:targetObject];
    [self.arrayObjeto removeObjectAtIndex:targetIndex];
    [self save];
}


- (void)removeObjectAtIndex:(NSUInteger)targetIndex
{
    [self.arrayObjeto removeObjectAtIndex:targetIndex];
}

- (void)exchangeObjectAtIndex:(NSUInteger)sourceIndex withObjectAtIndex:(NSUInteger)targetIndex
{
    [self.arrayObjeto exchangeObjectAtIndex:sourceIndex
                          withObjectAtIndex:targetIndex];
  //  [self save];
}

- (void)exchangeObject:(id)sourceObject withObject:(id)targetObject
{
    NSInteger sourceIndex=[self.arrayObjeto indexOfObjectIdenticalTo:sourceObject];
    NSInteger targetIndex=[self.arrayObjeto indexOfObjectIdenticalTo:targetObject];
    [self removeMoveObjectAtIndex:sourceIndex];
    [self addMoveObject:sourceObject AtIndex:targetIndex];
//    [self.arrayObjeto exchangeObjectAtIndex:sourceIndex
//                          withObjectAtIndex:targetIndex];
    [self save];
}


+ (NSString *)pathForDocumentWithName:(NSString *)documentName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *path = [paths objectAtIndex:0];
    
    return [path stringByAppendingPathComponent:documentName];
}

- (float)saldoParaMesadeiro:(int)idMesadeiro
{
    float resultado = 0.0;
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"SELF.idMesadeiro == %d", idMesadeiro];
    NSArray *arrayFiltrado = [[self.arrayObjeto copy]filteredArrayUsingPredicate:predicate];
    for(imLancamento *lancamento in arrayFiltrado){
        resultado = resultado + (lancamento.quantidade * [[imGrupoFaltas grupo] objetoComId:lancamento.idFalta].valor);
    }
    return resultado;
}


- (void)save
{
    NSMutableArray *objetoDicts = [NSMutableArray arrayWithCapacity:[self.arrayObjeto count]];
    
    // Convert the array of books into an array of dictionaries for storage
    // in text plist format.
    //
    for (id currObj in self.arrayObjeto)
    {
        [objetoDicts addObject:[currObj dictionaryWithValuesForKeys:[imLancamento keys]]];
    }
    
    NSString *plist = [objetoDicts description];
    NSString *path = [[self class] pathForDocumentWithName:@"lancamentos.plist"];
    
    NSError *error = nil;
    [plist writeToFile:path
            atomically:YES
              encoding:NSUTF8StringEncoding
                 error:&error];
    if (error)
    {
        NSLog(@"Error writing file at path: %@; error was %@", path, error);
    }
}

- (NSString *)montaEmailParaMesadeiro:(int)idMesadeiro
{
     NSNumberFormatter *numberFormater = [[NSNumberFormatter alloc] init];
    [numberFormater setNumberStyle:NSNumberFormatterCurrencyStyle];
    numberFormater.currencySymbol = [NSString stringWithFormat: @"%@ ", numberFormater.currencySymbol];
    imMesadeiro *mesadeiro = [[imGrupoMesadeiros grupo] objetoComId:idMesadeiro];
    
    NSString *cabe = [NSString stringWithFormat:@"%@<br>%@ %@<br>%@ %@ <br><br><table border=1><tr><td>Regra</td><td>Qtd</td><td>Valor</td></tr>",
                      mesadeiro.nome,
                      NSLocalizedString(@"Mesada:", @"Mesada:"),
                      [numberFormater stringFromNumber:[NSNumber numberWithFloat: mesadeiro.valorMesadaInicial]],
                      NSLocalizedString(@"Saldo:", @"Saldo:"),
                      [numberFormater stringFromNumber:[NSNumber numberWithFloat: [mesadeiro saldo]]]];
    
    NSMutableArray *bodyLinha = [[NSMutableArray alloc] init];
    [bodyLinha addObject:cabe];
    
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"SELF.idMesadeiro == %d", idMesadeiro];
    NSArray *arrayFiltrado = [[imGrupoLancamentos grupo].arrayObjeto filteredArrayUsingPredicate:predicate];
    
    for(imLancamento *lancamento in arrayFiltrado){
        imFalta *falta = [[imGrupoFaltas grupo] objetoComId:lancamento.idFalta];
        NSString *meio = [NSString stringWithFormat:@"<tr><td>%@ (%@)</td><td>%d</td><td>%@</td></tr>",
            falta.descricao,
            [numberFormater stringFromNumber:[NSNumber numberWithFloat: falta.valor]],
            lancamento.quantidade,
            [numberFormater stringFromNumber:[NSNumber numberWithFloat: (lancamento.quantidade * falta.valor)]]];
            [bodyLinha addObject:meio];
    }
    
    NSString *body = [bodyLinha componentsJoinedByString:@""];
    return  body;
}

- (void) chamaAtualizacao
{
    [[imGrupoFaltas grupo] atualizacaoFaltas];
}

- (void)removeMoveObjectAtIndex:(NSUInteger)targetIndex{
    [self.arrayObjeto removeObjectAtIndex:targetIndex];
}

- (void)addMoveObject:(id)anObject AtIndex:(NSUInteger)targetIndex{
    if (anObject != nil)
    {
        [self.arrayObjeto insertObject:anObject atIndex:targetIndex];
    }
}


@end
