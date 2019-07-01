# Available Samples

We have created both simple and advanced samples that show you how to capture barcodes and how to use Matrix Scan functionality.
The simple samples allow you to get going quickly, while the advanced samples show you how to use additional settings and setup the scanner for the best user experience.

## Barcode Capture Samples

|                               Simple Sample                              |                                View Sample                               |                             Settings Sample                              |
|:------------------------------------------------------------------------:|:------------------------------------------------------------------------:|:------------------------------------------------------------------------:|
| ![alt text](/images/sample-bc-simple.jpeg?raw=true "Simple Sample") | ![alt text](/images/sample-bc-view-1.jpeg?raw=true "View Sample") ![alt text](/images/sample-bc-view-2.jpeg?raw=true "View Sample") | ![alt text](/images/sample-bc-settings-1.jpeg?raw=true "Settings Sample") ![alt text](/images/sample-bc-settings-2.png?raw=true "Settings Sample") |
 Basic sample that uses the camera to read a single barcode.              | Demonstrates the various ways to best integrate the scanner into the UI of your app. | Demonstrates how you can adapt the scanner settings best to your needs and experiment with all the options. |


## MatrixScan Samples

|                               Reject Sample                              |                               Bubble Sample                              |                          Search And Find Sample                          |
|:------------------------------------------------------------------------:|:------------------------------------------------------------------------:|:------------------------------------------------------------------------:|
| ![alt text](/images/sample-ms-simple.jpeg?raw=true "Simple Sample") | ![alt text](/images/sample-ms-bubble.jpeg?raw=true "Bubble Sample") | ![alt text](/images/sample-ms-saf-1.jpeg?raw=true "Search") ![alt text](/images/sample-ms-saf-2.jpeg?raw=true "Find") |
| Sample which shows how you can highlight selected (by a custom condition) barcodes on screen with the Scandit Data Capture SDK. | Demonstrates the use of more advanced augmented reality use cases with the Scandit Data Capture SDK. | Demonstrates a use case that requires a consecutive use of both Barcode Capture and MatrixScan in a single app. |

# Run the Samples

The best way to start working with the Scandit Data Capture SDK is to run one of our sample apps.

Before you can run a sample app, you need to go through a few simple steps:

  1. Clone or download the samples repository.
  
  2. Sign in to your Scandit account and download the newest iOS Framework at <https://ssl.scandit.com/sdk/>. Unzip the archive and copy the `frameworks` directory into the parent directory of the one with all the samples. It should look like this:
  
  ![alt text](/images/samples-libs-setup.png?raw=true "Frameworks setup")
  
  3. Open the project file in Xcode. Make sure you always have the most recent version of Xcode installed.
  
  4. Set the license key. To do this, sign in to your Scandit account and find your license key at <https://ssl.scandit.com/licenses/>`. Once you have the license key, add it to the sample:
  
  ```swift
  extension DataCaptureContext {
      private static let licenseKey = "-- ENTER YOUR SCANDIT LICENSE KEY HERE --"

      // Get a licensed DataCaptureContext
      static let licensed = DataCaptureContext(licenseKey: licenseKey)
  }
  ```
  
  5. Run the sample in Xcode by clicking the Play button. We recommend running our samples on a physical device as otherwise no camera is available.


# Troubleshooting

## Code Signing
	Code Sign error: No matching provisioning profiles found: No provisioning profiles with a valid signing identity (i.e. certificate and private key pair) matching the bundle identifier "" were found.
	
Try to disable and enable again the `Automatic manage signing` settings in Xcode. You might want to change the bundle id.

For more code signing troubleshooting please refer to the [Apple developer support page](https://help.apple.com/xcode/mac/current/#/dev60b6fbbc7)
