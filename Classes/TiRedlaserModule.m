//  TiRedLaserModule.m
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


#import "TiRedlaserModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

#import <objc/runtime.h>

@implementation TiRedlaserModule

MAKE_SYSTEM_PROP(BARCODE_TYPE_EAN13,kBarcodeTypeEAN13);
MAKE_SYSTEM_PROP(BARCODE_TYPE_UPCE,kBarcodeTypeUPCE);
MAKE_SYSTEM_PROP(BARCODE_TYPE_EAN8,kBarcodeTypeEAN8);
MAKE_SYSTEM_PROP(BARCODE_TYPE_STICKY,kBarcodeTypeSTICKY);
MAKE_SYSTEM_PROP(BARCODE_TYPE_QRCODE,kBarcodeTypeQRCODE);
MAKE_SYSTEM_PROP(BARCODE_TYPE_CODE128,kBarcodeTypeCODE128);
MAKE_SYSTEM_PROP(BARCODE_TYPE_CODE39,kBarcodeTypeCODE39);
MAKE_SYSTEM_PROP(BARCODE_TYPE_DATAMATRIX,kBarcodeTypeDATAMATRIX);
MAKE_SYSTEM_PROP(BARCODE_TYPE_ITF,kBarcodeTypeITF);
MAKE_SYSTEM_PROP(BARCODE_TYPE_EAN5,kBarcodeTypeEAN5);
MAKE_SYSTEM_PROP(BARCODE_TYPE_EAN2,kBarcodeTypeEAN2);
MAKE_SYSTEM_PROP(BARCODE_TYPE_CODABAR,kBarcodeTypeCodabar);

MAKE_SYSTEM_PROP(STATUS_EVAL_MODE_READY,RLState_EvalModeReady);
MAKE_SYSTEM_PROP(STATUS_LICENSED_MODE_READY,RLState_LicensedModeReady);

MAKE_SYSTEM_PROP(STATUS_MISSING_OS_LIBS,RLState_MissingOSLibraries);
MAKE_SYSTEM_PROP(STATUS_NO_CAMERA,RLState_NoCamera);
MAKE_SYSTEM_PROP(STATUS_BAD_LICENSE,RLState_BadLicense);
MAKE_SYSTEM_PROP(STATUS_SCAN_LIMIT_REACHED,RLState_ScanLimitReached);

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"5732454f-aff6-4836-b38d-b50fd1774395";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.redlaser";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma Public APIs

-(id)sdkVersion
{
	return RL_GetRedLaserSDKVersion();
}

-(id)status
{
	return [NSNumber numberWithInt:RL_CheckReadyStatus()];
}

-(void)startScanning:(id)params
{
    ENSURE_UI_THREAD(startScanning,params);
    ENSURE_SINGLE_ARG(params, NSDictionary);
    
    if (picker == nil) {
        picker = [[BarcodePickerController alloc] init];
        picker.delegate = self;

        overlayViewProxy = [[params objectForKey:@"overlay"] retain];
        if (overlayViewProxy) {
            ENSURE_TYPE(overlayViewProxy, TiViewProxy);
            // Blaine made the suggestion to call rememberProxy before anything else.
            [self rememberProxy:overlayViewProxy];

            overlayViewController = [[OverlayViewController alloc] initWithModule:self];
            [overlayViewController.view addSubview:overlayViewProxy.view];
            [picker setOverlay:overlayViewController];
        }

        if (overlayViewProxy) {
            // This is what the showPicker method in MediaModule.m does:
            //
            //        [TiUtils setView:overlayViewProxy.view positionRect:CGRectMake(0, 0, 320, 460)];
            
            [TiUtils setView:overlayViewProxy.view positionRect:[picker view].bounds];
            //        [overlayViewProxy setSandboxBounds:CGRectMake(0, 0, 320, 460)];
            //        overlayViewProxy.view.center = CGPointMake(160, 210);
            //        overlayViewProxy.view.bounds = CGRectMake(0, 0, 320, 460);
            [overlayViewProxy windowWillOpen];
            [overlayViewProxy windowDidOpen];
            [overlayViewProxy layoutChildren:NO];
            [picker setWantsFullScreenLayout:YES];
            
            //
            // The following commented-out lines were my interpretation of what
            // the view proxy 'add' method would do.
            //
            //        [overlayViewProxy parentWillShow];
            //        [overlayViewProxy setSandboxBounds:CGRectMake(0, 0, 320, 460)];
            //        overlayViewProxy.view.autoresizingMask = UIViewAutoresizingNone;
            //        overlayViewProxy.view.center = CGPointMake(160, 210);
            //        overlayViewProxy.view.bounds = CGRectMake(0, 0, 320, 460);
            //        [overlayViewProxy layoutChildren:NO];
        }
        
        [[TiApp app] showModalController:picker animated:YES];
        if (overlayViewProxy) {
            [overlayViewProxy windowDidOpen];
            [overlayViewProxy layoutChildren:NO];
            [picker setWantsFullScreenLayout:YES];
        }
        
        [[[TiApp app] controller] manuallyRotateToOrientation:UIInterfaceOrientationPortrait duration:[[[TiApp app] controller] suggestedRotationDuration]];
        if ([self _hasListeners:@"scannerActivated"]) {
            [self fireEvent:@"scannerActivated"];
        }
    } else {
        NSLog(@"[WARN] Received call to startScanning while scanner is already active.");
    }
}

