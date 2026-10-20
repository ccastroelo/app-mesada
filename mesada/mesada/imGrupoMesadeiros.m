//
//  imGrupoMesadeiros.m
//  mesada
//
//  Created by claudio on 11/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//


#import "imGrupoMesadeiros.h"
#import "imMesadeiro.h"
#import "imGrupoLancamentos.h"
#import <Dropbox/Dropbox.h>

#define LIB_DIR_PATH    NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0]

@interface imGrupoMesadeiros()


@end

bool carregaArray = NO;

@implementation imGrupoMesadeiros


+ (imGrupoMesadeiros *) grupo
{
    static imGrupoMesadeiros *grupo = nil;
    if (!grupo) {
        grupo = [[super allocWithZone:nil] init];
    }
    return grupo;
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    return [self grupo];
}



- (imMesadeiro *) objetoComId: (int) idObjeto
{
    imMesadeiro *mesadeiro;
    for (imMesadeiro *objeto in self.arrayObjeto) {
        if(objeto.idMesadeiro == idObjeto){
            mesadeiro = objeto;
            break;
        }
    }
    return mesadeiro;
}


- (imMesadeiro *)objectAtIndex:(NSUInteger)targetIndex
{
    return [self.arrayObjeto objectAtIndex:targetIndex];
}

