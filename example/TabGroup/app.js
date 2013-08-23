// iOS only
var RedLaser = require('ti.redlaser');

RedLaser.addEventListener('scannerStatusUpdated', logStatusUpdate);
RedLaser.addEventListener('scannerReturnedResults', function(e) {
    // This event is iOS only.
    Ti.API.info('Received scannerReturnedResults event.');
    e.foundBarcodes.forEach(logBarcodeResult);
});

var tabGroup = Ti.UI.createTabGroup();

var win1 = Titanium.UI.createWindow({
    backgroundColor: 'red',
    title: 'Red Window'
});
var win2 = Titanium.UI.createWindow({
    backgroundColor: 'blue',
    title: 'Blue Window',
    orientationModes: [Ti.UI.PORTRAIT]
});

var cameraPreview = RedLaser.createCameraPreview({
    // The size and postion of the camera preview view can be set here
    width: '100%', 
    height: '100%',
    orientationModes: [Ti.UI.PORTRAIT]
});
win2.add(cameraPreview);

var tab1 = Ti.UI.createTab({
    title: 'red',
    window: win1
});
var tab2 = Ti.UI.createTab({
    title: 'scanner',
    window: win2
});
tabGroup.addTab(tab1);
tabGroup.addTab(tab2);

// When using a RedLaser in a TabGroup, we must call `startScanning` and
// `doneScanning` when the scanner's window is focused and blurred respectively.
win2.addEventListener('focus', function() {
    RedLaser.startScanning({
        cameraPreview: cameraPreview
    });
});
win2.addEventListener('blur', function() {
    RedLaser.doneScanning();
});

tabGroup.open();

function logBarcodeResult(barcode) {
    var locationString, barcodeInfo;
    
    barcodeInfo = 'Barcode type: ' + barcode.barcodeType + ' (' + barcode.barcodeTypeString + ')\n';
    barcodeInfo += 'Barcode string: ' + barcode.barcodeString + '\n';
    barcodeInfo += 'Extended barcode string: ' + barcode.extendedBarcodeString + '\n';
    barcodeInfo += 'First scan time: ' + barcode.firstScanTime + '\n';
    barcodeInfo += 'Most recent scan time: ' + barcode.mostRecentScanTime  + '\n';
    barcodeInfo += 'Unique ID: ' + barcode.uniqueID + '\n';

    locationString = 'Location: ';
    barcode.barcodeLocation.forEach(function(point) {
        locationString += '(' + point.x + ', ' + point.y + ') ';
    });
    barcodeInfo += locationString + '\n';
    barcodeInfo += 'Is partial barcode: ' + barcode.isPartialBarcode + '\n';

    Ti.API.info(barcodeInfo);

    Ti.API.info('Equals itself: ' + barcode.equals(barcode));
    
    if (barcode.associatedBarcode) {
        Ti.API.info('Associated barcode info:');
        logBarcodeResult(barcode.associatedBarcode);
    } else {
        Ti.API.info('No associated barcode.');
    }   
}

function logStatusUpdate(updateInfo) {
    Ti.API.info('Received status update with ' + updateInfo.newFoundBarcodes.length + ' new barcode(s).');
    Ti.API.info('guidance: ' + updateInfo.guidance);
    Ti.API.info('valid: ' + updateInfo.valid);
    Ti.API.info('inRange: ' + updateInfo.inRange);
    Ti.API.info('Number of total barcodes discovered: ' + updateInfo.foundBarcodes.length);

    if (updateInfo.newFoundBarcodes.length) {
        Ti.Media.vibrate([0, 250]);
        
        Ti.API.info('Details of newly discovered barcode(s):');
        updateInfo.newFoundBarcodes.forEach(logBarcodeResult);
    }
}