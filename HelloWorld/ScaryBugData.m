//
//  ScaryBugData.m
//  HelloWorld
//
//  Created by Francesca Corsini on 05/03/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "ScaryBugData.h"

@implementation ScaryBugData


- (id)initWithTitle:(NSString*)title rating:(float)rating
{
	if ((self = [super init]))
	{
		self.title = title;
		self.rating = rating;
	}
	return self;
}

@end
