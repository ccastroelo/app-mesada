//
//  imFalta.m
//  mesada
//
//  Created by claudio on 12/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imFalta.h"

@implementation imFalta

+ (NSArray *)keys
{
    return [NSArray arrayWithObjects:
            @"idFalta",
            @"descricao",
            @"valor",
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
