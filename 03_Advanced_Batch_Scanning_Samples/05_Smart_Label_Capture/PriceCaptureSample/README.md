# Price Capture with Smart Label Capture

This sample shows how to verify shelf prices by capturing a product barcode and the printed price from a price label in a single shot, using Smart Label Capture's pre-built `priceCapture` definition.

The captured `(barcode, price)` pair is compared against a reference database bundled with the app, and the price label is highlighted with the validation result: a colored box around the price field plus a floating status pin.

| State     | Color  | Pin | Meaning                                                       |
| --------- | ------ | --- | ------------------------------------------------------------- |
| Correct   | green  | ✓   | Barcode found in the database and the captured price matches. |
| Incorrect | red    | ✕   | Barcode found in the database but the captured price differs. |
| Unknown   | yellow | !   | Barcode not present in the database.                          |

## Installation

- Clone this repo locally.
- Sign in to your Developer Account at [ssl.scandit.com](http://ssl.scandit.com) and generate a license key.  If you do not have an account, sign up here: [https://ssl.scandit.com/dashboard/sign-up?p=test](https://ssl.scandit.com/dashboard/sign-up?p=test).
- Replace the license key in the sample where you see `-- ENTER YOUR SCANDIT LICENSE KEY HERE --`.
- Build and run this sample on your mobile device.

## What is Smart Label Capture?

Smart Label Capture reads multiple fields from a label — barcodes and printed text — in a single scan. The pre-built `priceCapture` definition targets shelf price labels: it captures the product barcode (field name `SKU`) and the printed price (field name `priceText`) typically found on European price tags (EAN-13 / UPC-A, Code 128).

## Trying it out

`PriceCaptureSample/codes_for_testing.pdf` is a sheet of price labels you can scan straight off the
screen or a printout. With the bundled reference data, most labels read as **correct** (green); a
few read as **incorrect** (red — their printed price differs from the reference), and a product
that isn't in the database reads as **unknown** (yellow).

## Reference price database

The reference data lives in `PriceCaptureSample/barcode_price_database.csv`, bundled with the app and loaded into memory once on startup. It is a two-column `barcode,price` CSV with no header:

```csv
# Correct prices
7846987774588,7.99
7617400031003,4.29
# Incorrect prices
7654782245697,4.49
```

To use your own data, edit the CSV in place and rebuild the app. Comparison is exact: a captured price matches the reference only when the two are equal at the cent (Swift `Decimal` equality). Lines beginning with `#` and blank lines are ignored, so you can annotate the data.

## Documentation

Smart Label Capture is an API of the Scandit Data Capture SDK.  Our SDK is supported on most popular frameworks.

Get started with Smart Label Capture on [iOS](https://docs.scandit.com/sdks/ios/label-capture/get-started/), [Android](https://docs.scandit.com/sdks/android/label-capture/get-started/), [React Native](https://docs.scandit.com/sdks/react-native/label-capture/get-started/).

For all data capture functionality across frameworks, see documentation:

[iOS](https://docs.scandit.com/data-capture-sdk/ios/index.html), [Android](https://docs.scandit.com/data-capture-sdk/android/index.html), [Web](https://docs.scandit.com/data-capture-sdk/web/index.html), [Cordova](https://docs.scandit.com/data-capture-sdk/cordova/index.html), Xamarin ([iOS](https://docs.scandit.com/data-capture-sdk/xamarin.ios/index.html), [Android](https://docs.scandit.com/data-capture-sdk/xamarin.android/index.html), [Forms](https://docs.scandit.com/data-capture-sdk/xamarin.forms/index.html)), .NET ([iOS](https://docs.scandit.com/data-capture-sdk/dotnet.ios/index.html), [Android](https://docs.scandit.com/data-capture-sdk/dotnet.android/index.html)), [React Native](https://docs.scandit.com/data-capture-sdk/react-native/index.html), [Flutter](https://docs.scandit.com/data-capture-sdk/flutter/index.html), [Capacitor](https://docs.scandit.com/data-capture-sdk/capacitor/index.html), [Titanium](https://docs.scandit.com/data-capture-sdk/titanium/index.html)

## Trial Signup

To add Smart Label Capture to your app, sign up for your Scandit Developer Account and get instant access to your license key: [https://ssl.scandit.com/dashboard/sign-up?p=test](https://ssl.scandit.com/dashboard/sign-up?p=test)

## Support

Our support engineers can be reached at [support@scandit.com](mailto:support@scandit.com).

## License

[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0)
