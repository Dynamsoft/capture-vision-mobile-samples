/*
 * This is the sample of Dynamsoft Capture Vision.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

class ResultViewController: UIViewController {

    var mrzData: MRZData?
    var driverLicenseData: DriverLicenseData?

    private let tableView = UITableView(
        frame: .zero,
        style: .plain
    )

    private struct ResultRow {
        let label: String
        let value: String?
        let failed: Bool
    }

    private var rows: [ResultRow] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupData()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Result"
        setupTableView()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60

        tableView.dataSource = self

        tableView.register(
            ResultTableViewCell.self,
            forCellReuseIdentifier: ResultTableViewCell.identifier
        )

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }

    private func setupData() {
        rows.removeAll()

        if let mrzData = mrzData {
            showMrzData(mrzData)
        } else if let driverLicenseData = driverLicenseData {
            showDriverLicenseData(driverLicenseData)
        }

        tableView.reloadData()
    }

    // MARK: - MRZ Data

    private func showMrzData(_ data: MRZData) {
        let validation = data.fieldsValidation

        addRow(
            label: "Document Type",
            value: data.documentType,
            failed: false
        )

        addRow(
            label: "First Name",
            value: data.firstName,
            failed: isFailed(validation.firstNameValidation)
        )

        addRow(
            label: "Last Name",
            value: data.lastName,
            failed: isFailed(validation.lastNameValidation)
        )

        addRow(
            label: "Sex",
            value: data.sex,
            failed: isFailed(validation.sexValidation)
        )

        addRow(
            label: "Issuing State",
            value: data.issuingState,
            failed: isFailed(validation.issuingStateValidation)
        )

        addRow(
            label: "Nationality",
            value: data.nationality,
            failed: isFailed(validation.nationalityValidation)
        )

        addRow(
            label: "Date of Birth",
            value: data.dateOfBirth,
            failed: isFailed(validation.dateOfBirthValidation)
        )

        addRow(
            label: "Date of Expire",
            value: data.dateOfExpire,
            failed: isFailed(validation.dateOfExpireValidation)
        )

        addRow(
            label: "Document Number",
            value: data.documentNumber,
            failed: isFailed(validation.documentNumberValidation)
        )

        addRow(
            label: "Age",
            value: String(data.age),
            failed: false
        )

        addRowIfPresent(
            label: "Optional Data 1",
            value: data.optionalData1,
            failed: isFailed(
                validation.optionalData1Validation
            )
        )

        addRowIfPresent(
            label: "Optional Data 2",
            value: data.optionalData2,
            failed: isFailed(
                validation.optionalData2Validation
            )
        )

        addRowIfPresent(
            label: "Personal Number",
            value: data.personalNumber,
            failed: isFailed(
                validation.personalNumberValidation
            )
        )

        addRow(
            label: "MRZ Text",
            value: data.mrzText,
            failed: isFailed(
                validation.mrzTextValidation
            )
        )
    }

    // MARK: - Driver License Data

    private func showDriverLicenseData(
        _ data: DriverLicenseData
    ) {
        let validation = data.fieldsValidation

        addRow(
            label: "Document Type",
            value: data.documentType,
            failed: false
        )

        addRow(
            label: "Name",
            value: data.name,
            failed: isFailed(
                validation.nameValidation
            )
        )

        // State - AAMVA_DL_ID
        addRowIfPresent(
            label: "State",
            value: data.state,
            failed: isFailed(
                validation.stateValidation
            )
        )

        // State/Province - AAMVA_DL_ID_WITH_MAG_STRIPE
        addRowIfPresent(
            label: "State/Province",
            value: data.stateOrProvince,
            failed: isFailed(
                validation.stateOrProvinceValidation
            )
        )

        // Initials - SOUTH_AFRICA_DL
        addRowIfPresent(
            label: "Initials",
            value: data.initials,
            failed: false
        )

        addRowIfPresent(
            label: "City",
            value: data.city,
            failed: isFailed(
                validation.cityValidation
            )
        )

        addRowIfPresent(
            label: "Address",
            value: data.address,
            failed: isFailed(
                validation.addressValidation
            )
        )

        // SOUTH_AFRICA_DL
        addRowIfPresent(
            label: "ID Number",
            value: data.idNumber,
            failed: false
        )

        // SOUTH_AFRICA_DL
        addRowIfPresent(
            label: "ID Number Type",
            value: data.idNumberType,
            failed: false
        )

        addRow(
            label: "License Number",
            value: data.licenseNumber,
            failed: isFailed(
                validation.licenseNumberValidation
            )
        )

        // SOUTH_AFRICA_DL
        addRowIfPresent(
            label: "License Issue Number",
            value: data.licenseIssueNumber,
            failed: false
        )

        addRowIfPresent(
            label: "Issued Date",
            value: data.issuedDate,
            failed: isFailed(
                validation.issuedDateValidation
            )
        )

        addRowIfPresent(
            label: "Expiration Date",
            value: data.expirationDate,
            failed: isFailed(
                validation.expirationDateValidation
            )
        )

        addRowIfPresent(
            label: "Birth Date",
            value: data.birthDate,
            failed: isFailed(
                validation.birthDateValidation
            )
        )

        addRowIfPresent(
            label: "Sex",
            value: data.sex,
            failed: isFailed(
                validation.sexValidation
            )
        )

        addRowIfPresent(
            label: "Height",
            value: data.height,
            failed: isFailed(
                validation.heightValidation
            )
        )

        addRowIfPresent(
            label: "Issued Country",
            value: data.issuedCountry,
            failed: isFailed(
                validation.issuedCountryValidation
            )
        )

        addRowIfPresent(
            label: "Vehicle Class",
            value: data.vehicleClass,
            failed: isFailed(
                validation.vehicleClassValidation
            )
        )

        // SOUTH_AFRICA_DL
        addRowIfPresent(
            label: "Driver Restriction Codes",
            value: data.driverRestrictionCodes,
            failed: false
        )

        addRowIfPresent(
            label: "Raw Text",
            value: data.rawText,
            failed: false
        )
    }

    // MARK: - Validation

    private func isFailed(
        _ status: ValidationStatus
    ) -> Bool {
        return status == .failed
    }

    // MARK: - Rows

    private func addRowIfPresent(
        label: String,
        value: String?,
        failed: Bool
    ) {
        guard let value = value,
              !value
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .isEmpty else {
            return
        }

        addRow(
            label: label,
            value: value,
            failed: failed
        )
    }

    private func addRow(
        label: String,
        value: String?,
        failed: Bool
    ) {
        rows.append(
            ResultRow(
                label: label,
                value: value,
                failed: failed
            )
        )
    }
}

// MARK: - UITableViewDataSource

extension ResultViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return rows.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ResultTableViewCell.identifier,
            for: indexPath
        ) as? ResultTableViewCell else {
            return UITableViewCell()
        }

        let row = rows[indexPath.row]

        cell.configure(
            label: row.label,
            value: row.value,
            failed: row.failed
        )

        return cell
    }
}

// MARK: - ResultTableViewCell

final class ResultTableViewCell: UITableViewCell {

    static let identifier = "ResultTableViewCell"

    private let labelView = UILabel()
    private let valueView = UILabel()

    private let stackView = UIStackView()

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )

        setupUI()
    }

    required init?(
        coder: NSCoder
    ) {
        super.init(coder: coder)

        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none

        labelView.font = UIFont.systemFont(
            ofSize: 15
        )

        labelView.textColor = .label
        labelView.numberOfLines = 0

        valueView.font = UIFont.systemFont(
            ofSize: 15
        )

        valueView.textColor = .label
        valueView.numberOfLines = 0

        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

        stackView.addArrangedSubview(labelView)
        stackView.addArrangedSubview(valueView)

        labelView.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        labelView.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )

        valueView.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 12
            ),

            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),

            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),

            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -12
            ),

            labelView.widthAnchor.constraint(
                equalToConstant: 130
            )
        ])
    }

    func configure(
        label: String,
        value: String?,
        failed: Bool
    ) {
        labelView.text = label
        valueView.text = value ?? ""

        valueView.textColor = failed ? .red : .label
    }
}
