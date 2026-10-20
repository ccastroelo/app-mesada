//
//  imGrupoMesadeiros.h
//  mesada
//
//  Created by claudio on 11/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "imMesadeiro.h"
#import <Dropbox/Dropbox.h>



@interface imGrupoMesadeiros : NSObject

+ (imGrupoMesadeiros *) grupo;

- (imMesadeiro *)objectAtIndex:(NSUInteger)targetIndex;
- (int)maiorId;
- (void)addObject:(id)anObject;
- (void)save;
- (void)removeObjectAtIndex:(NSUInteger)targetIndex;
- (void)exchangeObjectAtIndex:(NSUInteger)sourceIndex withObjectAtIndex:(NSUInteger)targetIndex;
- (NSUInteger)count;
- (imMesadeiro *)objetoComId: (int) idObjeto;
- (void)converteMesadeiros;
//- (void)limpaArrayLocal;

- (void) carregaArray;
- (void) bloqueiaArray;

@property (nonatomic, strong) DBDatastore *datastore;
@property (strong, nonatomic) NSMutableArray *arrayObjeto;

@end
