//
//  ScaryBugDoc.m
//  HelloWorld
//
//  Created by Francesca Corsini on 05/03/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "ScaryBugDoc.h"
#import "ScaryBugData.h"

@implementation ScaryBugDoc

- (id)initWithTitle:(NSString*)title rating:(float)rating thumbImage:(NSImage *)thumbImage fullImage:(NSImage *)fullImage
{
	if ((self = [super init]))
	{
		self.data = [[ScaryBugData alloc] initWithTitle:title rating:rating];
		self.thumbImage = thumbImage;
		self.fullImage = fullImage;
	}
	return self;
}

@end
