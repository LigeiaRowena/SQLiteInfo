//
//  ScaryBugDoc.h
//  HelloWorld
//
//  Created by Francesca Corsini on 05/03/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ScaryBugData;

@interface ScaryBugDoc : NSObject

@property (nonatomic, strong) ScaryBugData *data;
@property (nonatomic, strong) NSImage *thumbImage;
@property (nonatomic, strong) NSImage *fullImage;

- (id)initWithTitle:(NSString*)title rating:(float)rating thumbImage:(NSImage *)thumbImage fullImage:(NSImage *)fullImage;

@end
