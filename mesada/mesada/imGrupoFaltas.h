//
//  imGrupoFaltas.h
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "imFalta.h"
#import <Dropbox/Dropbox.h>

@interface imGrupoFaltas : NSObject

+ (imGrupoFaltas *) grupo;
- (imFalta *)objectAtIndex:(NSUInteger)targetIndex;
- (int)maiorId;
- (void)addObject:(id)anObject;
- (void)save;
- (NSUInteger)count;
- (void)exchangeObjectAtIndex:(NSUInteger)sourceIndex withObjectAtIndex:(NSUInteger)targetIndex;
- (void)removeObjectAtIndex:(NSUInteger)targetIndex;
- (imFalta *) objetoComId: (int) idObjeto;

- (void)removeMoveObjectAtIndex:(NSUInteger)targetIndex;
- (void)addMoveObject:(id)anObject AtIndex:(NSUInteger)targetIndex;


- (void)atualizacaoFaltas;
- (void)converteFaltas;

- (void) carregaArray;
- (void) bloqueiaArray;

@property (nonatomic, strong) DBDatastore *datastore;

@property (strong, nonatomic) NSMutableArray *arrayObjeto;

@end
