/**
 * Appcelerator Titanium Mobile Modules
 * Copyright (c) 2012-2013 by Appcelerator, Inc. All Rights Reserved.
 * Proprietary and Confidential - This source code is not for redistribution
 */

#import "RedLaserSDK.h"
#import "TiUtils.h"

#import "BarcodeResultProxy.h"
#import <QuartzCore/QuartzCore.h>

@class TiRedlaserModule;

@interface OverlayViewController : CameraOverlayViewController {
    TiRedlaserModule *module;
}

-(OverlayViewController*)initWithModule:(TiRedlaserModule*)theModule;

@end
