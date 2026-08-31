# ID Capture from Uploaded Images

This sample demonstrates how to scan identity documents from **static images and PDFs** picked from the device, instead of from the live camera feed.

This is the path used by, for example, airline check-in flows where a passenger uploads a scan or photo of their passport rather than capturing it live. The Scandit Data Capture SDK does not provide an out-of-the-box UI for this, so this sample is a reference implementation showing how to wire it up correctly.

The sample covers:

- **Image upload** from Photos or the Files picker.
- **Single-sided documents** (e.g. a passport MRZ page or a national ID front) scanned from one image.
- **Double-sided documents** (e.g. a driver's license front + back), chaining two images through the SDK.
- **PDF upload** (single- and multipage), rasterising the selected page(s) before feeding them to the SDK.

## Installation

- Clone this repo locally.
- Sign in to your Developer Account at [ssl.scandit.com](http://ssl.scandit.com) and generate a license key. If you do not have an account, sign up here: [https://ssl.scandit.com/dashboard/sign-up?p=test](https://ssl.scandit.com/dashboard/sign-up?p=test).
- Replace the license key in the sample where you see `-- ENTER YOUR SCANDIT LICENSE KEY HERE --`.
- Build and run this sample on your mobile device.

## What is ID Capture?

ID Capture is a capability of Scandit's Data Capture SDK that extracts data from personal identification documents such as passports, ID cards, and driver's licenses.

## How it works

Instead of a camera, this sample feeds individual images into the SDK using [`ImageFrameSource`](https://docs.scandit.com/data-capture-sdk/ios/core/api/image-frame-source.html). The flow is:

1. The user picks an image (or PDF) from Photos or Files.
2. The file is decoded into an upright, bitmap-backed `UIImage` (PDFs are rasterised first, see below).
3. The image is wrapped in an `ImageFrameSource`, set on the `DataCaptureContext`, and switched on, which emits the frame to `IdCapture`.
4. The captured (or rejected) document is reported asynchronously through the `IdCaptureListener`.

The relevant code lives in:

- `ScanViewController.swift`: configuring and driving `IdCapture`, feeding frames, and orchestrating the single- vs double-sided flow.
- `DocumentPicker.swift`: presenting the Photos and Files pickers and turning the picked file into image(s).
- `Extensions/UIImage+DocumentImage.swift`: decoding picked images and rasterising PDF pages into SDK-ready images.
- `Result/ResultViewController.swift`: displaying the captured document's fields.

### Single-sided vs double-sided documents

An `ImageFrameSource` wraps a single image. The `DataCaptureContext` only keeps one in-flight frame, so the back side of a document must be fed **only after the front has actually been captured**, feeding it earlier would discard the front frame.

To make this work, the sample:

- Configures the scanner per document: a `SingleSideScanner` for one image, a `FullDocumentScanner` for two.
- Enables per-side notifications (`notifyOnSideCapture`) so `didCapture` fires once for the front side with `isCapturingComplete == false`, which is the signal to feed the back image. `IdCapture` then combines both sides and reports the complete document.

### Common pitfalls handled in this sample

- **Frames can be dropped before the mode is ready.** The sample sets `repeats = true` on the frame source, so the image is re-emitted until the sample switches the source off, which it does once `IdCapture` reports a result or the 10 s timeout fires.
- **EXIF orientation.** Photos from a camera or gallery often carry an orientation flag, so the sample redraws each image upright into a bitmap before feeding it.
- **Large images.** Very large photos are downscaled (longest side capped at 4096 px) to bound memory use.
- **No `DataCaptureView`.** With no view to surface context status, the sample listens for `DataCaptureContext` status changes itself to report license and context errors.

### PDF conversion

The SDK intentionally does not bundle a PDF-to-image converter, to keep its size down. This sample uses Core Graphics' built-in [`CGPDFDocument`](https://developer.apple.com/documentation/coregraphics/cgpdfdocument), which is part of the platform and so adds no third-party dependency.

Pages are rendered at 200 DPI for legible text (longest side capped at 4096 px) onto a white background, since PDF pages can be transparent and document detection expects an opaque image. For a multi-page PDF, the sample treats the second page as the back side of a double-sided document. See `Extensions/UIImage+DocumentImage.swift`.

## AI Coding Skills

Use the matching Scandit skill to get AI-assisted help for this sample. Install the Scandit skills collection once, then invoke the id-capture-ios skill.

[![Install via skills.sh](https://img.shields.io/badge/skills.sh-install-green)](https://skills.sh/scandit/skills)
[![Install in Cursor](https://img.shields.io/badge/Install%20in-Cursor-blue?style=flat-square&logo=cursor)](https://cursor.com/marketplace/scandit)

## Documentation

ID Capture is an API of the Scandit Data Capture SDK. Our SDK is supported on most popular frameworks.

Get started with ID Capture on [iOS](https://docs.scandit.com/data-capture-sdk/ios/id-capture/intro.html), [Android](https://docs.scandit.com/data-capture-sdk/android/id-capture/intro.html).

For all data capture functionality across frameworks, see documentation:

[iOS](https://docs.scandit.com/data-capture-sdk/ios/index.html), [Android](https://docs.scandit.com/data-capture-sdk/android/index.html), [Web](https://docs.scandit.com/data-capture-sdk/web/index.html), [Cordova](https://docs.scandit.com/data-capture-sdk/cordova/index.html), .NET ([iOS](https://docs.scandit.com/data-capture-sdk/dotnet.ios/index.html), [Android](https://docs.scandit.com/data-capture-sdk/dotnet.android/index.html)), [React Native](https://docs.scandit.com/data-capture-sdk/react-native/index.html), [Flutter](https://docs.scandit.com/data-capture-sdk/flutter/index.html), [Capacitor](https://docs.scandit.com/data-capture-sdk/capacitor/index.html)

## Trial Signup

To add ID Capture to your app, sign up for your Scandit Developer Account and get instant access to your license key: [https://ssl.scandit.com/dashboard/sign-up?p=test](https://ssl.scandit.com/dashboard/sign-up?p=test)

## Support

Our support engineers can be reached at [support@scandit.com](mailto:support@scandit.com).

## License

[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0)
