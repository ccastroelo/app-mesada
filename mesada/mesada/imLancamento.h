//
//  imLancamento.h
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface imLancamento : NSObject


@property (nonatomic) int idLancamento;
@property (nonatomic) int idFalta;
@property (nonatomic) int idMesadeiro;
@property (nonatomic) int quantidade;


+ (NSArray *)keys;
- (id)initWithDictionary:(NSDictionary *)dictionary;


@end