-(int)maiorId
{
    int idmax = 0;
    for(imMesadeiro *objeto in self.arrayObjeto){
        if(objeto.idMesadeiro > idmax){
            idmax = objeto.idMesadeiro;
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
    [[imGrupoLancamentos grupo] deletaLancamentosParaMesadeiro:[self objectAtIndex:targetIndex].idMesadeiro];
    if ([self dataStoreID]){
        imMesadeiro *mesadeiro = [self.arrayObjeto objectAtIndex:targetIndex];
        [self dropBoxRemoveMesadeiros:mesadeiro];
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




- (void) carregaArray{
    carregaArray = YES;
}

- (void) bloqueiaArray{
    carregaArray = NO;
}

- (NSMutableArray *)arrayObjeto
{
    if (!_arrayObjeto || carregaArray)
    {
        if (carregaArray) {
            [self limpaArrayLocal];
      //      carregaArray = NO;
        }
        if ([self dataStoreID]) {
            DBTable *mesadeiros = [self.datastore getTable:@"mesadeiros"];
            NSArray *arrayAux = [mesadeiros query:nil error:nil];
            _arrayObjeto = [[NSMutableArray alloc]
                            initWithCapacity:[arrayAux count]];

            for (DBRecord *record in arrayAux) {
                [_arrayObjeto addObject:[self converteRecordToMesadeiro:record]];
            }
        }else{
            NSString *path = [[self class] pathForDocumentWithName:@"mesadeiros.plist"];
            NSArray *objetoDicts = [NSMutableArray arrayWithContentsOfFile:path];
        
            if (!objetoDicts)
            {
                path = [[NSBundle mainBundle] pathForResource:@"mesadeiros"
                                                       ofType:@"plist"];
                objetoDicts = [NSMutableArray arrayWithContentsOfFile:path];
            }
        
            _arrayObjeto = [[NSMutableArray alloc]
                            initWithCapacity:[objetoDicts count]];
        
            for (NSDictionary *currDict in objetoDicts)
            {
                imMesadeiro *objeto = [[imMesadeiro alloc] initWithDictionary:currDict];
                objeto.foto = [self readImageFromPlistByKey:[NSString stringWithFormat:@"%d", objeto.idMesadeiro]];
                [_arrayObjeto addObject:objeto];
            }
        }
    }
    return _arrayObjeto;
}

- (void)addObject:(imMesadeiro *)anObject
{
    if (anObject != nil)
    {
        
        [self.arrayObjeto addObject:anObject];
        if ([self dataStoreID]) {
            [self dropBoxAddMesadeiros:anObject];
        }
        // TODO
        [[imGrupoLancamentos grupo] criaLancamentosParaMesadeiro:anObject.idMesadeiro];
    }
}

- (void)save
{
    [self bloqueiaArray];
    if ([self dataStoreID]) {
        for (imMesadeiro *currObj in self.arrayObjeto){
            DBRecord *record = [self localizaRecordDoMesadeiro:currObj];
            record[@"nome"] = currObj.nome;
            record[@"valorMesadaInicial"] = [NSNumber numberWithFloat: currObj.valorMesadaInicial];
//            record[@"foto"] = currObj.foto;
            record[@"email"] = currObj.email;
            [self saveImage:currObj.foto WithName:[NSString stringWithFormat:@"%d",currObj.idMesadeiro]];
            [self.datastore sync:nil];
        }
    }else{
        NSMutableArray *objetoDicts = [NSMutableArray arrayWithCapacity:[self.arrayObjeto count]];
        
        // Convert the array of books into an array of dictionaries for storage
        // in text plist format.
        //
        for (imMesadeiro *currObj in self.arrayObjeto)
        {
            [objetoDicts addObject:[currObj dictionaryWithValuesForKeys:[imMesadeiro keys]]];
            [self saveImage:currObj.foto WithName:[NSString stringWithFormat:@"%d",currObj.idMesadeiro]];
        }
        
        NSString *plist = [objetoDicts description];
        NSString *path = [[self class] pathForDocumentWithName:@"mesadeiros.plist"];
        
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
    [self carregaArray];
}

- (void)saveImage:(UIImage *)image WithName:(NSString *)imageName
{
    // If File Exist then read it otherwise creat new
    NSMutableDictionary *imageInfoDict;
    if([[NSFileManager defaultManager] fileExistsAtPath:[LIB_DIR_PATH stringByAppendingPathComponent:@"imageInfo.plist"]]){
        NSData *fileData = [NSData dataWithContentsOfFile:[LIB_DIR_PATH stringByAppendingPathComponent:@"imageInfo.plist"]];
        imageInfoDict = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:fileData]];
    } else {
        imageInfoDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    // Add Single Image to Dictionary
    [imageInfoDict setValue:image forKey:imageName];
    
    // Convert Main info Dictionary to `NSData` to Save on Disc
    [NSKeyedArchiver archiveRootObject:imageInfoDict toFile:[LIB_DIR_PATH stringByAppendingPathComponent:@"imageInfo.plist"]];

}

-(UIImage *)readImageFromPlistByKey:(NSString *)keyName
{
    UIImage *imagemRetorno;
    // If File Exist then read it otherwise creat new
    NSMutableDictionary *imageInfoDict;
    if([[NSFileManager defaultManager] fileExistsAtPath:[LIB_DIR_PATH stringByAppendingPathComponent:@"imageInfo.plist"]]){
        
        NSData *fileData = [NSData dataWithContentsOfFile:[LIB_DIR_PATH stringByAppendingPathComponent:@"imageInfo.plist"]];
        if([fileData length] > 0){
            // Read Plist
            imageInfoDict = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:fileData]];
            // Here is your Image
            imagemRetorno = imageInfoDict[keyName];
        }
    }else{
        // Return Default Image if not Found
        imagemRetorno = [UIImage imageNamed:@"fotoplaceholder.png"];
    }
    return imagemRetorno;
}

- (void)limpaArrayLocal{
    [_arrayObjeto removeAllObjects];
    _arrayObjeto = nil;
}

- (void)converteMesadeiros{
    for (imMesadeiro *objeto in self.arrayObjeto) {
        //
        [self dropBoxAddMesadeiros:objeto];
        //
        
    }
    
}

-(imMesadeiro *)converteRecordToMesadeiro:(DBRecord *)dpMesadeiro{
 
    imMesadeiro *mesadeiro = [[imMesadeiro alloc] init];

    mesadeiro.nome = dpMesadeiro[@"nome"];
    
    mesadeiro.idMesadeiro = [dpMesadeiro[@"idMesadeiro"] intValue];
    
    mesadeiro.valorMesadaInicial = [dpMesadeiro[@"valorMesadaInicial"] floatValue];

    mesadeiro.foto = [self readImageFromPlistByKey:[NSString stringWithFormat:@"%d", [dpMesadeiro[@"idMesadeiro"] intValue]]];
    
    mesadeiro.email = dpMesadeiro[@"email"];
    
    return mesadeiro;
}

-(void)dropBoxRemoveMesadeiros:(imMesadeiro *)mesadeiro{
     DBRecord *record = [self localizaRecordDoMesadeiro:mesadeiro];
    [record deleteRecord];
    [self.datastore sync:nil];
}


-(void)dropBoxAddMesadeiros:(imMesadeiro *)mesadeiro{
    DBTable *mesadeiros = [self.datastore getTable:@"mesadeiros"];
    [mesadeiros insert:@{ @"ID": [NSString stringWithFormat:@"mes%d", mesadeiro.idMesadeiro], @"idMesadeiro": [NSNumber numberWithInt: mesadeiro.idMesadeiro], @"nome": mesadeiro.nome, @"valorMesadaInicial": [NSNumber numberWithFloat: mesadeiro.valorMesadaInicial], @"email": mesadeiro.email }];
//    @"foto": mesadeiro.foto,
    [self.datastore sync:nil];
}

-(DBRecord *)localizaRecordDoMesadeiro:(imMesadeiro *)mesadeiro{
    DBTable *mesadeiros = [self.datastore getTable:@"mesadeiros"];
    NSArray *results = [mesadeiros query:@{ @"idMesadeiro": [NSNumber numberWithInt: mesadeiro.idMesadeiro]} error:nil];
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

@end
