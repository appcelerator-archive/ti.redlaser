package ti.redlaser;

import java.util.ArrayList;
import java.util.Date;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;

import android.graphics.PointF;

import com.ebay.redlasersdk.BarcodeResult;

@Kroll.proxy
public class BarcodeResultProxy extends KrollProxy {

	private BarcodeResult myBarcodeResult;
	
	public BarcodeResultProxy(BarcodeResult bcr) {
		super();
		myBarcodeResult = bcr;
	}
	
	@Kroll.getProperty
	public Integer getBarcodeType() {
		return myBarcodeResult.barcodeType;
	}

	@Kroll.getProperty
	public String getBarcodeTypeString() {
		return myBarcodeResult.getBarcodeType();
	}

	@Kroll.getProperty
	public String getBarcodeString() {
		return myBarcodeResult.barcodeString;
	}

	@Kroll.getProperty
	public String getExtendedBarcodeString() {
		return myBarcodeResult.extendedBarcodeString;
	}

	@Kroll.getProperty
	public Date getFirstScanTime() {
		return myBarcodeResult.firstScanTime;
	}
	
	@Kroll.getProperty
	public Date getMostRecentScanTime() {
		return myBarcodeResult.mostRecentScanTime;
	}

	@Kroll.getProperty
	public String getUniqueID() {
		return myBarcodeResult.uniqueID.toString();
	}

	@Kroll.method
	public BarcodeResultProxy getAssociatedBarcode(Object[] barcodeResults) {
		ArrayList<BarcodeResult> nativeResultSet = new ArrayList<BarcodeResult>();
		
		for (int i=0; i<barcodeResults.length; i++) {
			if (barcodeResults[i] instanceof BarcodeResultProxy) {
				nativeResultSet.add(((BarcodeResultProxy)barcodeResults[i]).myBarcodeResult);
			}
		}
		
		return new BarcodeResultProxy(myBarcodeResult.getAssociatedBarcode(nativeResultSet));
	}

	@Kroll.method
	public Boolean equals(BarcodeResultProxy otherBarcodeProxcy) {
		return myBarcodeResult.equals(otherBarcodeProxcy.myBarcodeResult);
	}
	
	@Kroll.getProperty
	public String getAssociatedBarcodeUUID() {
		return myBarcodeResult.associatedBarcode.toString();
	}

	@Kroll.getProperty
	public KrollDict[] getBarcodeLocation() {
		ArrayList<KrollDict> result = new ArrayList<KrollDict>();

		for(PointF point : myBarcodeResult.barcodeLocation) {
			KrollDict jsPoint = new KrollDict();
			jsPoint.put("x", point.x);
			jsPoint.put("y", point.y);
			result.add(jsPoint);
		}
		return result.toArray(new KrollDict[result.size()]);
	}

	@Kroll.getProperty
	public boolean getIsPartialBarcode() {
		return myBarcodeResult.isPartialBarcode;
	}

	
}
