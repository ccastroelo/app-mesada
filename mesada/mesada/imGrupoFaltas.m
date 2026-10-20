//
//  imGrupoFaltas.m
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//


#import "imGrupoFaltas.h"
#import "imFalta.h"
#import "imGrupoLancamentos.h"
#import <Dropbox/Dropbox.h>

@interface imGrupoFaltas()

@end

bool carregaArray2 = NO;

@implementation imGrupoFaltas

+ (imGrupoFaltas *) grupo
{
    static imGrupoFaltas *grupo = nil;
    if (!grupo) {
        grupo = [[super allocWithZone:nil] init];
    }
    return grupo;
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    return [self grupo];
}




- (imFalta *) objetoComId: (int) idObjeto
{
    imFalta *falta;
    for (imFalta *objeto in self.arrayObjeto) {
        if(objeto.idFalta == idObjeto){
            falta = objeto;
            break;
        }
    }
    return falta;
}


- (imFalta *)objectAtIndex:(NSUInteger)targetIndex
{
    return [self.arrayObjeto objectAtIndex:targetIndex];
}

-(int)maiorId
{
    int idmax = 0;
    for(imFalta *objeto in self.arrayObjeto){
        if(objeto.idFalta > idmax){
            idmax = objeto.idFalta;
        }
    }
    return idmax;
}

- (NSUInteger)count
{
    return [self.arrayObjeto count];
}

- (void)removeObjectAtIndex:(NSUInteger)targetIndex
{
    [[imGrupoLancamentos grupo] deletaLancamentosParaFalta:[self objectAtIndex:targetIndex].idFalta];
    if ([self dataStoreID]){
        imFalta *falta = [self.arrayObjeto objectAtIndex:targetIndex];
        [self dropBoxRemoveFaltas:falta];
    }
    [self.arrayObjeto removeObjectAtIndex:targetIndex];
}

- (void)exchangeObjectAtIndex:(NSUInteger)sourceIndex withObjectAtIndex:(NSUInteger)targetIndex
{
    [self.arrayObjeto exchangeObjectAtIndex:sourceIndex
                              withObjectAtIndex:targetIndex];
}

+ (NSString *)pathForDocumentWithName:(NSString *)documentName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *path = [paths objectAtIndex:0];
    
    return [path stringByAppendingPathComponent:documentName];
}

- (NSMutableArray *)arrayObjeto
{
    if (!_arrayObjeto || carregaArray2)
    {
        if (carregaArray2) {
            [self limpaArrayLocal];
        }
        if ([self dataStoreID]) {
            DBTable *faltas = [self.datastore getTable:@"faltas"];
            NSArray *arrayAux = [faltas query:nil error:nil];
            _arrayObjeto = [[NSMutableArray alloc]
                            initWithCapacity:[arrayAux count]];
            
            for (DBRecord *record in arrayAux) {
                [_arrayObjeto addObject:[self converteRecordToFalta:record]];
            }
        }else{
            
            NSString *path = [[self class] pathForDocumentWithName:@"faltas.plist"];
            NSArray *objetoDicts = [NSMutableArray arrayWithContentsOfFile:path];
            
            if (!objetoDicts)
            {
                path = [[NSBundle mainBundle] pathForResource:@"faltas"
                                                       ofType:@"plist"];
                objetoDicts = [NSMutableArray arrayWithContentsOfFile:path];
            }
            
            _arrayObjeto = [[NSMutableArray alloc]
                            initWithCapacity:[objetoDicts count]];
            
            for (NSDictionary *currDict in objetoDicts)
            {
                imFalta *objeto = [[imFalta alloc] initWithDictionary:currDict];
                [_arrayObjeto addObject:objeto];
            }
        }
    }
    return _arrayObjeto;
}

