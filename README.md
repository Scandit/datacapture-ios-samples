# Scandit iOS Samples

This repository contains both simple and advanced samples that show you how use various features of the Scandit Data Capture SDK. The simple samples allow you to get going quickly, while the advanced samples show you how to use additional settings and setup the scanner for the best performance and user experience.

## **Pre-Built Barcode Scanning Components**

Scandit offers building blocks that can be integrated in just a few lines of code. The pre-built camera UI has been designed and user-tested to achieve superior process efficiency, ergonomics and usability.

### High-speed Single Barcode Scanning (**SparkScan)**

SparkScan is a camera-based solution for high-speed single scanning and scan-intensive workflows. It includes an out-of-the-box UI optimized for an efficient and frictionless user experience.

![SparkScan.png](https://github.com/Scandit/.github/blob/main/images/SparkScan.png)

**List Building Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/01_Single_Scanning_Samples/01_Barcode_Scanning_with_Prebuilt_UI/ListBuildingSampleUIKit))

**List Building Sample (SwiftUI)** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/01_Single_Scanning_Samples/01_Barcode_Scanning_with_Prebuilt_UI/ListBuildingSampleSwiftUI))

**ReceivingSample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/03_Advanced_Batch_Scanning_Samples/02_Counting_and_Receiving/ReceivingSample))

### Counting and Receiving in Batches (MatrixScan Count)

MatrixScan Count is an out-of-the-box scan and count solution for counting and receiving multiple items at once, in which user interface (UI) elements and interactions are built into a workflow.

![MSCount.png](https://github.com/Scandit/.github/blob/main/images/MSCount.png)

**MatrixScan Count Simple Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/03_Advanced_Batch_Scanning_Samples/02_Counting_and_Receiving/MatrixScanCountSimpleSample))

**Receiving Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/03_Advanced_Batch_Scanning_Samples/02_Counting_and_Receiving/ReceivingSample))

**Expiry Management Sample** ([iOS](Scandit%20iOS%20Samples%202246395c6e4146458347ebb7a7f5624f.md))

**MatrixScan Count Tote Mapping Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/03_Advanced_Batch_Scanning_Samples/02_Counting_and_Receiving/MatrixScanCountToteMappingSample))

### Seach for Barcodes (**MatrixScan Find)**

MatrixScan Find is a pre-built component that uses AR overlays to highlight items that match predefined criteria.

![MSFind.png](https://github.com/Scandit/.github/blob/main/images/MSFind.png)

**Seach  & Find Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/03_Advanced_Batch_Scanning_Samples/03_Search_and_Find/SearchAndFindSample))

### Scan One of Many Barcodes (Barcode Selection)

Barcode Selection is a pre-built component that provides a UI for selecting the right code when codes are crowded (and cannot be selected programmatically).

Consider Barcode Selection when **accuracy** is more important than **speed**.

- **Aim to Select** allows you to select one barcode at a time using an aimer, and tapping to confirm the selection. It is especially convenient for one-handed operation.

  ![AimToSelect.png](https://github.com/Scandit/.github/blob/main/images/AimToSelect.png)


- **Tap to select** is quicker when you need to select several barcodes, as demonstrated by the **Catalog Reordering Sample** (yep, those are teeth).

  ![TapToSelect.png](https://github.com/Scandit/.github/blob/main/images/TapToSelect.png)


**Barcode Selection Settings Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/01_Single_Scanning_Samples/02_Barcode_Scanning_with_Low_Level_API/BarcodeSelectionSettingsSample))

**Reorder from Catalog Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/03_Advanced_Batch_Scanning_Samples/02_Counting_and_Receiving/ReorderFromCatalogSample))

## Fully-flexible API

The fully-flexible API provides the camera interface, viewfinders and minimal guidance.

### ID Scanning and Verification Samples

ID Scanning Samples demonstrate the features of the ID Capture API and demonstrate workflows such as Age Verified Delivery and US Drivers’ License Verification.

![IDScanning.png](https://github.com/Scandit/.github/blob/main/images/IDScanning.png)

**ID Capture Simple Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/02_ID_Scanning_Samples/IdCaptureSimpleSample))

**Age Verified Delivery Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/02_ID_Scanning_Samples/AgeVerifiedDeliverySample))

**US Drivers’ License Verification Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/02_ID_Scanning_Samples/USDLVerificationSample))

**ID Capture Settings Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/02_ID_Scanning_Samples/IdCaptureSettingsSample))

**ID Capture Extended Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/02_ID_Scanning_Samples/IdCaptureExtendedSample))

### Barcode Capture Samples

**Barcode Capture Simple Sample** ([Swift](https://github.com/Scandit/datacapture-ios-samples/tree/master/01_Single_Scanning_Samples/02_Barcode_Scanning_with_Low_Level_API/BarcodeCaptureSimpleSampleSwift), [ObjC](https://github.com/Scandit/datacapture-ios-samples/tree/master/01_Single_Scanning_Samples/02_Barcode_Scanning_with_Low_Level_API/BarcodeCaptureSimpleSampleObjC))

**Barcode Capture Reject Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/01_Single_Scanning_Samples/02_Barcode_Scanning_with_Low_Level_API/BarcodeCaptureRejectSample))

**Barcode Capture Settings Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/01_Single_Scanning_Samples/02_Barcode_Scanning_with_Low_Level_API/BarcodeCaptureSettingsSample))

### MatrixScan AR Sam**ples**

**MatrixScan Simple Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/03_Advanced_Batch_Scanning_Samples/01_Batch_Scanning_and_AR_Info_Lookup/MatrixScanSimpleSample))

**MatrixScan Bubbles Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/03_Advanced_Batch_Scanning_Samples/01_Batch_Scanning_and_AR_Info_Lookup/MatrixScanBubblesSample))

**MatrixScan Reject Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/03_Advanced_Batch_Scanning_Samples/01_Batch_Scanning_and_AR_Info_Lookup/MatrixScanRejectSample))

**Inventory Audit Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/03_Advanced_Batch_Scanning_Samples/01_Batch_Scanning_and_AR_Info_Lookup/InventoryAuditSample))

### MatrixScan AR Samples

**MatrixScan AR Simple Sample** ([link](https://github.com/Scandit/datacapture-ios-samples/tree/master/03_Advanced_Batch_Scanning_Samples/01_Batch_Scanning_and_AR_Info_Lookup/MatrixScanARSimpleSample))

## Samples on Other Frameworks

Samples on other frameworks are located at [https://github.com/scandit](https://github.com/scandit).

## Documentation

The Scandit Data Capture SDK documentation can be found here: [iOS](https://docs.scandit.com/data-capture-sdk/ios/index.html)

## Sample Barcodes

Once you get the sample up and running, go find some barcodes to scan. Don’t feel like getting up from your desk? Here’s a [handy pdf of barcodes](https://github.com/Scandit/.github/blob/main/images/PrintTheseBarcodes.pdf) you can print out.

## Trial Signup

To add the Scandit Data Capture SDK to your app, sign up for your Scandit Developer Account  and get instant access to your license key: [https://ssl.scandit.com/dashboard/sign-up?p=test](https://ssl.scandit.com/dashboard/sign-up?p=test)

## Support

Our support engineers can be reached at [support@scandit.com](mailto:support@scandit.com).

## License

[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0)
