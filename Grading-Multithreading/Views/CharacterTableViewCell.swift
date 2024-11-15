//
//  CharacterTableViewCell.swift
//  Grading-Multithreading
//
//  Created by Prokoptsov on 23.08.2024.
//

import UIKit

final class CharacterTableViewCell: UITableViewCell {

	// MARK: - Private properties

	private let characterImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 8
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 18)
		label.textColor = .black
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let statusLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14)
		label.textColor = .gray
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	// MARK: - Lifecycle

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
//		characterImageView.image = nil
	}

	// MARK: - Setup Views

	private func setupViews() {
		contentView.addSubview(characterImageView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(statusLabel)
	}

	// MARK: - Setup Constraints

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			// Character ImageView
			characterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			characterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			characterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
			characterImageView.heightAnchor.constraint(equalToConstant: 100),
			characterImageView.widthAnchor.constraint(equalToConstant: 100),

			// Title Label
			titleLabel.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 16),
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

			// Status Label
			statusLabel.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 16),
			statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
			statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
		])
	}

	// MARK: - Configure Cell

	func configure(with character: CharacterDomain) {
		titleLabel.text = character.name
		statusLabel.text = character.status
		if let filteredImage = character.filteredImage {
			characterImageView.image = filteredImage
		}
	}
}
