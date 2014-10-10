/**
 * Appcelerator Titanium Mobile Modules
 * Copyright (c) 2012-2013 by Appcelerator, Inc. All Rights Reserved.
 * Proprietary and Confidential - This source code is not for redistribution
 */

#import "TiModule.h"
#import "TiApp.h"

#import "RedLaserSDK.h"
#import "BarcodeResultProxy.h"
#import "OverlayViewController.h"

#import "TiRedlaserCameraPreviewProxy.h"

@interface TiRedlaserModule : TiModule <BarcodePickerControllerDelegate>
{
    BarcodePickerController *picker;
    TiViewProxy *overlayViewProxy;
    OverlayViewController *overlayViewController;
    TiRedlaserCameraPreviewProxy *cameraPreview;
}

-(void)pauseScanning:(id)unused;
-(void)resumeScanning:(id)unused;
-(void)prepareToScan:(id)unused;
-(void)clearResultsSet:(id)unused;
-(void)doneScanning:(id)unused;
-(NSNumber*)isFlashAvailable;
-(void)turnFlash:(id)value;
-(void)requestCameraSnapshot:(id)stillPictureSized;

@property (nonatomic, assign) NSNumber* scanUPCE;
@property (nonatomic, assign) NSNumber* scanEAN8;
@property (nonatomic, assign) NSNumber* scanEAN13;
@property (nonatomic, assign) NSNumber* scanQRCODE;
@property (nonatomic, assign) NSNumber* scanCODE128;
@property (nonatomic, assign) NSNumber* scanCODE39;
@property (nonatomic, assign) NSNumber* scanDATAMATRIX;
@property (nonatomic, assign) NSNumber* scanITF;
@property (nonatomic, assign) NSNumber* scanEAN5;
@property (nonatomic, assign) NSNumber* scanEAN2;
@property (nonatomic, assign) NSNumber* scanCODABAR;
@property (nonatomic, assign) NSNumber* scanPDF417;
@property (nonatomic, assign) NSNumber* scanGS1DATABAR;
@property (nonatomic, assign) NSNumber* scanGS1DATABAREXPANDED;
@property (nonatomic, assign) NSNumber* scanCODE93;
@property (nonatomic, assign) NSDictionary *activeRegion;
@property (nonatomic, assign) NSNumber *orientation;
@property (nonatomic, assign) NSNumber* torchState;
@property (readonly, assign)  NSNumber* isFocusing;
@property (nonatomic, assign) NSNumber* useFrontCamera;
@property (nonatomic, assign) NSNumber* exposureLock;

@end
