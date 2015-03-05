//
//  ScaryBugData.h
//  HelloWorld
//
//  Created by Francesca Corsini on 05/03/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScaryBugData : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic) float rating;

- (id)initWithTitle:(NSString*)title rating:(float)rating;

@end
