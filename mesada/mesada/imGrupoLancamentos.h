//
//  imGrupoLancamentos.h
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "imLancamento.h"


@interface imGrupoLancamentos : NSObject 

+ (imGrupoLancamentos *) grupo;

- (imLancamento *)objectAtIndex:(NSUInteger)targetIndex;
- (int)maiorId;
- (void)save;
- (NSUInteger)count;
- (void)exchangeObjectAtIndex:(NSUInteger)sourceIndex withObjectAtIndex:(NSUInteger)targetIndex;
- (void)removeObjectAtIndex:(NSUInteger)targetIndex;
- (void)zeraTodosLancamentos;
- (void)zeraLancamentosParaMesadeiro:(int)idMesadeiro;
- (void)criaLancamentosParaMesadeiro: (int) idMesadeiro;
- (void)criaLancamentosParaFalta: (int) idFalta;
- (void)deletaLancamentosParaMesadeiro: (int) idMesadeiro;
- (void)deletaLancamentosParaFalta: (int) idFalta;
- (NSUInteger)countWithMesadeiro: (int)idMesadeiro;
- (imLancamento *)objectAtIndex: (NSUInteger)targetIndex withMesadeiro: (int)idMesadeiro;
- (void)atualiza;
- (float)saldoParaMesadeiro:(int)idMesadeiro;
- (NSString *)montaEmailParaMesadeiro:(int)idMesadeiro;
- (void) chamaAtualizacao;

- (void)removeMoveObjectAtIndex:(NSUInteger)targetIndex;
- (void)addMoveObject:(id)anObject AtIndex:(NSUInteger)targetIndex;
- (void)exchangeObject:(id)sourceObject withObject:(id)targetObject;
- (void)removeObject:(id)targetObject;

@property (strong, nonatomic) NSMutableArray *arrayObjeto;

@end