-(void)barcodePickerController:(BarcodePickerController*)picker
                   returnResults:(NSSet *)results;
{
    if ([self _hasListeners:@"scannerReturnedResults"]) {
        NSMutableDictionary *jsEvent = [NSMutableDictionary dictionary];
        NSMutableArray *jsResults = [NSMutableArray arrayWithCapacity:[results count]];
        for (BarcodeResult *result in results) {
            if ([result isKindOfClass:[BarcodeResult class]]) {
                [jsResults addObject:[BarcodeResultProxy withBarcodeResult:result]];
            } else {
                NSLog(@"[WARN] Unexpected object type in barcodePickerController:returnResults.");
            }
        }
        [jsEvent setObject:jsResults forKey:@"foundBarcodes"];
        [self fireEvent:@"scannerReturnedResults" withObject:jsEvent];
    }
}

-(NSArray*)findBarcodesInBlob:(id)theBlob
{
    ENSURE_SINGLE_ARG(theBlob, TiBlob);
    UIImage *image = ((TiBlob*)theBlob).image;
    if (!image) {
        NSLog(@"[WARN] Blob is not an image!");
    }
    NSSet *results = FindBarcodesInUIImage(image);
    NSMutableArray *jsResults = [NSMutableArray arrayWithCapacity:results.count];
    
    for (BarcodeResult *result in results) {
        [jsResults addObject:[BarcodeResultProxy withBarcodeResult:result]];
    }
    return jsResults;
}

-(void)pauseScanning:(id)unused
{
    if (picker != nil) {
        [picker pauseScanning];
    } else {
        NSLog(@"[WARN] Received call to pauseScanning while scanner is not active.");
    }
}

-(void)resumeScanning:(id)unused
{
    if (picker != nil) {
        [picker resumeScanning];
    } else {
        NSLog(@"[WARN] Received call to resumeScanning while scanner is not active.");
    }
}

-(void)prepareToScan:(id)unused
{
    // Note: this method is currently useless because by the time the picker
    // object is available, it as also scanning. This method will become useful
    // again if we ever decide to separate the cretion of the picker object from
    // the start of scanning.
    if (picker != nil) {
        [picker prepareToScan];
    } else {
        NSLog(@"[WARN] Received call to prepareToScan while picker is not initialized.");
    }
}

-(void)clearResultsSet:(id)unused
{
    if (picker != nil) {
        [picker clearResultsSet];
    } else {
        NSLog(@"[WARN] Received call to clearResultsSet while scanner is not active.");
    }
}

-(void)doneScanning:(id)unused
{
    ENSURE_UI_THREAD(doneScanning,unused);
    
    if (picker != nil) {
        if (overlayViewProxy) {
            [overlayViewProxy windowWillClose];
        }
        [picker doneScanning];
        [picker dismissViewControllerAnimated:TRUE completion:nil];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        if (overlayViewProxy) {
            [overlayViewProxy windowDidClose];
            [self forgetProxy:overlayViewProxy];
            RELEASE_TO_NIL(overlayViewProxy);
        }
        RELEASE_TO_NIL(picker);
    } else {
        NSLog(@"[WARN] Received call to doneScanning while scanner is not active.");
    }
}

-(NSNumber*)isFlashAvailable
{
    if (picker != nil) {
        return NUMBOOL([picker hasFlash]);
    } else {
        return NUMBOOL(NO);
        NSLog(@"[WARN] Received call to isFlashAvailable while scanner is not active.");
    }
}

-(void)turnFlash:(id)value
{
    if (picker != nil) {
        [picker turnFlash:[TiUtils boolValue:value]];
    } else {
        NSLog(@"[WARN] Received call to turnFlash while scanner is not active.");
    }
}

-(void)requestCameraSnapshot:(id)stillPictureSized
{
    if (picker != nil) {
        [picker requestCameraSnapshot:[TiUtils boolValue:stillPictureSized]];
    } else {
        NSLog(@"[WARN] Received call to requestCameraSnapshot while scanner is not active.");
    }
}

-(void)setScanUPCE:(id)value
{
    picker.scanUPCE = [TiUtils boolValue:value];
}

