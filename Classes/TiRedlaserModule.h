//  TiRedLaserModule.h
//  redlaser
//
//  Created by: 
//  	Zsombor Papp	zsombor.papp@logicallabs.com
//  	Logical Labs	titanium@logicallabs.com
//
//  Created on 11/1/12
//
//  Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
//



#import "TiModule.h"
#import "TiApp.h"

#import "RedLaserSDK.h"

#import "BarcodeResultProxy.h"
#import "OverlayViewController.h"

@interface TiRedlaserModule : TiModule <BarcodePickerControllerDelegate>
{
    BarcodePickerController *picker;
    TiViewProxy *overlayViewProxy;
    OverlayViewController *overlayViewController;
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
@property (nonatomic, assign) NSNumber* scanSTICKY;
@property (nonatomic, assign) NSNumber* scanQRCODE;
@property (nonatomic, assign) NSNumber* scanCODE128;
@property (nonatomic, assign) NSNumber* scanCODE39;
@property (nonatomic, assign) NSNumber* scanDATAMATRIX;
@property (nonatomic, assign) NSNumber* scanITF;
@property (nonatomic, assign) NSNumber* scanEAN5;
@property (nonatomic, assign) NSNumber* scanEAN2;
@property (nonatomic, assign) NSNumber* scanCODABAR;
@property (nonatomic, assign) NSDictionary *activeRegion;
@property (nonatomic, assign) NSNumber *orientation;
@property (nonatomic, assign) NSNumber* torchState;
@property (readonly, assign)  NSNumber* isFocusing;
@property (nonatomic, assign) NSNumber* useFrontCamera;
@property (nonatomic, assign) NSNumber* exposureLock;

@end
