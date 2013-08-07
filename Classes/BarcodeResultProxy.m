/**
 * Appcelerator Titanium Mobile Modules
 * Copyright (c) 2012-2013 by Appcelerator, Inc. All Rights Reserved.
 * Proprietary and Confidential - This source code is not for redistribution
 */

#import "BarcodeResultProxy.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@implementation BarcodeResultProxy

@synthesize barcodeResult = _barcodeResult;

+(BarcodeResultProxy*)withBarcodeResult:(BarcodeResult*)theBarcodeResult
{
    BarcodeResultProxy *newProxy = nil;
    
    if (theBarcodeResult != nil) {
        newProxy = [[[BarcodeResultProxy alloc] initWithBarcodeResult:theBarcodeResult] autorelease];
    }
    
    return newProxy;
}

-(BarcodeResultProxy*)initWithBarcodeResult:(BarcodeResult*)theBarcodeResult
{
    self = [super init];
    if (self) {
        _barcodeResult = [theBarcodeResult retain];
    }
    return self;
}

-(void)dealloc
{
    [_barcodeResult release];
    [super dealloc];
}


-(NSNumber*)barcodeType
{
    return [NSNumber numberWithInt:self.barcodeResult.barcodeType];
}

-(NSString*)barcodeTypeString
{
    switch (self.barcodeResult.barcodeType) {
        case kBarcodeTypeEAN13:
            return @"EAN13";
            break;
        case kBarcodeTypeUPCE:
            return @"UPCE";
            break;
        case kBarcodeTypeEAN8:
            return @"EAN8";
            break;
        case kBarcodeTypeSTICKY:
            return @"STIKCY";
            break;
        case kBarcodeTypeQRCODE:
            return @"QRCODE";
            break;
        case kBarcodeTypeCODE128:
            return @"CODE128";
            break;
        case kBarcodeTypeCODE39:
            return @"CODE39";
            break;
        case kBarcodeTypeDATAMATRIX:
            return @"DATAMATRIX";
            break;
        case kBarcodeTypeITF:
            return @"ITF";
            break;
        case kBarcodeTypeEAN5:
            return @"EAN5";
            break;
        case kBarcodeTypeEAN2:
            return @"EAN2";
            break;
        case kBarcodeTypeCodabar:
            return @"Codabar";
            break;
        default:
            return @"unknown";
            break;
    }
}

-(NSString*)barcodeString
{
    return self.barcodeResult.barcodeString;
}

-(NSString*)extendedBarcodeString
{
    return self.barcodeResult.extendedBarcodeString;
}

-(BarcodeResultProxy*)associatedBarcode
{
    return [BarcodeResultProxy withBarcodeResult:self.barcodeResult.associatedBarcode];
}

-(NSDate*)firstScanTime
{
    return self.barcodeResult.firstScanTime;
}

-(NSDate*)mostRecentScanTime
{
    return self.barcodeResult.mostRecentScanTime;
}

-(NSNumber*)equals:(id)otherBarcodeProxy
{
    ENSURE_SINGLE_ARG(otherBarcodeProxy, BarcodeResultProxy);
    return [NSNumber numberWithBool:[self.barcodeResult.barcodeString isEqual:((BarcodeResultProxy*)otherBarcodeProxy).barcodeResult.barcodeString]];
}

-(NSArray*)barcodeLocation
{
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.barcodeResult.barcodeLocation.count];
    for(NSValue *point in self.barcodeResult.barcodeLocation) {
        NSMutableDictionary *jsPoint = [NSMutableDictionary dictionaryWithCapacity:2];
        [jsPoint setObject:[NSNumber numberWithDouble:[point CGPointValue].x] forKey:@"x"];
        [jsPoint setObject:[NSNumber numberWithDouble:[point CGPointValue].y] forKey:@"y"];
        [result addObject:jsPoint];
    }

    return result;
}


@end
