//
//  NSArray+Enumerable.h
//  ChatCave
//
//  Created by Alex Vollmer on 3/4/14.
//  Copyright (c) 2014 Pluralsight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Enumerable)

- (NSArray *)mappedArrayWithBlock:(id(^)(id obj))block;

@end
