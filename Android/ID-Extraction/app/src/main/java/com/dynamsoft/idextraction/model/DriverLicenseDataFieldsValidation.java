package com.dynamsoft.idextraction.model;

import com.dynamsoft.dcp.EnumValidationStatus;

import java.io.Serializable;

public class DriverLicenseDataFieldsValidation implements Serializable {
    @EnumValidationStatus
    public int nameValidation = EnumValidationStatus.VS_NONE; // For AAMVA_DL_ID (fullName/givenName/firstName/lastName), AAMVA_DL_ID_WITH_MAG_STRIPE (name)

    @EnumValidationStatus
    public int stateValidation = EnumValidationStatus.VS_NONE; // For AAMVA_DL_ID (jurisdictionCode)

    @EnumValidationStatus
    public int stateOrProvinceValidation = EnumValidationStatus.VS_NONE; // For AAMVA_DL_ID_WITH_MAG_STRIPE (stateOrProvince)

    @EnumValidationStatus
    public int cityValidation = EnumValidationStatus.VS_NONE; // For AAMVA_DL_ID, AAMVA_DL_ID_WITH_MAG_STRIPE (city)

    @EnumValidationStatus
    public int addressValidation = EnumValidationStatus.VS_NONE; // For AAMVA_DL_ID (street_1/street_2), AAMVA_DL_ID_WITH_MAG_STRIPE (address)

    @EnumValidationStatus
    public int licenseNumberValidation = EnumValidationStatus.VS_NONE; // For AAMVA_DL_ID (licenseNumber), AAMVA_DL_ID_WITH_MAG_STRIPE (DLorID_Number)

    @EnumValidationStatus
    public int issuedDateValidation = EnumValidationStatus.VS_NONE; // For AAMVA_DL_ID (issuedDate)

    @EnumValidationStatus
    public int expirationDateValidation = EnumValidationStatus.VS_NONE; // For AAMVA_DL_ID, AAMVA_DL_ID_WITH_MAG_STRIPE (expirationDate)

    @EnumValidationStatus
    public int birthDateValidation = EnumValidationStatus.VS_NONE; // For AAMVA_DL_ID, AAMVA_DL_ID_WITH_MAG_STRIPE (birthDate)

    @EnumValidationStatus
    public int sexValidation = EnumValidationStatus.VS_NONE; // For AAMVA_DL_ID, AAMVA_DL_ID_WITH_MAG_STRIPE (sex)

    @EnumValidationStatus
    public int heightValidation = EnumValidationStatus.VS_NONE; // For AAMVA_DL_ID, AAMVA_DL_ID_WITH_MAG_STRIPE (height)

    @EnumValidationStatus
    public int issuedCountryValidation = EnumValidationStatus.VS_NONE; // For AAMVA_DL_ID (issuingCountry)

    @EnumValidationStatus
    public int vehicleClassValidation = EnumValidationStatus.VS_NONE; // For AAMVA_DL_ID (vehicleClass)
}
