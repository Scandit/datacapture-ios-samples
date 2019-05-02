/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#import "ViewController.h"

@import ScanditBarcodeCapture;

static NSString *const _Nonnull licenseKey = @"-- ENTER YOUR SCANDIT LICENSE KEY HERE --";

@implementation SDCDataCaptureContext (Licensed)

// Get a licensed DataCaptureContext.
+ (SDCDataCaptureContext *)licensedDataCaptureContext {
    return [self contextForLicenseKey:licenseKey];
}

@end

@interface ViewController () <SDCBarcodeCaptureListener>

@property (strong, nonatomic) SDCDataCaptureContext *context;
@property (strong, nonatomic, nullable) SDCCamera *camera;
@property (strong, nonatomic) SDCBarcodeCapture *barcodeCapture;
@property (strong, nonatomic) SDCDataCaptureView *captureView;
@property (strong, nonatomic) SDCBarcodeCaptureOverlay *overlay;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRecognition];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Switch camera on to start streaming frames. The camera is started asynchronously and will
    // take some time to completely turn on.
    self.barcodeCapture.enabled = YES;
    [self.camera switchToDesiredState:SDCFrameSourceStateOn];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will
    // take some time to completely turn off. Until it is completely stopped, it is still possible
    // to receive further results, hence it's a good idea to first disable barcode capture as well.
    self.barcodeCapture.enabled = NO;
    [self.camera switchToDesiredState:SDCFrameSourceStateOff];
}

- (void)setupRecognition {
    // Create data capture context using your license key.
    self.context = [SDCDataCaptureContext licensedDataCaptureContext];

    // Use the world-facing (back) camera and set it as the frame source of the context. The camera
    // is off by default and must be turned on to start streaming frames to the data capture context
    // for recognition. See viewWillAppear and viewDidDisappear above.
    self.camera = SDCCamera.defaultCamera;
    [self.context setFrameSource:self.camera completionHandler:nil];

    // The barcode capturing process is configured through barcode capture settings that first need
    // to be configured and are then applied to the barcode capture instance that manages barcode
    // recognition.
    SDCBarcodeCaptureSettings *settings = [SDCBarcodeCaptureSettings settings];

    // The settings instance initially has all types of barcodes (symbologies) disabled. For the
    // purpose of this sample we enable a very generous set of symbologies. In your own app ensure
    // that you only enable the symbologies that your app requires as every additional symbology
    // enabled has an impact on processing times.
    [settings setSymbology:SDCSymbologyEAN13UPCA enabled:YES];
    [settings setSymbology:SDCSymbologyEAN8 enabled:YES];
    [settings setSymbology:SDCSymbologyUPCE enabled:YES];
    [settings setSymbology:SDCSymbologyQR enabled:YES];
    [settings setSymbology:SDCSymbologyDataMatrix enabled:YES];
    [settings setSymbology:SDCSymbologyCode39 enabled:YES];
    [settings setSymbology:SDCSymbologyCode128 enabled:YES];
    [settings setSymbology:SDCSymbologyInterleavedTwoOfFive enabled:YES];

    // Some linear/1d barcode symbologies allow you to encode variable-length data. By default, the
    // Scandit DataCapture SDK only scans barcodes in a certain length range. If your application
    // requires scanning of one of these symbologies, and the length is falling outside the default
    // range, you may need to adjust the "active symbol counts" for this symbology. This is shown in
    // the following few lines of code for one of the variable-length symbologies.
    SDCSymbologySettings *symbologySettings = [settings settingsForSymbology:SDCSymbologyCode39];
    symbologySettings.activeSymbolCounts = [NSSet
        setWithObjects:@7, @8, @9, @10, @11, @12, @13, @14, @15, @16, @17, @18, @19, @20, nil];

    // Create new barcode capture mode with the settings from above.
    self.barcodeCapture = [SDCBarcodeCapture barcodeCaptureWithContext:self.context
                                                              settings:settings];

    // Register self as a listener to get informed whenever a new barcode got recognized.
    [self.barcodeCapture addListener:self];

    // To visualize the on-going barcode capturing process on screen, setup a data capture view that
    // renders the camera preview. The view must be connected to the data capture context.
    self.captureView = [[SDCDataCaptureView alloc] initWithFrame:self.view.bounds];
    self.captureView.dataCaptureContext = self.context;
    self.captureView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                        UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.captureView];

    // Add a barcode capture overlay to the data capture view to render the location of captured
    // barcodes on top of the video preview. This is optional, but recommended for better visual
    // feedback.
    self.overlay = [SDCBarcodeCaptureOverlay overlayWithBarcodeCapture:self.barcodeCapture];
    self.overlay.viewfinder = [SDCRectangularViewfinder viewfinder];
    [self.captureView addOverlay:self.overlay];
}

- (void)showResult:(nonnull NSString *)result completion:(nonnull void (^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:result
                             message:nil
                      preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *_Nonnull action) {
                                                    completion();
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

// MARK: - SDCBarcodeCaptureListener

- (void)barcodeCapture:(SDCBarcodeCapture *)barcodeCapture
      didScanInSession:(SDCBarcodeCaptureSession *)session
             frameData:(id<SDCFrameData>)frameData {
    SDCBarcode *barcode = [session.newlyRecognizedBarcodes firstObject];
    if (barcode == nil || barcode.data == nil) {
        return;
    }

    // Stop recognizing barcodes for as long as we are displaying the result. There won't be any new
    // results until the capture mode is enabled again. Note that disabling the capture mode does
    // not stop the camera, the camera continues to stream frames until it is turned off.
    self.barcodeCapture.enabled = NO;

    // If you are not disabling barcode capture here and want to continue scanning, consider
    // setting the codeDuplicateFilter when creating the barcode capture settings to around 500
    // or even -1 if you do not want codes to be scanned more than once.

    // Get the human readable name of the symbology and assemble the result to be shown.
    NSString *symbology =
        [[SDCSymbologyDescription alloc] initWithSymbology:barcode.symbology].readableName;
    NSString *result = [NSString stringWithFormat:@"Scanned %@ (%@)", barcode.data, symbology];

    __weak ViewController *weakSelf = self;
    [self showResult:result
          completion:^{
              // Enable recognizing barcodes when the result is not shown anymore.
              weakSelf.barcodeCapture.enabled = YES;
          }];
}

@end
