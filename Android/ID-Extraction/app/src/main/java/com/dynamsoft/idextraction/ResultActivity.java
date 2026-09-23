package com.dynamsoft.idextraction;

import android.os.Bundle;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.dynamsoft.dcp.EnumValidationStatus;
import com.dynamsoft.idextraction.model.DriverLicenseData;
import com.dynamsoft.idextraction.model.DriverLicenseDataFieldsValidation;
import com.dynamsoft.idextraction.model.MRZData;
import com.dynamsoft.idextraction.model.MRZDataFieldsValidation;

public class ResultActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_result);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        MRZData mrzData = (MRZData) getIntent().getSerializableExtra(MainActivity.EXTRA_MRZ_DATA);
        DriverLicenseData driverLicenseData = (DriverLicenseData) getIntent().getSerializableExtra(MainActivity.EXTRA_DRIVER_LICENSE_DATA);

        findViewById(R.id.btn_back).setOnClickListener(v -> getOnBackPressedDispatcher().onBackPressed());

        LinearLayout container = findViewById(R.id.container_result);
        if (mrzData != null) {
            showMrzData(container, mrzData);
        } else if (driverLicenseData != null) {
            showDriverLicenseData(container, driverLicenseData);
        }
    }

    private void showMrzData(LinearLayout container, MRZData data) {
        MRZDataFieldsValidation validation = data.fieldsValidation;
        addRow(container, "Document Type", data.documentType, false);
        addRow(container, "First Name", data.firstName, isFailed(validation.firstNameValidation));
        addRow(container, "Last Name", data.lastName, isFailed(validation.lastNameValidation));
        addRow(container, "Sex", data.sex, isFailed(validation.sexValidation));
        addRow(container, "Issuing State", data.issuingState, isFailed(validation.issuingStateValidation));
        addRow(container, "Nationality", data.nationality, isFailed(validation.nationalityValidation));
        addRow(container, "Date of Birth", data.dateOfBirth, isFailed(validation.dateOfBirthValidation));
        addRow(container, "Date of Expire", data.dateOfExpire, isFailed(validation.dateOfExpireValidation));
        addRow(container, "Document Number", data.documentNumber, isFailed(validation.documentNumberValidation));
        addRow(container, "Age", String.valueOf(data.age), false);
        addRowIfPresent(container, "Optional Data 1", data.optionalData1, isFailed(validation.optionalData1Validation));
        addRowIfPresent(container, "Optional Data 2", data.optionalData2, isFailed(validation.optionalData2Validation));
        addRowIfPresent(container, "Personal Number", data.personalNumber, isFailed(validation.personalNumberValidation));
        addRow(container, "MRZ Text", data.mrzText, isFailed(validation.mrzTextValidation));
    }

    private void showDriverLicenseData(LinearLayout container, DriverLicenseData data) {
        DriverLicenseDataFieldsValidation validation = data.fieldsValidation;
        addRow(container, "Document Type", data.documentType, false);
        addRow(container, "Name", data.name, isFailed(validation.nameValidation));
        // The following fields are only populated for specific doc types (see
        // the field comments in DriverLicenseData), so they are hidden when empty.
        addRowIfPresent(container, "State", data.state, isFailed(validation.stateValidation));
        addRowIfPresent(container, "State/Province", data.stateOrProvince, isFailed(validation.stateOrProvinceValidation));
        addRowIfPresent(container, "Initials", data.initials, false);
        addRowIfPresent(container, "City", data.city, isFailed(validation.cityValidation));
        addRowIfPresent(container, "Address", data.address, isFailed(validation.addressValidation));
        addRowIfPresent(container, "ID Number", data.idNumber, false);
        addRowIfPresent(container, "ID Number Type", data.idNumberType, false);
        addRow(container, "License Number", data.licenseNumber, isFailed(validation.licenseNumberValidation));
        addRowIfPresent(container, "License Issue Number", data.licenseIssueNumber, false);
        addRowIfPresent(container, "Issued Date", data.issuedDate, isFailed(validation.issuedDateValidation));
        addRowIfPresent(container, "Expiration Date", data.expirationDate, isFailed(validation.expirationDateValidation));
        addRowIfPresent(container, "Birth Date", data.birthDate, isFailed(validation.birthDateValidation));
        addRowIfPresent(container, "Sex", data.sex, isFailed(validation.sexValidation));
        addRowIfPresent(container, "Height", data.height, isFailed(validation.heightValidation));
        addRowIfPresent(container, "Issued Country", data.issuedCountry, isFailed(validation.issuedCountryValidation));
        addRowIfPresent(container, "Vehicle Class", data.vehicleClass, isFailed(validation.vehicleClassValidation));
        addRowIfPresent(container, "Driver Restriction Codes", data.driverRestrictionCodes, false);
        addRowIfPresent(container, "Raw Text", data.rawText, false);
    }

    private boolean isFailed(@EnumValidationStatus int status) {
        return status == EnumValidationStatus.VS_FAILED;
    }

    private void addRowIfPresent(LinearLayout container, String label, String value, boolean failed) {
        if (value != null && !value.trim().isEmpty()) {
            addRow(container, label, value, failed);
        }
    }

    private void addRow(LinearLayout container, String label, String value, boolean failed) {
        LinearLayout row = (LinearLayout) getLayoutInflater().inflate(R.layout.item_result_row, container, false);
        TextView labelView = row.findViewById(R.id.tv_label);
        TextView valueView = row.findViewById(R.id.tv_value);
        labelView.setText(label);
        valueView.setText(value == null ? "" : value);
        // Keep the theme text color for valid values so it stays readable in
        // dark mode; only failed values are highlighted.
        if (failed) {
            valueView.setTextColor(ContextCompat.getColor(this, R.color.validation_failed));
        }
        container.addView(row);
    }
}