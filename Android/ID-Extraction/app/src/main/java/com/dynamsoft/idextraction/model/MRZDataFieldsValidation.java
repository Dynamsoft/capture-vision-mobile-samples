package com.dynamsoft.idextraction.model;

import com.dynamsoft.dcp.EnumValidationStatus;

import java.io.Serializable;

public class MRZDataFieldsValidation implements Serializable {
    @EnumValidationStatus
    public int firstNameValidation = EnumValidationStatus.VS_NONE;

    @EnumValidationStatus
    public int lastNameValidation = EnumValidationStatus.VS_NONE;

    @EnumValidationStatus
    public int sexValidation = EnumValidationStatus.VS_NONE;

    @EnumValidationStatus
    public int issuingStateValidation = EnumValidationStatus.VS_NONE;

    @EnumValidationStatus
    public int nationalityValidation = EnumValidationStatus.VS_NONE;

    @EnumValidationStatus
    public int dateOfBirthValidation = EnumValidationStatus.VS_NONE;

    @EnumValidationStatus
    public int dateOfExpireValidation = EnumValidationStatus.VS_NONE;

    @EnumValidationStatus
    public int documentNumberValidation = EnumValidationStatus.VS_NONE;

    @EnumValidationStatus
    public int mrzTextValidation = EnumValidationStatus.VS_NONE;

    @EnumValidationStatus
    public int optionalData1Validation = EnumValidationStatus.VS_NONE;

    @EnumValidationStatus
    public int optionalData2Validation = EnumValidationStatus.VS_NONE;

    @EnumValidationStatus
    public int personalNumberValidation = EnumValidationStatus.VS_NONE;
}
