//
//  CameraPreview.java
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

import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiUIView;

import android.widget.FrameLayout;

public class CameraPreview extends TiUIView {

	FrameLayout frameLayout;
	
	public CameraPreview(TiViewProxy proxy) {
		super(proxy);
		
		frameLayout = new FrameLayout(proxy.getActivity());
		setNativeView(frameLayout);
	}
	
	public FrameLayout getFrameLayout() {
		return frameLayout;
	}

}
