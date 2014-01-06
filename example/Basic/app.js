/*jslint sloppy:true */

var
    IOS = (Ti.Platform.osname === 'iphone' || Ti.Platform.osname === 'ipad'),
    ANDROID = Ti.Platform.osname === 'android',
    defaultInfoText,
    RedLaser, win, startScanningButton,
    overlayView, doneButton, pauseButton, resumeButton, torchButton, swapButton,
    cameraPreview, cameraIndexLabel, cameraIndexField,
    snapshotButton, snapshotImageView, infoTextField
;

RedLaser = require('ti.redlaser');

// Constants

Ti.API.info('BARCODE_TYPE_CODABAR:' + RedLaser.BARCODE_TYPE_CODABAR);
Ti.API.info('BARCODE_TYPE_CODE128:' + RedLaser.BARCODE_TYPE_CODE128);
Ti.API.info('BARCODE_TYPE_CODE39:' + RedLaser.BARCODE_TYPE_CODE39);
Ti.API.info('BARCODE_TYPE_CODE93:' + RedLaser.BARCODE_TYPE_CODE93);
Ti.API.info('BARCODE_TYPE_DATAMATRIX:' + RedLaser.BARCODE_TYPE_DATAMATRIX);
Ti.API.info('BARCODE_TYPE_EAN13:' + RedLaser.BARCODE_TYPE_EAN13);
Ti.API.info('BARCODE_TYPE_EAN2:' + RedLaser.BARCODE_TYPE_EAN2);
Ti.API.info('BARCODE_TYPE_EAN5:' + RedLaser.BARCODE_TYPE_EAN5);
Ti.API.info('BARCODE_TYPE_EAN8:' + RedLaser.BARCODE_TYPE_EAN8);
Ti.API.info('BARCODE_TYPE_GS1DATABAR:' + RedLaser.BARCODE_TYPE_GS1DATABAR);
Ti.API.info('BARCODE_TYPE_GS1DATABAR_EXPANDED:' + RedLaser.BARCODE_TYPE_GS1DATABAR_EXPANDED);
Ti.API.info('BARCODE_TYPE_ITF:' + RedLaser.BARCODE_TYPE_ITF);
Ti.API.info('BARCODE_TYPE_NONE:' + RedLaser.BARCODE_TYPE_NONE);
Ti.API.info('BARCODE_TYPE_PDF417:' + RedLaser.BARCODE_TYPE_PDF417);
Ti.API.info('BARCODE_TYPE_QRCODE:' + RedLaser.BARCODE_TYPE_QRCODE);
Ti.API.info('BARCODE_TYPE_RSS14:' + RedLaser.BARCODE_TYPE_RSS14);
Ti.API.info('BARCODE_TYPE_STICKY:' + RedLaser.BARCODE_TYPE_STICKY);
Ti.API.info('BARCODE_TYPE_UPCE:' + RedLaser.BARCODE_TYPE_UPCE);
Ti.API.info('STATUS_API_LEVEL_TOO_LOW:' + RedLaser.STATUS_API_LEVEL_TOO_LOW);
Ti.API.info('STATUS_EVAL_MODE_READY:' + RedLaser.STATUS_EVAL_MODE_READY);
Ti.API.info('STATUS_LICENSED_MODE_READY:' + RedLaser.STATUS_LICENSED_MODE_READY);
Ti.API.info('STATUS_MISSING_OS_LIBS:' + RedLaser.STATUS_MISSING_OS_LIBS);
Ti.API.info('STATUS_NO_CAMERA:' + RedLaser.STATUS_NO_CAMERA);
Ti.API.info('STATUS_BAD_LICENSE:' + RedLaser.STATUS_BAD_LICENSE);
Ti.API.info('STATUS_SCAN_LIMIT_REACHED:' + RedLaser.STATUS_SCAN_LIMIT_REACHED);
Ti.API.info('STATUS_MISSING_PERMISSIONS:' + RedLaser.STATUS_MISSING_PERMISSIONS);
Ti.API.info('STATUS_UNKNOWN_STATE:' + RedLaser.STATUS_UNKNOWN_STATE);

