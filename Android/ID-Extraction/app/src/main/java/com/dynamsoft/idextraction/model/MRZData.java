package com.dynamsoft.idextraction.model;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.dynamsoft.dcp.EnumValidationStatus;
import com.dynamsoft.dcp.ParsedResultItem;

import java.io.Serializable;
import java.util.Calendar;
import java.util.HashMap;

public class MRZData implements Serializable {
    public String documentType; //EnumDocumentType.MRTD_TD1_ID, MRTD_TD2_ID, MRTD_TD3_PASSPORT
    public String firstName;
    public String lastName;
    public String sex;
    public String issuingState;
    public String nationality;
    public String dateOfBirth;
    public String dateOfExpire;
    public String documentNumber;
    public int age;
    public String mrzText;
    public String issuingStateRaw;
    public String nationalityRaw;
    @Nullable
    public String optionalData1;
    @Nullable
    public String optionalData2;
    @Nullable
    public String personalNumber;

    @NonNull
    public MRZDataFieldsValidation fieldsValidation = new MRZDataFieldsValidation();

    public MRZData() {
    }

    MRZData(String firstName, String lastName, String sex,
            String issuingState, String nationality, String dateOfBirth, String dateOfExpire,
            String documentNumber, int age, String mrzText, String documentType,
            String issuingStateRaw, String nationalityRaw,
            @Nullable String optionalData1, @Nullable String optionalData2, @Nullable String personalNumber) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.sex = sex;
        this.issuingState = issuingState;
        this.nationality = nationality;
        this.dateOfBirth = dateOfBirth;
        this.dateOfExpire = dateOfExpire;
        this.documentNumber = documentNumber;
        this.age = age;
        this.mrzText = mrzText;
        this.documentType = documentType;

