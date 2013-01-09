//
//  OverlayViewController.h
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

#import "RedLaserSDK.h"
#import "TiUtils.h"

#import "BarcodeResultProxy.h"
#import <QuartzCore/QuartzCore.h>

@class TiRedlaserModule;

@interface OverlayViewController : CameraOverlayViewController {
    CAShapeLayer				*targetLine;
}

@property (readonly, retain) TiRedlaserModule *module;

-(OverlayViewController*)initWithModule:(TiRedlaserModule*)theModule;

@end
