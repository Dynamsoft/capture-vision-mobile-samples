# Dynamsoft Capture Vision samples for Android and iOS editions

## Requirements

### Android

- Supported OS: Android 5.0 (API Level 21) or higher.
- Supported ABI: armeabi-v7a, arm64-v8a, x86 and x86_64.
- Development Environment: Android Studio 2022.2.1 or higher.

### iOS

- Supported OS: iOS 11.0 or higher (iOS 13 and higher recommended).
- Supported ABI: arm64 and x86_64.
- Development Environment: Xcode 13 and above (Xcode 14.1+ recommended), CocoaPods 1.11.0+

## Samples

| Sample Name | Description | Programming Languages |
| ----------- | ----------- | --------------------- |
| `DriversLicenseScanner` | Scan the PDF417 barcode on a driver's license and extract driver's information. | Java/Swift |
| `MRZScanner` | Scan the MRZ area on a passport, an Id Card, or a VISA and extract the encoded content to human-readable fields. | Java/Swift |
| `VINScanner` | Scan the VIN code from a barcode or a text line and extract the vehicle information. | Java/Swift |

## How to build (For iOS Editions)

Enter the sample folder, install DBR SDK through pod command

```bash
pod install
```

Open the generated file `[SampleName].xcworkspace`.

## License

You can request a 30-day trial license via the [Request a Trial License](https://www.dynamsoft.com/customer/license/trialLicense?product=cvs&utm_source=github&package=mobile) link.

## Contact Us

For any questions or feedback, you can either [contact us](https://www.dynamsoft.com/company/contact/) or [submit an issue](https://github.com/Dynamsoft/capture-vision-mobile-samples/issues/new).
