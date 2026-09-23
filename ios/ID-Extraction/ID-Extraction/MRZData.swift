/*
 * This is the sample of Dynamsoft Capture Vision.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import DynamsoftCaptureVisionBundle
import Foundation

class MRZData {

    var documentType: String?
    var firstName: String?
    var lastName: String?
    var sex: String?
    var issuingState: String?
    var nationality: String?
    var dateOfBirth: String?
    var dateOfExpire: String?
    var documentNumber: String?
    var age: Int = 0
    var mrzText: String?
    var issuingStateRaw: String?
    var nationalityRaw: String?
    var optionalData1: String?
    var optionalData2: String?
    var personalNumber: String?

    var fieldsValidation = MRZDataFieldsValidation()

    static func fromParsedResultItem(
        _ item: ParsedResultItem
    ) -> MRZData? {
        let map = item.parsedFields

        let docType = item.codeType

        guard DocumentType.isMrz(docType) else {
            return nil
        }

        let mrzData = MRZData()
        mrzData.documentType = docType

        // MRZ Text Validation
        var isValid = false

        if docType == DocumentType.mrtdTd1Id.rawValue {

            isValid =
                item.getFieldValidationStatus("line1") != .failed &&
                item.getFieldValidationStatus("line2") != .failed &&
                item.getFieldValidationStatus("line3") != .failed

        } else if docType == DocumentType.mrtdTd2Id.rawValue ||
                    docType == DocumentType.mrtdTd3Passport.rawValue {

            isValid =
                item.getFieldValidationStatus("line1") != .failed &&
                item.getFieldValidationStatus("line2") != .failed
        }

        let line1 = map["line1"] ?? ""
        let line2 = map["line2"] ?? ""
        let line3 = map["line3"] ?? ""

        mrzData.mrzText = """
        \(line1)
        \(line2)
        \(line3)
        """
        .trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        mrzData.fieldsValidation.mrzTextValidation =
            isValid ? .succeeded : .failed

        // Document Number
        if map["passportNumber"] != nil {

            mrzData.documentNumber = map["passportNumber"]

            mrzData.fieldsValidation.documentNumberValidation =
                item.getFieldValidationStatus(
                    "passportNumber"
                )

        } else if map["documentNumber"] != nil {

            mrzData.documentNumber = map["documentNumber"]

            mrzData.fieldsValidation.documentNumberValidation =
                item.getFieldValidationStatus(
                    "documentNumber"
                )

        } else if map["longDocumentNumber"] != nil {

            mrzData.documentNumber =
                map["longDocumentNumber"]

            mrzData.fieldsValidation.documentNumberValidation =
                item.getFieldValidationStatus(
                    "longDocumentNumber"
                )
        }

        // Sex
        mrzData.sex = map["sex"]

        mrzData.fieldsValidation.sexValidation =
            item.getFieldValidationStatus("sex")

        // Issuing State
        let issuingState = map["issuingState"]
        let issuingStateRaw =
            item.getFieldRawValue("issuingState")

        mrzData.issuingState = issuingState
        mrzData.issuingStateRaw = issuingStateRaw

        mrzData.fieldsValidation.issuingStateValidation =
            item.getFieldValidationStatus(
                "issuingState"
            )

        // Nationality
        let nationality = map["nationality"]
        let nationalityRaw =
            item.getFieldRawValue("nationality")

        mrzData.nationality = nationality
        mrzData.nationalityRaw = nationalityRaw

        mrzData.fieldsValidation.nationalityValidation =
            item.getFieldValidationStatus(
                "nationality"
            )

        // Name
        let firstName =
            map["secondaryIdentifier"] ?? ""

        mrzData.firstName = firstName

        mrzData.fieldsValidation.firstNameValidation =
            item.getFieldValidationStatus(
                "secondaryIdentifier"
            )

        let lastName =
            map["primaryIdentifier"] ?? ""

        mrzData.lastName = lastName

        mrzData.fieldsValidation.lastNameValidation =
            item.getFieldValidationStatus(
                "primaryIdentifier"
            )

        // Birth Date
        let calendar = Calendar.current

        let currentYear = calendar.component(
            .year,
            from: Date()
        )

        let currentMonth = calendar.component(
            .month,
            from: Date()
        )

        let currentDay = calendar.component(
            .day,
            from: Date()
        )

        var birthYear = 0
        var birthMonth = 0
        var birthDay = 0

        if let value = map["birthYear"],
           let year = Int(value) {
            birthYear = year
        }

        if let value = map["birthMonth"],
           let month = Int(value) {
            birthMonth = month
        }

        if let value = map["birthDay"],
           let day = Int(value) {
            birthDay = day
        }

        birthYear += 1900

        let birthNumber =
            birthYear * 10000 +
            birthMonth * 100 +
            birthDay

        let currentDayNumber =
            currentYear * 10000 +
            currentMonth * 100 +
            currentDay

        var age =
            (currentDayNumber - birthNumber) / 10000

        if age >= 100 {
            age -= 100
            birthYear += 100
        }

        let birthMonthString =
            map["birthMonth"] ?? ""

        let birthDayString =
            map["birthDay"] ?? ""

        mrzData.dateOfBirth =
            "\(birthYear)-\(birthMonthString)-\(birthDayString)"

        mrzData.fieldsValidation.dateOfBirthValidation =
            item.getFieldValidationStatus(
                "dateOfBirth"
            )

        mrzData.age = age

        // Expiration Date
        var expireYear = 0

        if let value = map["expiryYear"],
           let year = Int(value) {
            expireYear = year
        }

        let expireYearString =
            expireYear != 0
            ? String(expireYear + 2000)
            : "XXXX"

        let expireMonthString =
            map["expiryMonth"] ?? ""

        let expireDayString =
            map["expiryDay"] ?? ""

        mrzData.dateOfExpire =
            "\(expireYearString)-\(expireMonthString)-\(expireDayString)"

        mrzData.fieldsValidation.dateOfExpireValidation =
            item.getFieldValidationStatus(
                "dateOfExpiry"
            )

        // Personal Number
        mrzData.personalNumber =
            map["personalNumber"]

        mrzData.fieldsValidation.personalNumberValidation =
            item.getFieldValidationStatus(
                "personalNumber"
            )

        // Optional Data 1
        mrzData.optionalData1 =
            item.getFieldRawValue(
                "optionalData1"
            )

        mrzData.fieldsValidation.optionalData1Validation =
            item.getFieldValidationStatus(
                "optionalData1"
            )

        // Optional Data 2
        mrzData.optionalData2 =
            item.getFieldRawValue(
                "optionalData2"
            )

        mrzData.fieldsValidation.optionalData2Validation =
            item.getFieldValidationStatus(
                "optionalData2"
            )

        return mrzData
    }
}
