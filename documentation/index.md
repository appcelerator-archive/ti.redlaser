# RedLaser Module

## Description

This module makes the RedLaser API available to Titanium developers.

## Licensing

You will need to add a RedLaser license file to your app to be able to use
the RedLaser module beyond the free trial. The license for Titanium apps is
the same and is created the same way ([on the RedLaser development portl](http://redlaser.com/developers/portal/))
as for native apps. 

The license file will have to be added to the Titanium app project in Titanium
Studio. For iOS, the file must be placed under the _Resources_ directory. For
Android, the file must be placed under the _platform/android/bin/assets_ directory,
where _platform_ is at the same level as _Resources_.

Note that it may take some time, in extreme cases up to 48 hours,
for a newly generated license to become active. During this time you may receive
error messages indicating a problem with the license file, even though there
is nothing wrong with the file or its placement.

## Accessing the RedLaser Module

To access this module from JavaScript, you would do the following:

	var RedLaser = require("ti.redlaser");

The RedLaser variable is a reference to the Module object.	

## Usage

The following is a simple example of how to use the RedLaser module:

	RedLaser.addEventListener('scannerActivated', function() {
		// Change settings such as supported barcode types here.
	});

	RedLaser.addEventListener('scannerStatusUpdated', function(updateInfo) {
		// Digest results returned by the RedLaser SDK here.
	});

	overlayView = Ti.UI.createView({...});
	
	RedLaser.startScanning({
		overlay: overlayView,
	});


The _startScanning_ function brings up the camera preview and starts
the scanning operation. The _scannerActivated_ event is sent when the
scanner becomes active. This is an important event because many of
the scanner's settings can only be queried and changed while the scanner
is active.

The _overlay_ parameter of the _startScanning_ function can be used
to specify a Titanium view that will be applied to the camera preview
screen as an overlay. The purpose of this overlay is to provide a user
interface while the scanner is active; the RedLaser SDK itself does not
provide any user interface for the scanner. Although this parameter is
optional, in practice it will be almost always necessary to provide
some kind of user interface.
 
Once the scanner is active, it sends _scannerStatusUpdated_
messages at regular intervals (several times a second -- not only when
new barcodes are discovered). The discovered barcodes are attached to the
event object that the event handler function receives as parameter.

## BarcodeResult class

Barcodes are stored in instances of the _BarcodeResult_ class. It is not
possible (or necessary) to instantiate this class from JavaScript. The
BarcodeResult instances are created when the scanner discovers a barcode
and exposed to JavaScript via the _scannerStatusUpdated_ and (in the case
of iOS) the _scannerReturnedResults_ events.

### Properties and Functions of BarcodeResult objects

#### barcodeType

__Type__: Integer 

#### barcodeTypeString

__Type__: String 

#### barcodeString

__Type__: String 

#### barcodeExtendedString

__Type__: String 

#### associatedBarcode

iOS only.

__Type__: BarcodeResult

#### uniqueID

Android only.

__Type__: String

#### associatedBarcodeUUID

Android only.

__Type__: String

#### firstScanTime

__Type__: Date

#### mostRecentScanTime

__Type__: Date

#### barcodeLocation

__Type__: Array of 4 point objects, each with x and y properties.

#### getAssociatedBarcode(<array of BarcodeResult objects>)

__Return type__: BarcodeResult

#### equals(<BarcodeResult object>)

__Return type__: Boolean
 
### Properties, Functions and Events of the Module Object

#### sdkVersion

__Type__: String

#### status

Compare this to the STATUS\_XXX constants.

__Type__: Integer

#### sdkVersion

__Type__: String

#### isFlashAvailable

Only works after the scanner was started. Call _startScanner()_ first. __Read only.__

__Type__: Boolean

#### torchState

Can be used to turn flash on/off. See also _turnFlash()_. Only works after the scanner was started. Call _startScanner()_ first.

__Type__: Boolean

#### isFocusing

Only works after the scanner was started. Call _startScanner()_ first.
__iOS only.__

__Type__: Boolean

#### useFrontCamera

Only works after the scanner was started. Call _startScanner()_ first.
__iOS only.__

__Type__: Boolean

#### exposureLock

Only works after the scanner was started. Call _startScanner()_ first.
__iOS only.__

__Type__: Boolean

#### activeRect

Only works after the scanner was started. Call _startScanner()_ first.

__Type__: Rectangle object with x, y, width, and height properties of float type. 

#### orientation

Only works after the scanner was started. Call _startScanner()_ first. __iOS only.__

__Type__: Integer

#### scanCodabar

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on.

__Type__: Boolean

#### scanCode128

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on.

__Type__: Boolean

#### scanCode39

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on.

__Type__: Boolean

#### scanCode93

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on. __Android only.__

__Type__: Boolean

#### scanDataMatrix

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on.

__Type__: Boolean

#### scanEan13

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on.

__Type__: Boolean

#### scanEan2

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on.

__Type__: Boolean

#### scanEan5

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on.

__Type__: Boolean

#### scanEan8

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on.

__Type__: Boolean

#### scanITF

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on.

__Type__: Boolean

#### scanQRCode

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on.

__Type__: Boolean

#### scanRSS14

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on. __Android only.__

__Type__: Boolean

#### scanSticky

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on.

__Type__: Boolean

#### scanUPCE

Turns detection of this type of barcode on/off. By default, detection
of every supported barcode type is on.

__Type__: Boolean

#### enabledTypes

Turns detection of several barcodes on/off. By default, detection
of every supported barcode type is on. __Android only.__

__Type__: Integer

#### startScanner(<parameter object>)

Brings up the camera preview and starts the scanner.

__Parameters___

* _overlay_: A TiView object that provides a user interface while the camera
preview is active.
* _cameraPreview_: A CameraPreview object created by the createCameraPreview
function. Add this view to the overlay view. The RedLaser SDK will place the
camera preview into this view. __Android only.__
* _cameraIndex_: The index of the desired camera. __Android only.__ See
_useFrontCamera_ on iOS.
* _orientation_: Equivalent to _getOrientationSetting_. __Android only.__

__Return type__: void

#### pauseScanning()

Pauses scanning without closing the camera preview. __iOS only.__

__Return type__: void

#### resumeScanning()

Resumes scanning after it was paused with _pauseScanning()_. __iOS only.__

__Return type__: void

#### doneScanning()

Stops scanning and closes the camera preview.

__Return type__: void

#### clearResultSet()

Equivalent of _BarcodePickerController.clearResultsSet_. __iOS only.__

__Return type__: void

#### findBarcodesInBlob(<TiBlob>)

__Return type__: Array of _BarcodeResult_ objects.

#### turnFlash(boolean)

Turns the flash on/off. See also _torchState_.

__Return type__: void

#### requestCameraSnapshot([boolean])

Equivalent to _requestCameraSnapshot_ on iOS and to _requestImageData_ on Android.
The boolean parameter is for __iOS only__.

__Return type__: void

#### scannerActivated event

Fired after the _startScanner()_ function completes the initialization of the
scanner. This event does not have any properties.

#### scannerStatusUpdated event

Fired repeatedly while the scanner is running.

__Properties__:

* _foundBarcodes_: Array of _BarcodeResult_ objects, representing all the barcodes
discovered during this session.
* _newFoundBarcodes_: Array of _BarcodeResult_ objects, representing the barcodes
discovered since the last _scannerStatusUpdated_ event.
* _guidance_: Integer.
* _valid_: Boolean. __iOS only.__
* _inRange_: Boolean.
* _cameraSupportsAutofocus_: Boolean. __iOS only.__
* _partialBarcode_: __The type of this property depends on the platform.__ On iOS,
it is a string; on Android, it is a _BarcodeResult_ object.
* _cameraSnapshot_: TiBuffer object holding the image data of the camera snapshot.

__Note:__ Only the _foundBarcodes_ and _newFoundBarcodes_ properties are guaranteed
to be present.

#### scannerReturnedResults event

Fired at the end of a scanning section. __iOS only.__

__Properties__:

* _results_: Array of _BarcodeResult_ objects, representing all the barcodes
discovered during the session.

#### backButtonPressed event

Fired when the back button is pressed while the scanner is active. This event
does not have any properties. __Android only.__

#### enabledBarcodeTypesChanged event

Fired when the set of enabled barcode types is changed. This event
does not have any properties. __Android only.__

#### cameraError event

Fired when the OS reports an error with the camera. __Android only.__

__Properties__:

* _errorCode_: Integer.

### Constants

The constants listed in this section are attached to the module object.

The following constants represent barcode types:

* BARCODE\_TYPE\_CODABAR
* BARCODE\_TYPE\_CODE128
* BARCODE\_TYPE\_CODE39
* BARCODE\_TYPE\_CODE93
* BARCODE\_TYPE\_DATAMATRIX
* BARCODE\_TYPE\_EAN13
* BARCODE\_TYPE\_EAN2
* BARCODE\_TYPE\_EAN5
* BARCODE\_TYPE\_EAN8
* BARCODE\_TYPE\_ITF
* BARCODE\_TYPE\_NONE
* BARCODE\_TYPE\_QRCODE
* BARCODE\_TYPE\_RSS14
* BARCODE\_TYPE\_STICKY
* BARCODE\_TYPE\_UPCE

The following constants represent the status of the RedLaser SDK:

* STATUS\_API\_LEVEL\_TOO\_LOW
* STATUS\_EVAL\_MODE\_READY
* STATUS\_LICENSED\_MODE\_READY
* STATUS\_MISSING\_OS\_LIBS
* STATUS\_NO\_CAMERA
* STATUS\_BAD\_LICENSE
* STATUS\_SCAN\_LIMIT\_REACHED
* STATUS\_MISSING\_PERMISSIONS
* STATUS\_UNKNOWN\_STATE

## Native SDK Reference

[This page](redlaser-titanium-to-native-mapping.html) shows a comparison between
the Titanium API and the native SDKs.
 
## Author

Zsombor Papp, Logical Labs

zsombor.papp@logicallabs.com<br>
titanium@logicallabs.com

## License

TODO: Enter your license/legal information here.
