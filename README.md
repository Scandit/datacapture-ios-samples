# Available Samples

We have created both simple and advanced samples that show you how to capture barcodes and how to use Matrix Scan functionality.
The simple samples allow you to get going quickly, while the advanced samples show you how to use additional settings and setup the scanner for the best user experience.

## Barcode Capture Samples

|                        Simple Sample                        |                                 User Interface Sample                                |                                               Settings Sample                                               |
|:-----------------------------------------------------------:|:------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------------:|
|  ![alt text](/images/sample-bc-simple.jpeg?raw=true "Simple Sample")  |                                      Coming Soon                                     |                                                 Coming Soon                                                 |
| Basic sample that uses the camera to read a single barcode. | Demonstrates the various ways to best integrate the scanner into the UI of your app. | Demonstrates how you can adapt the scanner settings best to your needs and experiment with all the options. |


## MatrixScan Samples

|                                               Simple Sample                                               |                                           Advanced Sample                                           |
|:---------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------:|
|                         ![alt text](/images/sample-ms-simple.jpeg?raw=true "Simple Sample")                         |                                             Coming Soon                                             |
| Very simple sample which shows how you can highlight barcodes on screen with the Scandit Data Capture SDK. | Demonstrates the use of more advanced augmented reality use cases with the Scandit Data Capture SDK. |

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
