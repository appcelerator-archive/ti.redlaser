/**
 * Appcelerator Titanium Mobile Modules
 * Copyright (c) 2012-2013 by Appcelerator, Inc. All Rights Reserved.
 * Proprietary and Confidential - This source code is not for redistribution
 */

#import "TiWindowProxy.h"

#import "RedLaserSDK.h"
#import "OverlayViewController.h"

@interface TiRedlaserCameraPreviewProxy : TiViewProxy {
    BarcodePickerController *picker;
    OverlayViewController *overlayViewController;
    TiViewProxy *overlay;
}

-(void)startScanningWithPicker:(BarcodePickerController *)picker_ overlayViewProxy:(TiViewProxy *)overlay_ overlayViewController:(OverlayViewController *)overlayController_;
-(void)doneScanning;

@end
