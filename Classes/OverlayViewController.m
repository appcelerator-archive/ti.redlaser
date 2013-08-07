/**
 * Appcelerator Titanium Mobile Modules
 * Copyright (c) 2012-2013 by Appcelerator, Inc. All Rights Reserved.
 * Proprietary and Confidential - This source code is not for redistribution
 */

#import "OverlayViewController.h"

@interface OverlayViewController ()

@end

@implementation OverlayViewController

@synthesize module = _module;

-(OverlayViewController*)initWithModule:(TiRedlaserModule*)theModule
{
    self = [super init];
    if (self) {
        _module = [theModule retain];
    }
    return self;

}

-(void)barcodePickerController:(BarcodePickerController*)picker statusUpdated:(NSDictionary*)status
{
	// In the status dictionary:
	
	// "FoundBarcodes" key is a NSSet of all discovered barcodes this scan session
	// "NewFoundBarcodes" is a NSSet of barcodes discovered in the most recent pass.
    // When a barcode is found, it is added to both sets. The NewFoundBarcodes
    // set is cleaned out each pass.
	
	// "Guidance" can be used to help guide the user through the process of discovering
	// a long barcode in sections. Currently only works for Code 39.
	
	// "Valid" is TRUE once there are valid barcode results.
	// "InRange" is TRUE if there's currently a barcode detected the viewfinder. The barcode
	//		may not have been decoded yet. It is possible for barcodes to be found without
	// 		InRange ever being set.
    if ([self.module _hasListeners:@"scannerStatusUpdated"]) {
        NSMutableDictionary *jsEvent = [NSMutableDictionary dictionary];
        
        NSMutableArray *jsFoundBarcodes = [NSMutableArray array];
        if ([status objectForKey:@"FoundBarcodes"] != nil) {
            for (BarcodeResult *result in [status objectForKey:@"FoundBarcodes"]) {
                [jsFoundBarcodes addObject:[BarcodeResultProxy withBarcodeResult:result]];
            }
        }
        [jsEvent setObject:jsFoundBarcodes forKey:@"foundBarcodes"];
        
        NSMutableArray *jsNewFoundBarcodes = [NSMutableArray array];
        if ([status objectForKey:@"NewFoundBarcodes"] != nil) {
            for (BarcodeResult *result in [status objectForKey:@"NewFoundBarcodes"]) {
                [jsNewFoundBarcodes addObject:[BarcodeResultProxy withBarcodeResult:result]];
            }
        }
        [jsEvent setObject:jsNewFoundBarcodes forKey:@"newFoundBarcodes"];
        
        if ([status objectForKey:@"Valid"] != nil) {
            [jsEvent setObject:[status objectForKey:@"Valid"] forKey:@"valid"];
        }
        
        if ([status objectForKey:@"InRange"] != nil) {
            [jsEvent setObject:[status objectForKey:@"InRange"] forKey:@"inRange"];
        }
        
        if ([status objectForKey:@"Guidance"] != nil) {
            [jsEvent setObject:[status objectForKey:@"Guidance"] forKey:@"guidance"];
        }
        
        if ([status objectForKey:@"PartialBarcode"] != nil) {
            [jsEvent setObject:[status objectForKey:@"PartialBarcode"] forKey:@"partialBarcode"];
        }
        
        if ([status objectForKey:@"CameraSupportsTapToFocus"] != nil) {
            [jsEvent setObject:[status objectForKey:@"CameraSupportsTapToFocus"] forKey:@"cameraSupportsTapToFocus"];
        }
        
        if ([status objectForKey:@"CameraSnapshot"] != nil) {
            UIImage *image = [status objectForKey:@"CameraSnapshot"];
            TiBuffer *buffer = [[[TiBuffer alloc] init] autorelease];
            buffer.data = [NSMutableData dataWithData:UIImageJPEGRepresentation(image,1.0)];
            [jsEvent setObject:buffer forKey:@"cameraSnapshot"];
        }
        [self.module fireEvent:@"scannerStatusUpdated" withObject:jsEvent];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}
@end