        this.nationalityRaw = nationalityRaw;
        this.issuingStateRaw = issuingStateRaw;
        this.optionalData1 = optionalData1;
        this.optionalData2 = optionalData2;
        this.personalNumber = personalNumber;
    }

    @Nullable
    public static MRZData fromParsedResultItem(@Nullable ParsedResultItem item) {
        if (item == null || item.getParsedFields() == null) return null;
        HashMap<String, String> map = item.getParsedFields();
        String docType = item.getCodeType();

        if (docType == null || !EnumDocumentType.isMRZ(docType)) {
            return null;
        }

        MRZData mrzData = new MRZData();
        mrzData.documentType = docType;

        boolean isValid = false;
        if (docType.equals(EnumDocumentType.MRTD_TD1_ID.getValue())) {
            isValid = item.getFieldValidationStatus("line1") != EnumValidationStatus.VS_FAILED
                    && item.getFieldValidationStatus("line2") != EnumValidationStatus.VS_FAILED
                    && item.getFieldValidationStatus("line3") != EnumValidationStatus.VS_FAILED;
        } else if (docType.equals(EnumDocumentType.MRTD_TD2_ID.getValue()) || docType.equals(EnumDocumentType.MRTD_TD3_PASSPORT.getValue())) {
            isValid = item.getFieldValidationStatus("line1") != EnumValidationStatus.VS_FAILED
                    && item.getFieldValidationStatus("line2") != EnumValidationStatus.VS_FAILED;
        }

        String line1 = map.get("line1") == null ? "" : map.get("line1");
        String line2 = map.get("line2") == null ? "" : map.get("line2");
        String line3 = map.get("line3") == null ? "" : map.get("line3");
        mrzData.mrzText = (line1 + "\n" + line2 + "\n" + line3).trim();
        mrzData.fieldsValidation.mrzTextValidation = isValid ? EnumValidationStatus.VS_SUCCEEDED : EnumValidationStatus.VS_FAILED;

        if (map.containsKey("passportNumber")) {
            mrzData.documentNumber = map.get("passportNumber");
            mrzData.fieldsValidation.documentNumberValidation = item.getFieldValidationStatus("passportNumber");
        } else if (map.containsKey("documentNumber")) {
            mrzData.documentNumber = map.get("documentNumber");
            mrzData.fieldsValidation.documentNumberValidation = item.getFieldValidationStatus("documentNumber");
        } else if (map.containsKey("longDocumentNumber")) {
            mrzData.documentNumber = map.get("longDocumentNumber");
            mrzData.fieldsValidation.documentNumberValidation = item.getFieldValidationStatus("longDocumentNumber");
        }


        mrzData.sex = map.get("sex");
        mrzData.fieldsValidation.sexValidation = item.getFieldValidationStatus("sex");

        String issuingState = map.get("issuingState");
        String issuingStateRaw = item.getFieldRawValue("issuingState");
        mrzData.issuingState = issuingState;
        mrzData.issuingStateRaw = issuingStateRaw;
        mrzData.fieldsValidation.issuingStateValidation = item.getFieldValidationStatus("issuingState");

        String nationality = map.get("nationality");
        String nationalityRaw = item.getFieldRawValue("nationality");
        mrzData.nationality = nationality;
        mrzData.nationalityRaw = nationalityRaw;
        mrzData.fieldsValidation.nationalityValidation = item.getFieldValidationStatus("nationality");


        String firstName = map.get("secondaryIdentifier") == null ? "" : map.get("secondaryIdentifier");
        mrzData.fieldsValidation.firstNameValidation = item.getFieldValidationStatus("secondaryIdentifier");
        mrzData.firstName = firstName;
        String lastName = map.get("primaryIdentifier") == null ? "" : map.get("primaryIdentifier");
        mrzData.lastName = lastName;
        mrzData.fieldsValidation.lastNameValidation = item.getFieldValidationStatus("primaryIdentifier");

        Calendar calendar = Calendar.getInstance();
        int currentYear = calendar.get(Calendar.YEAR);
        int currentMonth = calendar.get(Calendar.MONTH) + 1;
        int currentDay = calendar.get(Calendar.DAY_OF_MONTH);

        int birthYear = 0, birthMonth = 0, birthDay = 0;
        try {
            birthYear = Integer.parseInt(map.get("birthYear"));
        } catch (Exception ignore) {
        }
        try {
            //It may be "XX" or "undefined", not a number
            birthMonth = Integer.parseInt(map.get("birthMonth"));
        } catch (Exception ignore) {
        }
        try {
            //It may be "XX" or "undefined", not a number
            birthDay = Integer.parseInt(map.get("birthDay"));
        } catch (Exception ignore) {
        }

        // Age information is not directly obtained from the MRZ but you can calculate it based on the date of birth.
        birthYear += 1900;
        int birthNumber = birthYear * 10000 + birthMonth * 100 + birthDay;
        int currentDayNumber = currentYear * 10000 + currentMonth * 100 + currentDay;
        int age = (currentDayNumber - birthNumber) / 10000;
        if (age >= 100) {
            age -= 100;
            birthYear += 100;
        }
        mrzData.dateOfBirth = birthYear + "-" + map.get("birthMonth") + "-" + map.get("birthDay");
        mrzData.fieldsValidation.dateOfBirthValidation = item.getFieldValidationStatus("dateOfBirth");
        mrzData.age = age;

        int expireYear = 0;
        try {
            expireYear = Integer.parseInt(map.get("expiryYear"));
        } catch (Exception ignore) {
        }
        String expireYearString = expireYear != 0 ? String.valueOf(expireYear + 2000) : "XXXX";
        mrzData.dateOfExpire = expireYearString + "-" + map.get("expiryMonth") + "-" + map.get("expiryDay");
        mrzData.fieldsValidation.dateOfExpireValidation = item.getFieldValidationStatus("dateOfExpiry");

        mrzData.personalNumber = map.get("personalNumber");
        mrzData.fieldsValidation.personalNumberValidation = item.getFieldValidationStatus("personalNumber");

        mrzData.optionalData1 = item.getFieldRawValue("optionalData1");
        mrzData.fieldsValidation.optionalData1Validation = item.getFieldValidationStatus("optionalData1");

        mrzData.optionalData2 = item.getFieldRawValue("optionalData2");
        mrzData.fieldsValidation.optionalData2Validation = item.getFieldValidationStatus("optionalData2");

        return mrzData;
    }
}
