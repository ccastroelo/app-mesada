//
//  imLancamento.m
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imLancamento.h"

@implementation imLancamento


+ (NSArray *)keys
{
    return [NSArray arrayWithObjects:
            @"idLancamento",
            @"idFalta",
            @"idMesadeiro",
            @"quantidade",
            nil];
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
