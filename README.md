# TWCameraView

A simple & easy-to-use iOS camera wrapper, written in Swift 3. Currently supports taking still photos.

## Why?

There's often a lot of boilerplate code required when building a custom camera in iOS. For example, dealing with orientation when taking photos using `AVCaptureSession`, `AVCapturePhotoOutput` and `AVCaptureVideoPreviewLayer` can be painful. This framework aims to do the work for you.

To help simplify the interface, this framework presumes the device has both a front and back camera.

## Usage

First, import TWCameraView:

```
import TWCameraView
```

Next, initialise the view, set the delegate, and start the preview:

```
let cameraView = TWCameraView()
cameraView.delegate = self
self.view.addSubview(cameraView)
        
cameraView.startPreview(requestPermissionIfNeeded: true)
```
Setting the `requestPermissionIfNeeded` flag automatically asks the user for camera permission, and starts the preview session if granded. If you pass false, and no permission has been granted, the preview will not start. Remember to set `NSCameraUsageDescription` in your Info.plist – this will be displayed in the permission alert.

To take a photo, just call `capturePhoto()`:

```
cameraView.capturePhoto()
```
or
```
cameraView.capturePhoto(imageStabilization: true, flashMode: .off)
```

The delegate callback function `cameraViewDidCaptureImage(image: UIImage, cameraView: TWCameraView)` will be called with the output UIImage.

### Front or back camera?

TWCameraView supports either camera, but default to back. Just set the `cameraType` setting:

```
self.cameraView?.cameraType = .front
```
or
```
self.cameraView?.cameraType = .back
```

## Licence
The MIT License (MIT)
