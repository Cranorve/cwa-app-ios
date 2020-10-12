// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import AVFoundation
import Foundation
import UIKit


class ExposureSubmissionOverviewViewController: DynamicTableViewController, SpinnerInjectable {

	// MARK: - Attributes.

	var spinner: UIActivityIndicatorView?
	private(set) weak var coordinator: ExposureSubmissionCoordinating?
	private(set) weak var service: ExposureSubmissionService?

	// MARK: - Initializers.

	required init?(coder: NSCoder, coordinator: ExposureSubmissionCoordinating, exposureSubmissionService: ExposureSubmissionService) {
		self.service = exposureSubmissionService
		self.coordinator = coordinator
		super.init(coder: coder)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View lifecycle methods.

	override func viewDidLoad() {
		super.viewDidLoad()
		dynamicTableViewModel = dynamicTableData()
		setupView()
	}

	private func setupView() {
		tableView.register(
			UINib(
				nibName: String(describing: ExposureSubmissionTestResultHeaderView.self),
				bundle: nil
			),
			forHeaderFooterViewReuseIdentifier: "test"
		)
		tableView.register(UINib(nibName: String(describing: ExposureSubmissionImageCardCell.self), bundle: nil), forCellReuseIdentifier: CustomCellReuseIdentifiers.imageCard.rawValue)
		title = AppStrings.ExposureSubmissionDispatch.title
	}

	// MARK: - Helpers.

	/// Shows the data privacy disclaimer and only lets the
	/// user scan a QR code after accepting.
	func showDisclaimer() {
		preconditionFailure("No longer used")
 	}
}

// MARK: Data extension for DynamicTableView.

private extension DynamicCell {
	static func imageCard(
		title: String,
		description: String? = nil,
		attributedDescription: NSAttributedString? = nil,
		image: UIImage?,
		action: DynamicAction,
		accessibilityIdentifier: String? = nil) -> Self {
		.identifier(ExposureSubmissionOverviewViewController.CustomCellReuseIdentifiers.imageCard, action: action) { _, cell, _ in
			guard let cell = cell as? ExposureSubmissionImageCardCell else { return }
			cell.configure(
				title: title,
				description: description ?? "",
				attributedDescription: attributedDescription,
				image: image,
				accessibilityIdentifier: accessibilityIdentifier)
		}
	}
}

private extension ExposureSubmissionOverviewViewController {
	func dynamicTableData() -> DynamicTableViewModel {
		var data = DynamicTableViewModel([])

		let header = DynamicHeader.blank

		data.add(
			.section(
				header: header,
				separators: false,
				cells: [
					.body(
						text: AppStrings.ExposureSubmissionDispatch.description,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.description)
				]
			)
		)

		data.add(DynamicSection.section(cells: [
			.imageCard(
				title: AppStrings.ExposureSubmissionDispatch.qrCodeButtonTitle,
				description: AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription,
				image: UIImage(named: "Illu_Submission_QRCode"),
				action: .execute(block: { [weak self] _ in self?.showDisclaimer() }),
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.qrCodeButtonDescription
			),
			.imageCard(
				title: AppStrings.ExposureSubmissionDispatch.tanButtonTitle,
				description: AppStrings.ExposureSubmissionDispatch.tanButtonDescription,
				image: UIImage(named: "Illu_Submission_TAN"),
				action: .execute(block: { [weak self] _ in self?.coordinator?.showTanScreen() }),
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.tanButtonDescription
			),
			.imageCard(
				title: AppStrings.ExposureSubmissionDispatch.hotlineButtonTitle,
				attributedDescription: applyFont(style: .headline, to: AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription, with: AppStrings.ExposureSubmissionDispatch.positiveWord),
				image: UIImage(named: "Illu_Submission_Anruf"),
				action: .execute(block: { [weak self] _ in self?.coordinator?.showHotlineScreen() }),
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.hotlineButtonDescription
			)
		]))

		return data
	}

	private func applyFont(style: ENAFont, to text: String, with content: String) -> NSAttributedString {
		return NSMutableAttributedString.generateAttributedString(normalText: text, attributedText: [
			NSAttributedString(string: content, attributes: [
				NSAttributedString.Key.font: UIFont.enaFont(for: style)
			])
		])
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionOverviewViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case imageCard = "imageCardCell"
	}
}