-(NSNumber*)scanUPCE
{
    if (picker != nil) {
        return NUMBOOL([picker scanUPCE]);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanEAN8:(id)value
{
    if (picker != nil) {
        picker.scanEAN8 = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanEAN8
{
    if (picker != nil) {
        return NUMBOOL(picker.scanEAN8);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanEAN13:(id)value
{
    if (picker != nil) {
        picker.scanEAN13 = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanEAN13
{
    if (picker != nil) {
        return NUMBOOL(picker.scanEAN13);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanSTICKY:(id)value
{
    if (picker != nil) {
        picker.scanSTICKY = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanSTICKY
{
    if (picker != nil) {
        return NUMBOOL(picker.scanSTICKY);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanQRCODE:(id)value
{
    if (picker != nil) {
        picker.scanQRCODE = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanQRCODE
{
    if (picker != nil) {
        return NUMBOOL(picker.scanQRCODE);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanCODE128:(id)value
{
    if (picker != nil) {
        picker.scanCODE128 = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanCODE128
{
    if (picker != nil) {
        return NUMBOOL(picker.scanCODE128);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanCODE39:(id)value
{
    if (picker != nil) {
        picker.scanCODE39 = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanCODE39
{
    if (picker != nil) {
        return NUMBOOL(picker.scanCODE39);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanDATAMATRIX:(id)value
{
    if (picker != nil) {
        picker.scanDATAMATRIX = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanDATAMATRIX
{
    if (picker != nil) {
        return NUMBOOL(picker.scanDATAMATRIX);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanITF:(id)value
{
    if (picker != nil) {
        picker.scanITF = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanITF
{
    if (picker != nil) {
        return NUMBOOL(picker.scanITF);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanEAN5:(id)value
{
    if (picker != nil) {
        picker.scanEAN5 = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanEAN5
{
    if (picker != nil) {
        return NUMBOOL(picker.scanEAN5);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanEAN2:(id)value
{
    if (picker != nil) {
        picker.scanEAN2 = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanEAN2
{
    if (picker != nil) {
        return NUMBOOL(picker.scanEAN2);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanCODABAR:(id)value
{
    if (picker != nil) {
        picker.scanEAN8 = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
    picker.scanCODABAR = [TiUtils boolValue:value];
}

-(NSNumber*)scanCODABAR
{
    if (picker != nil) {
        return NUMBOOL(picker.scanCODABAR);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setActiveRect:(id)rect
{
    ENSURE_SINGLE_ARG(rect, NSDictionary);
    
    if (picker != nil) {
        picker.activeRegion = CGRectMake(
                                         [[rect objectForKey:@"x"] floatValue],
                                         [[rect objectForKey:@"y"] floatValue],
                                         [[rect objectForKey:@"width"] floatValue],
                                         [[rect objectForKey:@"height"] floatValue]
                                         );
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSDictionary*)activeRect
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:4];
    
    if (picker != nil) {
        [result setObject:[NSNumber numberWithFloat:picker.activeRegion.origin.x] forKey:@"x" ];
        [result setObject:[NSNumber numberWithFloat:picker.activeRegion.origin.y] forKey:@"y" ];
        [result setObject:[NSNumber numberWithFloat:picker.activeRegion.size.width] forKey:@"width" ];
        [result setObject:[NSNumber numberWithFloat:picker.activeRegion.size.height] forKey:@"heigh" ];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        [result setObject:[NSNumber numberWithFloat:0.0] forKey:@"x" ];
        [result setObject:[NSNumber numberWithFloat:0.0] forKey:@"y" ];
        [result setObject:[NSNumber numberWithFloat:0.0] forKey:@"width" ];
        [result setObject:[NSNumber numberWithFloat:0.0] forKey:@"heigh" ];
    }
    return result;
}

-(void)setOrientation:(id)value
{
    if (picker != nil) {
        picker.orientation = [TiUtils intValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)orientation
{
    if (picker != nil) {
        return NUMBOOL(picker.orientation);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(false);
    }
}

-(void)setTorchState:(id)value
{
    if (picker != nil) {
        picker.torchState = [TiUtils boolValue:value];
    }
}

-(NSNumber*)torchState
{
    if (picker != nil) {
        return NUMBOOL(picker.torchState);
    } else {
        return NUMBOOL(false);
    }
}

-(NSNumber*)isFocusing
{
    if (picker != nil) {
        return NUMBOOL(picker.isFocusing);
    } else {
        return NUMBOOL(false);
    }
}

-(void)setUseFrontCamera:(id)value
{
    if (picker != nil) {
        picker.useFrontCamera = [TiUtils boolValue:value];
    }
}

-(NSNumber*)useFrontCamera
{
    if (picker != nil) {
        return NUMBOOL(picker.useFrontCamera);
    } else {
        return NUMBOOL(false);
    }
}

-(void)setExposureLock:(id)value
{
    picker.exposureLock = [TiUtils boolValue:value];
}

-(NSNumber*)exposureLock
{
    return NUMBOOL(picker.exposureLock);
}

@end
