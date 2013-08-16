# Ti.RedLaser.CameraPreview

## Description
Creates a view where the camera preview can be displayed. 

__Android only:__ Add this view to the overlay view. The RedLaser SDK will place the
camera preview into this view.

__iOS only:__ Add this view to a parent view or window before calling _startScanning_.
If cameraPreview is not passed to _startScanning_, a scanner window will be opened. 

## Properties

Has the same properties as a standard [Ti.UI.View][], plus the ones listed below

### orientationModes[Number[]]

__iOS only__ 

Array of supported orientation modes, specified using the orientation constants defined in [Ti.UI][].

If orientationModes is not set or is set to an empty array, the CameraPreview will rotate in every orientation.
To restrict this CameraPreview to a certain set of orientations, specify one or more of the orientation constants [Ti.UI.LANDSCAPE_LEFT][], [Ti.UI.LANDSCAPE_RIGHT][], [Ti.UI.PORTRAIT][], [Ti.UI.UPSIDE_PORTRAIT][].

In most cases it is desirable to set the _orientationModes_ of the CameraPreview to the same orientations as its containing window.

If the cameraPreview view is added to a [Ti.UI.TabGroup][] it is necessary to call 
`startScanning` and `doneScanning` when the tab is focused and blured respectively.
See the example app `TabGroup/app.js`.

#### Example

	var win = Ti.UI.createWindow({
	    backgroundColor: 'black',
	    orientationModes: [Ti.UI.PORTRAIT, Ti.UI.LANDSCAPE_LEFT]
	});

	var cameraPreview = RedLaser.createCameraPreview({
		orientationModes: [Ti.UI.PORTRAIT, Ti.UI.LANDSCAPE_LEFT]
	});

[Ti.UI]: http://docs.appcelerator.com/titanium/latest/#!/api/Titanium.UI
[Ti.UI.View]: http://docs.appcelerator.com/titanium/latest/#!/api/Titanium.UI.View
[Ti.UI.TabGroup]: http://docs.appcelerator.com/titanium/latest/#!/api/Titanium.UI.TabGroup
[Ti.UI.LANDSCAPE_LEFT]: http://docs.appcelerator.com/titanium/latest/#!/api/Titanium.UI-property-LANDSCAPE_LEFT
[Ti.UI.LANDSCAPE_RIGHT]: http://docs.appcelerator.com/titanium/latest/#!/api/Titanium.UI-property-LANDSCAPE_RIGHT
[Ti.UI.PORTRAIT]: http://docs.appcelerator.com/titanium/latest/#!/api/Titanium.UI-property-PORTRAIT
[Ti.UI.UPSIDE_PORTRAIT]: http://docs.appcelerator.com/titanium/latest/#!/api/Titanium.UI-property-UPSIDE_PORTRAIT