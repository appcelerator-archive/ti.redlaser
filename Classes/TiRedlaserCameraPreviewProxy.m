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

-(void)_configure
{
	[self replaceValue:nil forKey:@"orientationModes" notification:NO];
	[super _configure];
}

-(void)startScanningWithPicker:(BarcodePickerController *)picker_ overlayViewProxy:(TiViewProxy *)overlay_ overlayViewController:(OverlayViewController *)overlayViewController_
{
    TiThreadPerformOnMainThread(^{
        if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
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
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        
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

#pragma mark - properties

-(void)setOrientationModes:(id)value
{
	[self replaceValue:value forKey:@"orientationModes" notification:YES];
	orientationFlags = RLOrientationFlagsFromObject(value);
}

#pragma mark - UIDeviceOrientationDidChangeNotification selector

-(void)didRotate:(id)unused
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    BOOL shouldRotate = RL_ORIENTATION_ALLOWED(orientationFlags, orientation) || (orientationFlags == RLOrientationNone);
    
    if (shouldRotate) {
        NSTimeInterval delay = [[UIApplication sharedApplication] statusBarOrientationAnimationDuration];
        [picker willAnimateRotationToInterfaceOrientation:[[UIDevice currentDevice] orientation] duration: delay];
    }
    
    [TiLayoutQueue addViewProxy:self];
    if (overlay != nil) {
        [TiLayoutQueue addViewProxy:overlay];
    }
}

#pragma mark - Utils

RLOrientationFlags RLOrientationFlagsFromObject(id args)
{
	if (![args isKindOfClass:[NSArray class]])
	{
		return RLOrientationNone;
	}
    
	RLOrientationFlags result = RLOrientationNone;
	for (id mode in args)
	{
		UIInterfaceOrientation orientation = (UIInterfaceOrientation)[TiUtils orientationValue:mode def:-1];
		switch ((int)orientation)
		{
			case UIDeviceOrientationPortrait:
			case UIDeviceOrientationPortraitUpsideDown:
			case UIDeviceOrientationLandscapeLeft:
			case UIDeviceOrientationLandscapeRight:
				RL_ORIENTATION_SET(result,orientation);
				break;
			case UIDeviceOrientationUnknown:
				DebugLog(@"[WARN] Ti.Gesture.UNKNOWN / Ti.UI.UNKNOWN is an invalid orientation mode.");
				break;
			case UIDeviceOrientationFaceDown:
				DebugLog(@"[WARN] Ti.Gesture.FACE_DOWN / Ti.UI.FACE_DOWN is an invalid orientation mode.");
				break;
			case UIDeviceOrientationFaceUp:
				DebugLog(@"[WARN] Ti.Gesture.FACE_UP / Ti.UI.FACE_UP is an invalid orientation mode.");
				break;
			default:
				DebugLog(@"[WARN] An invalid orientation was requested. Ignoring.");
				break;
		}
	}
	return result;
}

@end
