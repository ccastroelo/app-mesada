//
//  imFalta.h
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface imFalta : NSObject

@property (nonatomic) int idFalta;
@property (strong, nonatomic) NSString *descricao;
@property (nonatomic) float valor;

+ (NSArray *)keys;
- (id)initWithDictionary:(NSDictionary *)dictionary;


@end
