/*
 * This is the sample of Dynamsoft Capture Vision.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import DynamsoftCaptureVisionBundle

enum DocumentType: String {
    // MRZ
    case mrtdTd1Id = "MRTD_TD1_ID"
    case mrtdTd2Id = "MRTD_TD2_ID"
    case mrtdTd3Passport = "MRTD_TD3_PASSPORT"

    // DRIVER LICENSE
    case aamvaDlId = "AAMVA_DL_ID"
    case aamvaDlIdWithMagStripe = "AAMVA_DL_ID_WITH_MAG_STRIPE"
    case southAfricaDl = "SOUTH_AFRICA_DL"

    static func isMrz(_ docType: String) -> Bool {
        return mrtdTd1Id.rawValue == docType ||
               mrtdTd2Id.rawValue == docType ||
               mrtdTd3Passport.rawValue == docType
    }

    static func isDriverLicense(_ docType: String) -> Bool {
        return aamvaDlId.rawValue == docType ||
               aamvaDlIdWithMagStripe.rawValue == docType ||
               southAfricaDl.rawValue == docType
    }
}
