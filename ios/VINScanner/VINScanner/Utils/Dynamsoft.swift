
import Foundation
import UIKit

let kScreenWidth = UIScreen.main.bounds.size.width

let kScreenHeight = UIScreen.main.bounds.size.height

let kNavigationBarFullHeight = UIDevice.ds_navigationFullHeight()

let kTabBarSafeAreaHeight = UIDevice.ds_safeDistanceBottom()

func kFont_Regular(_ fonts: CGFloat) -> UIFont {
    UIFont.systemFont(ofSize: fonts)
}

enum VINPattern: String {
    case barcode = "VIN - Barcode"
    case text = "VIN - Text"
}

enum VINCustomizedTemplate: String {
    case barcode = "ReadVINBarcode"
    case text = "ReadVINText"
}

typealias PatternSelectedCompletion = (_ pattern: VINPattern) -> Void

typealias ConfirmCompletion = () -> Void

let parseFailedTip = "Failed to parse the result.\n The text is :\n"