var firstDiscoveredBarcode;

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

    infoTextField.value = barcodeInfo;
    Ti.API.info(barcodeInfo);

    Ti.API.info('Equals itself: ' + barcode.equals(barcode));
    if (firstDiscoveredBarcode) {
        Ti.API.info('Equals first discovered barcode: ' + barcode.equals(firstDiscoveredBarcode));
    } else {
        firstDiscoveredBarcode = barcode;
    }
    
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
        overlayView.animate({ backgroundColor: 'red', duration: 250}, function() {
            overlayView.backgroundColor = 'transparent';
        });

        Ti.API.info('Details of newly discovered barcode(s):');
        updateInfo.newFoundBarcodes.forEach(logBarcodeResult);
    }
    
    if (updateInfo.partialBarcode) {
        if (ANDROID) {
            // On Android, the partialBarcode property is a BarcodeResult(Proxy)
            // object.
            Ti.API.info('Received partial barcode: ');
            logBarcodeResult(updateInfo.partialBarcode);
        }
        if (IOS) {
            // On iOS, the partialBarcode property is a string.
            Ti.API.info('Received partial barcode: ' + updateInfo.partialBarcode);
        }
    }
    
    if (updateInfo.cameraSnapshot) {
        Ti.API.info('Camera snapshot received length: ' + updateInfo.cameraSnapshot.length);
        snapshotImageView.image = updateInfo.cameraSnapshot.toBlob();
    }
}

RedLaser.addEventListener('scannerStatusUpdated', logStatusUpdate);
RedLaser.addEventListener('scannerReturnedResults', function(e) {
    // This event is iOS only.
    Ti.API.info('Received scannerReturnedResults event.');
    e.foundBarcodes.forEach(logBarcodeResult);
});

win = Ti.UI.createWindow({
    backgroundColor: 'black',
    orientationModes: [Ti.UI.PORTRAIT]
});

overlayView = Ti.UI.createView({
    borderColor: 'blue', borderWidth: 3
});

cameraPreview = RedLaser.createCameraPreview({
    // The size and postion of the camera preview view can be set here
    width: '100%', 
    height: '100%',
    // orientationModes: iOS only
    // Should be set to the same orientations as the window it is added to
    orientationModes: [Ti.UI.PORTRAIT]
});

if (ANDROID) {
    cameraIndexLabel = Ti.UI.createLabel({
        color: 'black', backgroundColor: 'white',
        text: 'Camera index: ',
        bottom: '15%', left: '3%', height: '10%', width: '30%'
    });
    
    cameraIndexField = Ti.UI.createTextField({
        bottom: '15%', left: '35%', height: '10%', width: '30%'
    });
    
    win.add(cameraIndexLabel);
    win.add(cameraIndexField);
    overlayView.add(cameraPreview); // Android Only: The preview view is added to the overlayView
}

doneButton = Ti.UI.createButton({
    width: '30%', height: '10%', bottom: '3%', left: '2%',
    title: 'Done'
});

doneButton.addEventListener('click', function() {
    RedLaser.doneScanning();
    if (IOS) {
        win.remove(cameraPreview);
        pauseButton.enabled = true;
        resumeButton.enabled = false;
    }
});

overlayView.add(doneButton);

if (IOS) {
    // Pause/resume/camera swap function is not available on Android 
    swapButton = Ti.UI.createButton({
        width: '30%', height: '10%', top: '3%', left: '34%',
        title: 'Swap'
    });
    
    swapButton.addEventListener('click', function() {
        RedLaser.useFrontCamera = !RedLaser.useFrontCamera; 
    });
    
    overlayView.add(swapButton);
    
    pauseButton = Ti.UI.createButton({
        width: '30%', height: '10%', bottom: '3%', left: '34%',
        title: 'Pause'
    });
    
    pauseButton.addEventListener('click', function() {
        pauseButton.enabled = false;
        RedLaser.pauseScanning();
        resumeButton.enabled = true;
    });
    
    overlayView.add(pauseButton);
    
    resumeButton = Ti.UI.createButton({
        width: '30%', height: '10%', bottom: '3%', left: '66%',
        title: 'Resume',
        enabled: false
    });
    
    resumeButton.addEventListener('click', function() {
        resumeButton.enabled = false;
        RedLaser.resumeScanning();
        pauseButton.enabled = true;
    });
    
    overlayView.add(resumeButton);
}

