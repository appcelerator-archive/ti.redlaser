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
