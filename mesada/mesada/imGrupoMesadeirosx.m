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
    // select com id epecifico
    
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
    [self.arrayObjeto removeObjectAtIndex:targetIndex];
    [self save];
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
    if (!_arrayObjeto)
    {
        // ele retornar DBRecord e não um dicionario
        NSArray *objetoDicts = [self.mesadeirosTable query:nil error:nil];
        // ja possui banco
        if (objetoDicts) {
 //           NSLog(@"registros %lu",(unsigned long)[objetoDicts count]);
            _arrayObjeto = [[NSMutableArray alloc]
                            initWithCapacity:[objetoDicts count]];
            
            for (DBRecord *currDict in objetoDicts)
            {
                NSDictionary *dic = [currDict fields];
   //             NSLog(@"no forx");
                imMesadeiro *objeto = [[imMesadeiro alloc] initWithDictionary:dic];
                objeto.foto = [self readImageFromPlistByKey:[NSString stringWithFormat:@"%d", objeto.idMesadeiro]];
                [_arrayObjeto addObject:objeto];
            }

        }else{
     //       NSLog(@"lendo plist");
            
            NSString *path = [[self class] pathForDocumentWithName:@"mesadeiros.plist"];
            NSArray *objetoDicts = [NSMutableArray arrayWithContentsOfFile:path];
            if (!objetoDicts)
            {
       //         NSLog(@"lendo outra plist");
                path = [[NSBundle mainBundle] pathForResource:@"mesadeiros" ofType:@"plist"];
                objetoDicts = [NSMutableArray arrayWithContentsOfFile:path];
            }
            _arrayObjeto = [[NSMutableArray alloc]
                            initWithCapacity:[objetoDicts count]];
            for (NSDictionary *currDict in objetoDicts)
            {
  //              NSLog(@"no for");
                [self.mesadeirosTable insert:currDict];
                [self.datastore sync:nil];
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
    if (anObject)
    {
        NSDictionary *dictionary = [anObject dictionaryWithValuesForKeys:[imMesadeiro keys]];
        [self.mesadeirosTable insert:dictionary];
        [self.datastore sync:nil];
        
        [self.arrayObjeto addObject:anObject];
        [[imGrupoLancamentos grupo] criaLancamentosParaMesadeiro:anObject.idMesadeiro];
    }
}

- (void)save
{
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



@end