torchButton = Ti.UI.createButton({
    width: '30%', height: '10%', top: '3%', left: '66%',
    title: 'Toggle torch'
});

torchButton.addEventListener('click', function() {
    RedLaser.torchState = !RedLaser.torchState;
});

overlayView.add(torchButton);

snapshotButton = Ti.UI.createButton({
    width: '30%', height: '10%', top: '3%', left: '2%',
    title: 'Snapshot'
});

snapshotButton.addEventListener('click', function() {
    RedLaser.requestCameraSnapshot();
});

overlayView.add(snapshotButton);

snapshotImageView = Ti.UI.createImageView({
    bottom: '15%', right: '2%', height: '40%', width: '30%',
    borderColor: 'yellow', borderWidth: 2
});

win.add(snapshotImageView);

RedLaser.addEventListener('scannerActivated', function() {
    Ti.API.info('scannerActivated event received.');

    if (RedLaser.isFlashAvailable) {
        torchButton.enabled = true;
        torchButton.title = 'Toggle torch';
    } else {
        torchButton.enabled = false;
        torchButton.title = 'No torch';
    }
    
    // All barcode types are enabled by default. 
    // Turning some of them off can improve performance.
    // RedLaser.scanCodabar = false;
    // RedLaser.scanCode39 = false;
    // RedLaser.scanCode93 = false;
    // RedLaser.scanDataMatrix = false;
    // RedLaser.scanEan2 = false;
    // RedLaser.scanEan5 = false;
    // RedLaser.scanEan8 = false;
    // RedLaser.scanITF = false;
    // RedLaser.scanRSS14 = false;
});

RedLaser.addEventListener('backButtonPressed', function (e) {
    // This is an Android only event but it doesn't do any harm to define
    // a handler for it on either platform.
    Ti.API.info('backButtonPressed event received.');
    RedLaser.doneScanning();
});

RedLaser.addEventListener('enabledBarcodeTypesChanged', function() {
    // This is an Android only event but it doesn't do any harm to define
    // a handler for it on either platform.
    Ti.API.info('enabledBarcodeTypesChanged event received.');
});

RedLaser.addEventListener('cameraError', function(e) {
    // This is an Android only event but it doesn't do any harm to define
    // a handler for it on either platform.
    Ti.API.info('cameraError event received. Code: ' + e.errorCode);
});

Titanium.UI.setBackgroundColor('#000');

startScanningButton = Ti.UI.createButton({
    title: 'Start scanning',
    width: '70%', height: '10%',
    bottom: '3%'
});

startScanningButton.addEventListener('click', function() {
    if (IOS) {
        // iOS Only: `cameraPreview` added to the window before calling `startScanning`
        win.add(cameraPreview);
    }
    RedLaser.startScanning({
        overlay: overlayView,
        orientation: RedLaser.PREF_ORIENTATION_PORTRAIT,
        cameraPreview: cameraPreview,
        cameraIndex: cameraIndexField ? parseInt(cameraIndexField.value, 10) : undefined
    });
});

win.add(startScanningButton);

defaultInfoText = '';
defaultInfoText += '\nRedLaser status code: ' + RedLaser.status;
defaultInfoText += '\nRedLaser version: ' + RedLaser.sdkVersion;
defaultInfoText += '\nInfo about last scanned barcode will be shown here.';

infoTextField = Ti.UI.createTextArea({
    color: 'black',
    backgroundColor: 'white',
    value: defaultInfoText,
    height: '55%', width: '100%', top: 0,
    editable: false,
    font: { fontsize: 16 }
});

win.add(infoTextField);

win.open();