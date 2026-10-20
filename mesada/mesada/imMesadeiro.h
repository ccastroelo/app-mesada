//
//  imMesadeiro.h
//  mesada
//
//  Created by claudio on 11/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface imMesadeiro : NSObject

@property (nonatomic) int idMesadeiro;
@property (strong, nonatomic) NSString *nome;
@property (nonatomic) float valorMesadaInicial;
@property (strong, nonatomic) UIImage *foto;
@property (strong, nonatomic) NSString *email;


+ (NSArray *)keys;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (float)saldo;


@end
