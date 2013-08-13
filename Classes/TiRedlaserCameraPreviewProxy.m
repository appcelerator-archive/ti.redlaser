/**
 * Appcelerator Titanium Mobile Modules
 * Copyright (c) 2012-2013 by Appcelerator, Inc. All Rights Reserved.
 * Proprietary and Confidential - This source code is not for redistribution
 */

#import "TiRedlaserCameraPreviewProxy.h"
#import "TiLayoutQueue.h"

@implementation TiRedlaserCameraPreviewProxy

-(id)init
{
    picker = nil;
    overlay = nil;
    return [super init];
}

-(void)startScanningWithPicker:(BarcodePickerController *)picker_ overlayViewProxy:(TiViewProxy *)overlay_ overlayViewController:(OverlayViewController *)overlayViewController_
{
    TiThreadPerformOnMainThread(^{
        picker = [picker_ retain];
        overlayViewController = [overlayViewController_ retain];
        
        [picker.view setFrame:self.view.bounds];
        [picker.view setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        [self.view addSubview:picker.view];
        
        if (overlay_ != nil) {
            overlay = [overlay_ retain];
            [self rememberProxy:overlay];
            
            // If not YES, the top of the subView will be +20
            overlayViewController.wantsFullScreenLayout = YES;
            [TiUtils setView:overlayViewController.view positionRect:[self.view bounds]];
            [TiUtils setView:overlay.view positionRect:[self.view bounds]];
            
            [overlay layoutChildren:NO];
        }
        [picker setOverlay:overlayViewController];
    }, NO);
}

-(void)doneScanning
{
    TiThreadPerformOnMainThread(^{
        if (overlay != nil) {
            [overlay.view removeFromSuperview];
            [self forgetProxy:overlay];
            RELEASE_TO_NIL(overlay);
        }
        
        [picker.view removeFromSuperview];
        
        RELEASE_TO_NIL(picker);
        RELEASE_TO_NIL(overlayViewController);
    }, NO);
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [picker willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    // This Proxy must be added to the layoutqueue here
    // If it is not added, none of its children will be laid out after the first rotation
    [TiLayoutQueue addViewProxy:self];
    
    if (overlay != nil) {
        [TiLayoutQueue addViewProxy:overlay];
    }
}

@end
