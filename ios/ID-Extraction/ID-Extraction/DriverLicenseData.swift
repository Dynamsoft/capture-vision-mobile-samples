/*
 * This is the sample of Dynamsoft Capture Vision.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import DynamsoftCaptureVisionBundle

class DriverLicenseData {
    var documentType: String?
    var name: String?
    var state: String?
    var stateOrProvince: String?
    var initials: String?
    var city: String?
    var address: String?
    var idNumber: String?
    var idNumberType: String?
    var licenseNumber: String?
    var licenseIssueNumber: String?
    var issuedDate: String?
    var expirationDate: String?
    var birthDate: String?
    var sex: String?
    var height: String?
    var issuedCountry: String?
    var vehicleClass: String?

    var rawText: String?
    var driverRestrictionCodes: String?

    var fieldsValidation = DriverLicenseDataFieldsValidation()

    private static func combineValidationStatus(_ statuses: ValidationStatus...) -> ValidationStatus {
        var hasSucceeded = false

        for status in statuses {
            if status == ValidationStatus.failed {
                return ValidationStatus.failed
            }

            if status == ValidationStatus.succeeded {
                hasSucceeded = true
            }
        }

        return hasSucceeded
            ? ValidationStatus.succeeded
            : ValidationStatus.none
    }

    static func fromParsedResultItem(
        _ item: ParsedResultItem
    ) -> DriverLicenseData? {

        let map = item.parsedFields
        let docType = item.codeType

        guard DocumentType.isDriverLicense(docType) else {
            return nil
        }

        let data = DriverLicenseData()
        data.documentType = docType

        if DocumentType.aamvaDlId.rawValue == docType {

            let fullName = map["fullName"]

            if let fullName = fullName, !fullName.isEmpty {
                data.name = fullName
                data.fieldsValidation.nameValidation =
                    item.getFieldValidationStatus("fullName")
            } else {
                let givenNameKey: String
                if map["givenName"] != nil {
                    givenNameKey = "givenName"
                } else {
                    givenNameKey = "firstName"
                }

                let givenName = map[givenNameKey]
                let lastName = map["lastName"]

                data.name = [
                    givenName ?? "",
                    lastName ?? ""
                ]
                .joined(separator: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)

                data.fieldsValidation.nameValidation =
                    combineValidationStatus(
                        item.getFieldValidationStatus(givenNameKey),
                        item.getFieldValidationStatus("lastName")
                    )
            }

            data.city = map["city"]
            data.fieldsValidation.cityValidation =
                item.getFieldValidationStatus("city")

            data.state = map["jurisdictionCode"]
            data.fieldsValidation.stateValidation =
                item.getFieldValidationStatus("jurisdictionCode")

            let street1 = map["street_1"]
            let street2 = map["street_2"]

            data.address = [
                street1 ?? "",
                street2 ?? ""
            ]
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

            data.fieldsValidation.addressValidation =
                combineValidationStatus(
                    item.getFieldValidationStatus("street_1"),
                    item.getFieldValidationStatus("street_2")
                )

            data.licenseNumber = map["licenseNumber"]
            data.fieldsValidation.licenseNumberValidation =
                item.getFieldValidationStatus("licenseNumber")

            data.issuedDate = map["issuedDate"]
            data.fieldsValidation.issuedDateValidation =
                item.getFieldValidationStatus("issuedDate")

            data.expirationDate = map["expirationDate"]
            data.fieldsValidation.expirationDateValidation =
                item.getFieldValidationStatus("expirationDate")

            data.birthDate = map["birthDate"]
            data.fieldsValidation.birthDateValidation =
                item.getFieldValidationStatus("birthDate")

            data.height = map["height"]
            data.fieldsValidation.heightValidation =
                item.getFieldValidationStatus("height")

            data.sex = map["sex"]
            data.fieldsValidation.sexValidation =
                item.getFieldValidationStatus("sex")

            data.issuedCountry = map["issuingCountry"]
            data.fieldsValidation.issuedCountryValidation =
                item.getFieldValidationStatus("issuingCountry")

            data.vehicleClass = map["vehicleClass"]
            data.fieldsValidation.vehicleClassValidation =
                item.getFieldValidationStatus("vehicleClass")

        } else if DocumentType.aamvaDlIdWithMagStripe.rawValue == docType {

            data.name = map["name"]
            data.fieldsValidation.nameValidation =
                item.getFieldValidationStatus("name")

            data.city = map["city"]
            data.fieldsValidation.cityValidation =
                item.getFieldValidationStatus("city")

            data.stateOrProvince = map["stateOrProvince"]
            data.fieldsValidation.stateOrProvinceValidation =
                item.getFieldValidationStatus("stateOrProvince")

            data.address = map["address"]
            data.fieldsValidation.addressValidation =
                item.getFieldValidationStatus("address")

            data.licenseNumber = map["DLorID_Number"]
            data.fieldsValidation.licenseNumberValidation =
                item.getFieldValidationStatus("DLorID_Number")

            data.expirationDate = map["expirationDate"]
            data.fieldsValidation.expirationDateValidation =
                item.getFieldValidationStatus("expirationDate")

            data.birthDate = map["birthDate"]
            data.fieldsValidation.birthDateValidation =
                item.getFieldValidationStatus("birthDate")

            data.height = map["height"]
            data.fieldsValidation.heightValidation =
                item.getFieldValidationStatus("height")

            data.sex = map["sex"]
            data.fieldsValidation.sexValidation =
                item.getFieldValidationStatus("sex")

        } else if DocumentType.southAfricaDl.rawValue == docType {

            data.name = map["surname"]
            data.idNumber = map["idNumber"]
            data.idNumberType = map["idNumberType"]

            data.licenseNumber = map["licenseNumber"]

            data.licenseIssueNumber = map["licenseIssueNumber"]
            data.initials = map["initials"]

            data.issuedDate = map["licenseValidityFrom"]
            data.expirationDate = map["licenseValidityTo"]

            data.birthDate = map["birthDate"]
            data.sex = map["gender"]

            data.issuedCountry = map["idIssuedCountry"]
            data.driverRestrictionCodes = map["driverRestrictionCodes"]
        }

        let hasName =
            data.name?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty == false

        let hasLicenseNumber =
            data.licenseNumber != nil

        guard hasName && hasLicenseNumber else {
            return nil
        }

        data.rawText = (item.reference as? BarcodeResultItem)?.text

        return data
    }
}
