package com.dynamsoft.idextraction.model;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.dynamsoft.dcp.EnumValidationStatus;
import com.dynamsoft.dcp.ParsedResultItem;

import java.io.Serializable;
import java.util.HashMap;

public class DriverLicenseData implements Serializable {
    public String documentType; //EnumDocumentType.AAMVA_DL_ID, AAMVA_DL_ID_WITH_MAG_STRIPE, SOUTH_AFRICA_DL
    public String name;
    public String state; // For AAMVA_DL_ID
    public String stateOrProvince; // For AAMVA_DL_ID_WITH_MAG_STRIPE
    public String initials; // For SOUTH_AFRICA_DL
    public String city; // For AAMVA_DL_ID, AAMVA_DL_ID_WITH_MAG_STRIPE
    public String address; // For AAMVA_DL_ID, AAMVA_DL_ID_WITH_MAG_STRIPE
    public String idNumber; // For SOUTH_AFRICA_DL
    public String idNumberType; // For SOUTH_AFRICA_DL
    public String licenseNumber;
    public String licenseIssueNumber; // For SOUTH_AFRICA_DL
    public String issuedDate;
    public String expirationDate;
    public String birthDate;
    public String sex;
    public String height; // For AAMVA_DL_ID, SOUTH_AFRICA_DL
    public String issuedCountry; // For AAMVA_DL_ID, SOUTH_AFRICA_DL
    public String vehicleClass; // For AAMVA_DL_ID

    public String rawText;
    public String driverRestrictionCodes; // For SOUTH_AFRICA_DL

    @NonNull
    public DriverLicenseDataFieldsValidation fieldsValidation = new DriverLicenseDataFieldsValidation();

    public DriverLicenseData() {
    }

    // Combines the validation statuses of several JSON fields that together
    // form a single composite field (e.g. name, address): failed if any of
    // them failed, succeeded if any of them succeeded (and none failed),
    // otherwise none.
    private static int combineValidationStatus(int... statuses) {
        boolean hasSucceeded = false;
        for (int status : statuses) {
            if (status == EnumValidationStatus.VS_FAILED) {
                return EnumValidationStatus.VS_FAILED;
            }
            if (status == EnumValidationStatus.VS_SUCCEEDED) {
                hasSucceeded = true;
            }
        }
        return hasSucceeded ? EnumValidationStatus.VS_SUCCEEDED : EnumValidationStatus.VS_NONE;
    }


