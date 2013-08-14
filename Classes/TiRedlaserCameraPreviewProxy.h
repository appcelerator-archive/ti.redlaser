/**
 * Appcelerator Titanium Mobile Modules
 * Copyright (c) 2012-2013 by Appcelerator, Inc. All Rights Reserved.
 * Proprietary and Confidential - This source code is not for redistribution
 */

#import "TiWindowProxy.h"

#import "RedLaserSDK.h"
#import "OverlayViewController.h"

typedef enum
{
	RLOrientationNone = 0,
	RLOrientationAny = 0xFFFF,
	
    /**
     Portrait orientation flag.
     */
	RLOrientationPortrait			= 1 << UIInterfaceOrientationPortrait,
    
    /**
     Upside-down portrait orientation flag.
     */
	RLOrientationPortraitUpsideDown	= 1 << UIInterfaceOrientationPortraitUpsideDown,
	
    /**
     Landscape left orientation flag.
     */
    RLOrientationLandscapeLeft		= 1 << UIInterfaceOrientationLandscapeLeft,
	
    /**
     Landscape right orientation flag.
     */
    RLOrientationLandscapeRight		= 1 << UIInterfaceOrientationLandscapeRight,
    
    /**
     Landscape (left or right) orientation flag.
     */
    RLOrientationLandscapeOnly		= RLOrientationLandscapeLeft | RLOrientationLandscapeRight,
	
    /**
     Portrait (normal or upside-down) orientation flag.
     */
    RLOrientationPortraitOnly		= RLOrientationPortrait | RLOrientationPortraitUpsideDown,
	
} RLOrientationFlags;

#define RL_ORIENTATION_ALLOWED(flag,bit)	(flag & (1<<bit))
#define RL_ORIENTATION_SET(flag,bit)		(flag |= (1<<bit))

@interface TiRedlaserCameraPreviewProxy : TiViewProxy {
@private
    BarcodePickerController *picker;
    OverlayViewController *overlayViewController;
    TiViewProxy *overlay;
    RLOrientationFlags orientationFlags;
}

-(void)startScanningWithPicker:(BarcodePickerController *)picker_ overlayViewProxy:(TiViewProxy *)overlay_ overlayViewController:(OverlayViewController *)overlayController_;
-(void)doneScanning;

@end
