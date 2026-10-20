//
//  imMesadeiro.m
//  mesada
//
//  Created by claudio on 11/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imMesadeiro.h"
#import "imGrupoLancamentos.h"

@implementation imMesadeiro

+ (NSArray *)keys
{
    return [NSArray arrayWithObjects:
            @"idMesadeiro",
            @"nome",
            @"valorMesadaInicial",
            @"email",
            nil];
}

- (float)saldo
{
    float saldo = self.valorMesadaInicial + [[imGrupoLancamentos grupo] saldoParaMesadeiro:self.idMesadeiro];
    return saldo;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    NSMutableDictionary *mutableDict = [dictionary mutableCopy];
    [self setValuesForKeysWithDictionary:mutableDict];
    return self;
}

- (id)init
{
    self = [super init];
    if(self){

    }
    return self;
}


@end
