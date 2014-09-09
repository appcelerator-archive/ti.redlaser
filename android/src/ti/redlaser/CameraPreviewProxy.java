//
//  CameraPreviewProxy.java
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

package ti.redlaser;

import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiUIView;

import android.app.Activity;
import android.widget.FrameLayout;

@Kroll.proxy(creatableInModule=RedlaserModule.class, propertyAccessors = {})
public class CameraPreviewProxy extends TiViewProxy {

	@Override
	public TiUIView createView(Activity arg0) {
		// TODO Auto-generated method stub
		return new CameraPreview(this);
	}

	public FrameLayout getFrameLayout() {
		return ((CameraPreview) getOrCreateView()).getFrameLayout();
	}

}
