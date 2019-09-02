//
//  Product.m
//  StarTools
//
//  Created by Feo on 02/09/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "Product.h"

@implementation Product

-(instancetype)initWithIdentifier:(NSString *)identifier andType:(ProductType)type
{
	if ((self = [super init])) {
		_identifier = identifier;
		_type = type;
	}
	
	return self;
}

+(instancetype)productWithIdentifier:(NSString *)identifier andType:(ProductType)type
{
	return [[[self class] alloc] initWithIdentifier:identifier andType:type];
}

@end
