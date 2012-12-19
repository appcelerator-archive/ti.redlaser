//
//  OverlayViewController.h
//  redlaser
//
//  Created by Zsombor Papp on 11/1/12.
//
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