- (void)addObject:(imFalta *)anObject
{
    if (anObject != nil)
    {
        [self.arrayObjeto addObject:anObject];
        if ([self dataStoreID]) {
            [self dropBoxAddFaltas:anObject];
        }
        // TODO
        [[imGrupoLancamentos grupo] criaLancamentosParaFalta:anObject.idFalta];
    }
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

- (void)atualizacaoFaltas
{
    // metodo feito apenas para corrigir a atualização da plist
    
    NSMutableArray *objetoDicts = [NSMutableArray arrayWithCapacity:[self.arrayObjeto count]];
    
    // Convert the array of books into an array of dictionaries for storage
    // in text plist format.
    //
    for (imFalta *currObj in self.arrayObjeto)
    {
        currObj.valor = currObj.valor * -1;
        [objetoDicts addObject:[currObj dictionaryWithValuesForKeys:[imFalta keys]]];
    }
    
    NSString *plist = [objetoDicts description];
    NSString *path = [[self class] pathForDocumentWithName:@"faltas.plist"];
    
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

- (void)save
{
    [self bloqueiaArray];
    if ([self dataStoreID]) {
        for (imFalta *currObj in self.arrayObjeto){
            DBRecord *record = [self localizaRecordDaFalta:currObj];
            record[@"descricao"] = currObj.descricao;
            record[@"valor"] = [NSNumber numberWithFloat: currObj.valor];
            [self.datastore sync:nil];
        }
    }else{
        NSMutableArray *objetoDicts = [NSMutableArray arrayWithCapacity:[self.arrayObjeto count]];
        
        // Convert the array of books into an array of dictionaries for storage
        // in text plist format.
        //
        for (id currObj in self.arrayObjeto)
        {
            [objetoDicts addObject:[currObj dictionaryWithValuesForKeys:[imFalta keys]]];
        }
        
        NSString *plist = [objetoDicts description];
        NSString *path = [[self class] pathForDocumentWithName:@"faltas.plist"];
        
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
}


- (void)limpaArrayLocal{
    [_arrayObjeto removeAllObjects];
    _arrayObjeto = nil;
}

- (void)converteFaltas{
    for (imFalta *objeto in self.arrayObjeto) {
        //
        [self dropBoxAddFaltas:objeto];
        //
        
    }
    
}

-(imFalta *)converteRecordToFalta:(DBRecord *)dpFalta{
    
    imFalta *falta = [[imFalta alloc] init];
    
    // TODO dropbox
    falta.descricao = dpFalta[@"descricao"];
    
    falta.idFalta = [dpFalta[@"idFalta"] intValue];
    
    falta.valor = [dpFalta[@"valor"] floatValue];
    
    return falta;
}

-(void)dropBoxRemoveFaltas:(imFalta *)falta{
    DBRecord *record = [self localizaRecordDaFalta:falta];
    [record deleteRecord];
    [self.datastore sync:nil];
}


-(void)dropBoxAddFaltas:(imFalta *)falta{
    DBTable *faltas = [self.datastore getTable:@"faltas"];
    // TODO dropbox
    [faltas insert:@{ @"ID": [NSString stringWithFormat:@"fal%d", falta.idFalta], @"idFalta": [NSNumber numberWithInt: falta.idFalta], @"descricao": falta.descricao, @"valor": [NSNumber numberWithFloat: falta.valor] }];
    [self.datastore sync:nil];
}

-(DBRecord *)localizaRecordDaFalta:(imFalta *)falta{
    DBTable *faltas = [self.datastore getTable:@"faltas"];
    NSArray *results = [faltas query:@{ @"idFalta": [NSNumber numberWithInt: falta.idFalta]} error:nil];
    DBRecord *firstResult = [results objectAtIndex:0];
    return firstResult;
}


- (DBDatastore *)datastore{
    if (!_datastore){
        _datastore = [[DBDatastoreManager sharedManager] openDatastore:[self dataStoreID] error:nil];
        [_datastore sync:nil];
    }
    return _datastore;
}

-(void)syncArrayObject{
    [self.arrayObjeto removeAllObjects];
    self.arrayObjeto = nil;
}

-(NSString *)dataStoreID{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *dataStoreID = [defaults objectForKey:@"dataStoreID"];
    return dataStoreID;
}

- (void) carregaArray{
    carregaArray2 = YES;
}

- (void) bloqueiaArray{
    carregaArray2 = NO;
}

@end
