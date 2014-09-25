/**
 * Appcelerator Titanium Mobile Modules
 * Copyright (c) 2012-2013 by Appcelerator, Inc. All Rights Reserved.
 * Proprietary and Confidential - This source code is not for redistribution
 */

#import "TiRedlaserModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

#import "TiRedlaserCameraPreviewProxy.h"

@implementation TiRedlaserModule

MAKE_SYSTEM_PROP(BARCODE_TYPE_EAN13,kBarcodeTypeEAN13);
MAKE_SYSTEM_PROP(BARCODE_TYPE_UPCE,kBarcodeTypeUPCE);
MAKE_SYSTEM_PROP(BARCODE_TYPE_EAN8,kBarcodeTypeEAN8);
MAKE_SYSTEM_PROP(BARCODE_TYPE_QRCODE,kBarcodeTypeQRCODE);
MAKE_SYSTEM_PROP(BARCODE_TYPE_CODE128,kBarcodeTypeCODE128);
MAKE_SYSTEM_PROP(BARCODE_TYPE_CODE39,kBarcodeTypeCODE39);
MAKE_SYSTEM_PROP(BARCODE_TYPE_DATAMATRIX,kBarcodeTypeDATAMATRIX);
MAKE_SYSTEM_PROP(BARCODE_TYPE_ITF,kBarcodeTypeITF);
MAKE_SYSTEM_PROP(BARCODE_TYPE_EAN5,kBarcodeTypeEAN5);
MAKE_SYSTEM_PROP(BARCODE_TYPE_EAN2,kBarcodeTypeEAN2);
MAKE_SYSTEM_PROP(BARCODE_TYPE_CODABAR,kBarcodeTypeCodabar);
MAKE_SYSTEM_PROP(BARCODE_TYPE_PDF417,kBarcodeTypePDF417);
MAKE_SYSTEM_PROP(BARCODE_TYPE_GS1DATABAR,kBarcodeTypeGS1Databar);
MAKE_SYSTEM_PROP(BARCODE_TYPE_GS1DATABAR_EXPANDED,kBarcodeTypeGS1DatabarExpanded);
MAKE_SYSTEM_PROP(BARCODE_TYPE_CODE93,kBarcodeTypeCODE93);

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
	
    RELEASE_TO_NIL(picker);
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
    
    id overlayViewProxy_ = [params objectForKey:@"overlay"];
    ENSURE_TYPE_OR_NIL(overlayViewProxy_, TiViewProxy);
    
    id cameraPreview_ = [params objectForKey:@"cameraPreview"];
    ENSURE_TYPE_OR_NIL(cameraPreview_, TiRedlaserCameraPreviewProxy);
    
    if (picker == nil) {
        picker = [[BarcodePickerController alloc] init];
        picker.delegate = self;
        
        overlayViewController = [[OverlayViewController alloc] initWithModule:self];
        
        if (overlayViewProxy_ != nil) {
            overlayViewProxy = [overlayViewProxy_ retain];
            [self rememberProxy:overlayViewProxy];
        } 
        
        if (cameraPreview_ != nil) {
            cameraPreview = [cameraPreview_ retain];
            [self rememberProxy:cameraPreview];
            
            [cameraPreview startScanningWithPicker:picker
                                overlayViewProxy:overlayViewProxy
                               overlayViewController:overlayViewController];
        } else {
            [picker setOverlay:overlayViewController];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [TiUtils setView:overlayViewProxy.view positionRect:[picker view].bounds];
        }
        
        if (overlayViewProxy != nil) {
            [overlayViewController.view addSubview:overlayViewProxy.view];
            
            [overlayViewProxy windowWillOpen];
            [overlayViewProxy setParentVisible:YES];
            [overlayViewProxy windowDidOpen];
        }
        
        if (cameraPreview_ == nil) {
            // If cameraPreview not provided then show the controller
            // Must be called after addSubview
            [[TiApp app] showModalController:picker animated:YES];
        }
        
        if (overlayViewProxy != nil) {
            // layoutChildren must be called after `showModalController` to avoid layout
            // issues when showing picker in different orientations
            [overlayViewProxy layoutChildren:NO];
        }
        
        if ([self _hasListeners:@"scannerActivated"]) {
            [self fireEvent:@"scannerActivated"];
        }
    } else {
        NSLog(@"[WARN] Received call to startScanning while scanner is already active.");
    }
}

-(void)doneScanning:(id)unused
{
    ENSURE_UI_THREAD(doneScanning,unused);
    
    if (picker != nil) {
        [picker doneScanning];
        
        if (cameraPreview != nil) {
            [cameraPreview doneScanning];
        }
        
        if (overlayViewProxy != nil) {
            [overlayViewProxy windowWillClose];
        }
        
        // If no cameraPreview, dismiss the viewConstroller
        if (cameraPreview == nil) {
            [picker dismissViewControllerAnimated:TRUE completion:nil];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
        
        // Remove an release overlay
        if (overlayViewProxy != nil) {
            [overlayViewProxy.view removeFromSuperview];
            [self forgetProxy:overlayViewProxy];
            RELEASE_TO_NIL(overlayViewProxy);
        }
        
        if (cameraPreview != nil) {
            [self forgetProxy:cameraPreview];
            RELEASE_TO_NIL(cameraPreview);
        }
        
        [picker setOverlay:nil];
        RELEASE_TO_NIL(picker);
        RELEASE_TO_NIL(overlayViewController);
    } else {
        NSLog(@"[WARN] Received call to doneScanning while scanner is not active.");
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

-(NSNumber*)isFlashAvailable
{
    if (picker != nil) {
        return NUMBOOL([picker hasTorch]);
    } else {
        return NUMBOOL(NO);
        NSLog(@"[WARN] Received call to isFlashAvailable while scanner is not active.");
    }
}

-(void)turnFlash:(id)value
{
    if (picker != nil) {
        [picker turnTorch:[TiUtils boolValue:value]];
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
        picker.scanCODABAR = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
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

-(void)setScanPDF417:(id)value
{
    if (picker != nil) {
        picker.scanPDF417 = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanPDF417
{
    if (picker != nil) {
        return NUMBOOL(picker.scanPDF417);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanGS1DATABAR:(id)value
{
    if (picker != nil) {
        picker.scanGS1DATABAR = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanGS1DATABAR
{
    if (picker != nil) {
        return NUMBOOL(picker.scanGS1DATABAR);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanGS1DATABAREXPANDED:(id)value
{
    if (picker != nil) {
        picker.scanGS1DATABAREXPANDED = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanGS1DATABAREXPANDED
{
    if (picker != nil) {
        return NUMBOOL(picker.scanGS1DATABAREXPANDED);
    } else {
        NSLog(@"[WARN] Scanner is not active!");
        return NUMBOOL(NO);
    }
}

-(void)setScanCODE93:(id)value
{
    if (picker != nil) {
        picker.scanCODE93 = [TiUtils boolValue:value];
    } else {
        NSLog(@"[WARN] Scanner is not active!");
    }
}

-(NSNumber*)scanCODE93
{
    if (picker != nil) {
        return NUMBOOL(picker.scanCODE93);
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