    @Nullable
    public static DriverLicenseData fromParsedResultItem(@Nullable ParsedResultItem item, @Nullable String rawText) {
        if (item == null || item.getParsedFields() == null) return null;
        HashMap<String, String> map = item.getParsedFields();
        String docType = item.getCodeType();
        if(docType == null || !EnumDocumentType.isDriverLicense(docType)) {
            return null;
        }

        DriverLicenseData data = new DriverLicenseData();
        data.documentType = docType;
        if (EnumDocumentType.AAMVA_DL_ID.getValue().equals(docType)) {
            String fullName = map.get("fullName");
            if (fullName != null && !fullName.isEmpty()) {
                data.name = fullName;
                data.fieldsValidation.nameValidation = item.getFieldValidationStatus("fullName");
            } else {
                String givenNameKey = map.get("givenName") != null ? "givenName" : "firstName";
                String givenName = map.get(givenNameKey);
                String lastName = map.get("lastName");
                data.name = ((givenName == null ? "" : givenName) + " " + (lastName == null ? "" : lastName)).trim();
                data.fieldsValidation.nameValidation = combineValidationStatus(
                        item.getFieldValidationStatus(givenNameKey), item.getFieldValidationStatus("lastName"));
            }
            data.city = map.get("city");
            data.fieldsValidation.cityValidation = item.getFieldValidationStatus("city");
            data.state = map.get("jurisdictionCode");
            data.fieldsValidation.stateValidation = item.getFieldValidationStatus("jurisdictionCode");
            String street1 = map.get("street_1");
            String street2 = map.get("street_2");
            data.address = ((street1 == null ? "" : street1) + " " + (street2 == null ? "" : street2)).trim();
            data.fieldsValidation.addressValidation = combineValidationStatus(
                    item.getFieldValidationStatus("street_1"), item.getFieldValidationStatus("street_2"));
            data.licenseNumber = map.get("licenseNumber");
            data.fieldsValidation.licenseNumberValidation = item.getFieldValidationStatus("licenseNumber");
            data.issuedDate = map.get("issuedDate");
            data.fieldsValidation.issuedDateValidation = item.getFieldValidationStatus("issuedDate");
            data.expirationDate = map.get("expirationDate");
            data.fieldsValidation.expirationDateValidation = item.getFieldValidationStatus("expirationDate");
            data.birthDate = map.get("birthDate");
            data.fieldsValidation.birthDateValidation = item.getFieldValidationStatus("birthDate");
            data.height = map.get("height");
            data.fieldsValidation.heightValidation = item.getFieldValidationStatus("height");
            data.sex = map.get("sex");
            data.fieldsValidation.sexValidation = item.getFieldValidationStatus("sex");
            data.issuedCountry = map.get("issuingCountry");
            data.fieldsValidation.issuedCountryValidation = item.getFieldValidationStatus("issuingCountry");
            data.vehicleClass = map.get("vehicleClass");
            data.fieldsValidation.vehicleClassValidation = item.getFieldValidationStatus("vehicleClass");
        } else if (EnumDocumentType.AAMVA_DL_ID_WITH_MAG_STRIPE.getValue().equals(docType)) {
            data.name = map.get("name");
            data.fieldsValidation.nameValidation = item.getFieldValidationStatus("name");
            data.city = map.get("city");
            data.fieldsValidation.cityValidation = item.getFieldValidationStatus("city");
            data.stateOrProvince = map.get("stateOrProvince");
            data.fieldsValidation.stateOrProvinceValidation = item.getFieldValidationStatus("stateOrProvince");
            data.address = map.get("address");
            data.fieldsValidation.addressValidation = item.getFieldValidationStatus("address");
            data.licenseNumber = map.get("DLorID_Number");
            data.fieldsValidation.licenseNumberValidation = item.getFieldValidationStatus("DLorID_Number");
            data.expirationDate = map.get("expirationDate");
            data.fieldsValidation.expirationDateValidation = item.getFieldValidationStatus("expirationDate");
            data.birthDate = map.get("birthDate");
            data.fieldsValidation.birthDateValidation = item.getFieldValidationStatus("birthDate");
            data.height = map.get("height");
            data.fieldsValidation.heightValidation = item.getFieldValidationStatus("height");
            data.sex = map.get("sex");
            data.fieldsValidation.sexValidation = item.getFieldValidationStatus("sex");
        } else if (EnumDocumentType.SOUTH_AFRICA_DL.getValue().equals(docType)) {
            // SOUTH_AFRICA_DL_Map.json defines no Validation rules for any field,
            // so fieldsValidation is left at its default (VS_NONE) for this doc type.
            data.name = map.get("surname");
            data.idNumber = map.get("idNumber");
            data.idNumberType = map.get("idNumberType");
            data.licenseNumber = map.get("licenseNumber");
            data.licenseIssueNumber = map.get("licenseIssueNumber");
            data.initials = map.get("initials");
            data.issuedDate = map.get("licenseValidityFrom");
            data.expirationDate = map.get("licenseValidityTo");
            data.birthDate = map.get("birthDate");
            data.sex = map.get("gender");
            data.issuedCountry = map.get("idIssuedCountry");
            data.driverRestrictionCodes = map.get("driverRestrictionCodes");
        }

        boolean hasName = data.name != null && !data.name.trim().isEmpty();
        boolean hasLicenseNumber = data.licenseNumber != null;
        if (!hasName || !hasLicenseNumber) {
            return null;
        }
        data.rawText = rawText;
        return data;
    }
}
