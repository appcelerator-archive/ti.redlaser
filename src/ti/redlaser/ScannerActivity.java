package ti.redlaser;

import java.util.ArrayList;
import java.util.Map;
import java.util.Set;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.proxy.TiViewProxy;

import ti.modules.titanium.BufferProxy;
import android.content.res.Configuration;
import android.graphics.Rect;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.FrameLayout;

import com.ebay.redlasersdk.BarcodeResult;
import com.ebay.redlasersdk.BarcodeScanActivity;

public class ScannerActivity extends BarcodeScanActivity {
	private static final String LCAT = "RedlaserModule";

	private FrameLayout previewLayout;
	private View overlayNativeView = null;

	public static ScannerActivity activeInstance = null;
	public static TiViewProxy overlayProxy = null;
	public static CameraPreviewProxy cameraPreviewProxy = null;
	public static int requestedCameraIndex = 0;
	public static Rect activeRect = null;
	public static RedlaserModule moduleInstance = null;
	public static String prefOrientation = PREF_ORIENTATION_PORTRAIT;
	
    @Override
    public void onCreate(Bundle bundle) 
    {    	    	
		activeInstance = this;

    	overlayNativeView = overlayProxy.getOrCreateView().getNativeView();
    	while (overlayNativeView.getParent() instanceof View) {
    		overlayNativeView = (View)(overlayNativeView.getParent());
    	}
    	
    	if (overlayNativeView.getParent() instanceof ViewGroup) {
    		((ViewGroup)overlayNativeView.getParent()).removeView(overlayNativeView);
    	}
    	
    	super.onCreate(bundle);
    	
    	// Here we enable all barcode types to avoid complaints and to match
    	// the default iOS behavior.
    	enabledTypes.setCodabar(true);
    	enabledTypes.setCode128(true);
    	enabledTypes.setCode39(true);
    	enabledTypes.setCode93(true);
    	enabledTypes.setDataMatrix(true);
    	enabledTypes.setEan13(true);
    	enabledTypes.setEan2(true);
    	enabledTypes.setEan5(true);
    	enabledTypes.setEan8(true);
    	enabledTypes.setITF(true);
    	enabledTypes.setQRCode(true);
    	enabledTypes.setRSS14(true);
    	enabledTypes.setSticky(true);
    	enabledTypes.setUpce(true);
    	
        requestCameraIndex(requestedCameraIndex);
		
		previewLayout = new FrameLayout(this);
		setContentView(previewLayout);
    }
    
    @Override
    public void onStart() 
    {    	    	
    	super.onStart();
    }
    
	@Override
	protected void onResume() {
		super.onResume();

		previewLayout.addView(overlayNativeView, new FrameLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));
		activeInstance = this;
		if (activeRect != null) {
			setActiveRect(activeRect);
		}
		if (moduleInstance.hasListeners("scannerActivated")) {
			moduleInstance.fireEvent("scannerActivated", null);
		}
	}

	@Override
	protected void onPause() {
		super.onPause();

		previewLayout.removeView(overlayNativeView);
		activeInstance = null;
	}

	@Override
	protected void onScanStatusUpdate(Map<String, Object> scanStatus) {
		if (moduleInstance.hasListeners("scannerStatusUpdated")) {
			KrollDict event = new KrollDict();
			ArrayList<BarcodeResultProxy> jsAllResults = new ArrayList<BarcodeResultProxy>();
			ArrayList<BarcodeResultProxy> jsNewResults = new ArrayList<BarcodeResultProxy>();
	
		    @SuppressWarnings(value = "unchecked")
			Set<BarcodeResult> allResults = (Set<BarcodeResult>) scanStatus.get(Status.STATUS_FOUND_BARCODES);
			for (BarcodeResult bcr : allResults) {
				jsAllResults.add(new BarcodeResultProxy(bcr));
			}
			event.put("foundBarcodes", jsAllResults.toArray());
	
		    @SuppressWarnings(value = "unchecked")
			Set<BarcodeResult> newResults = (Set<BarcodeResult>) scanStatus.get(Status.STATUS_NEW_FOUND_BARCODES);
			for (BarcodeResult bcr : newResults) {
				jsNewResults.add(new BarcodeResultProxy(bcr));
			}
			event.put("newFoundBarcodes", jsNewResults.toArray());
	
			event.put("inRange", scanStatus.get(Status.STATUS_IN_RANGE));
			event.put("guidance", scanStatus.get(Status.STATUS_GUIDANCE));
	
			if (scanStatus.containsKey(Status.STATUS_PARTIAL_BARCODE)) {
				event.put("partialBarcode", new BarcodeResultProxy(((BarcodeResult)scanStatus.get(Status.STATUS_PARTIAL_BARCODE))));
			}
	
			if (scanStatus.containsKey(Status.STATUS_GUIDANCE)) {
				event.put("guidance", scanStatus.get(Status.STATUS_GUIDANCE));
			}
			
			if (scanStatus.containsKey(Status.STATUS_CAMERA_SNAPSHOT)) {
				event.put("cameraSnapshot", new BufferProxy(((byte[])scanStatus.get(Status.STATUS_CAMERA_SNAPSHOT))));
			}
			moduleInstance.fireEvent("scannerStatusUpdated", event);
		}
	}

	@Override
	public String getOrientationSetting() 
	{
		return prefOrientation;
	}
	
	@Override
	protected android.widget.FrameLayout getPreviewView()
	{
		if (cameraPreviewProxy == null) {
			return super.getPreviewView();			
		} else {
			return cameraPreviewProxy.getFrameLayout();
		}
	}
	
	public void doneScanning() {
		super.doneScanning();
	}

	public void setActiveRect(Rect activeRect) {
		if (activeRect != null) {
			super.setActiveRect(activeRect);
		}
	}
	
	public boolean isTorchAvailable() {
		return super.isTorchAvailable();	
	}
	
	public void setTorch(boolean value) {
		super.setTorch(value);
	}

	public boolean getTorch() {
		return super.getTorch();
	}
	
	public void requestImageData() {
		super.requestImageData();
	}
	
	@Override
	public void onBackPressed() {
		if (moduleInstance.hasListeners("backButtonPressed")) {
			moduleInstance.fireEvent("backButtonPressed", null);
		}
	}

	@Override
	public void onCameraError(int error) {
		if (moduleInstance.hasListeners("cameraError")) {
			KrollDict event = new KrollDict();
			event.put("errorCode", error);
			moduleInstance.fireEvent("cameraError", event);
		}
	}
	
	@Override
	public void enabledBarcodeTypesChanged() {
		if (moduleInstance.hasListeners("enabledBarcodeTypesChanged")) {
			moduleInstance.fireEvent("enabledBarcodeTypesChanged", null);
		}
	}	
}
