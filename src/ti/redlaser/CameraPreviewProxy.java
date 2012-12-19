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
