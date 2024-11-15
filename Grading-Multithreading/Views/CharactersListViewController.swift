//
//  ViewController.swift
//  Grading-Multithreading
//
//  Created by Prokoptsov on 23.08.2024.
//

import UIKit

final class CharactersListViewController: UIViewController {

	// MARK: - Outlets

	@IBOutlet private var segmentControl: UISegmentedControl!
	@IBOutlet private var loadButton: UIButton!
	@IBOutlet private var resetButton: UIButton!
	@IBOutlet private var tableView: UITableView!

	// MARK: - Private properties

	private let baseURL = URL(string: "https://rickandmortyapi.com/api/character")!

	private var characters: [CharacterDomain] = []

	private var selectedSegment: SegmentType = .operations

	private let operationService = OperationService()
	private let gcdService = GCDService()
	private let swiftConcurrencyService = SwiftConcurrencyService()

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	// MARK: - Private methods

	private func setupUI() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: "cell")
		tableView.allowsSelection = false

		segmentControl.removeAllSegments()

		SegmentType.allCases.forEach {
			segmentControl.insertSegment(withTitle: $0.title, at: $0.rawValue, animated: false)
		}
		segmentControl.selectedSegmentIndex = self.selectedSegment.rawValue
		segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)


		loadButton.addTarget(self, action: #selector(loadButtonTapped(_:)), for: .touchUpInside)
		resetButton.addTarget(self, action: #selector(resetButtonTapped(_:)), for: .touchUpInside)
	}

	private func reset() {
		operationService.resetAll()
		gcdService.suspendAllImageOperations()
		Task { await swiftConcurrencyService.suspendAllImageOperations() }
		characters = []
		tableView.reloadData()
	}

	private func startLoadingForOperation(indexPath: IndexPath) {
		operationService.loadCharacterImage(for: characters[indexPath.row], at: indexPath) { [weak self, indexPath] char in
			DispatchQueue.main.sync {
				self?.characters[indexPath.row] = char
				self?.tableView.reloadRows(at: [indexPath], with: .none)
			}
		}
	}

	private func startLoadingForGCD(indexPath: IndexPath) {
		gcdService.loadCharacterImage(for: characters[indexPath.row], at: indexPath) { [weak self, indexPath] char in
			DispatchQueue.main.sync {
				self?.characters[indexPath.row] = char
				self?.tableView.reloadRows(at: [indexPath], with: .none)
			}
		}
	}

	private func startLoadingForConcurrency(indexPath: IndexPath) {
		Task {
			let character = characters[indexPath.row]
			await swiftConcurrencyService.loadCharacterImage(for: character, at: indexPath) { [weak self, indexPath] char in
				DispatchQueue.main.sync {
					self?.characters[indexPath.row] = char
					self?.tableView.reloadRows(at: [indexPath], with: .none)
				}
			}
		}
	}

	// MARK: - Actions

	@objc private func loadButtonTapped(_ sender: UIButton) {
		switch selectedSegment {
		case .operations:
			operationService.loadCharacters(from: baseURL) { [weak self] result in
				DispatchQueue.main.sync {
					switch result {
					case .success(let success):
						self?.characters = success.results.map(CharacterDomain.init(from:))
						self?.tableView.reloadData()
					default:
						break
					}
				}
			}
		case .gcd:
			gcdService.loadCharacters(from: baseURL) { [weak self] result in
				DispatchQueue.main.sync {
					switch result {
					case .success(let success):
						self?.characters = success.results.map(CharacterDomain.init(from:))
						self?.tableView.reloadData()
					default:
						break
					}
				}
			}
		case .swiftConcurrency:
			Task { @MainActor in
				guard let characters = try? await swiftConcurrencyService.loadCharacters(from: baseURL) else { return }
				self.characters = characters.results.map(CharacterDomain.init(from:))
				self.tableView.reloadData()
			}
		}
	}

	@objc private func resetButtonTapped(_ sender: UIButton) {
		reset()
	}

	@objc private func segmentChanged(_ sender: UISegmentedControl) {
		guard let selectedSegment = SegmentType(rawValue: sender.selectedSegmentIndex) else { return }
		self.selectedSegment = selectedSegment
		reset()
	}
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CharactersListViewController: UITableViewDataSource, UITableViewDelegate {

	func numberOfSections(in tableView: UITableView) -> Int {
		1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		characters.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CharacterTableViewCell
		let character = characters[indexPath.row]
		cell.configure(with: character)

		switch character.state {
		case .new:
			switch selectedSegment {
			case .operations:
				startLoadingForOperation(indexPath: indexPath)
			case .gcd:
				startLoadingForGCD(indexPath: indexPath)
			case .swiftConcurrency:
				startLoadingForConcurrency(indexPath: indexPath)
			}
		default:
			break
		}
		return cell
	}

	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		switch selectedSegment {
		case .operations:
			operationService.suspendAllImagesOperations()
		case .gcd:
			gcdService.suspendAllImageOperations()
		case .swiftConcurrency:
			Task { await swiftConcurrencyService.suspendAllImageOperations() }
		}
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		switch selectedSegment {
		case .operations:
			let indices = operationService.startOperationsFor(for: tableView.indexPathsForVisibleRows, and: characters)
			for index in indices {
				startLoadingForOperation(indexPath: index)
			}
			operationService.resumeAllImagesOperations()
		case .gcd:
			let indices = gcdService.startImageLoadingFor(for: tableView.indexPathsForVisibleRows, and: characters)
			for index in indices {
				startLoadingForGCD(indexPath: index)
			}
		case .swiftConcurrency:
			let visibleRows = tableView.indexPathsForVisibleRows ?? []
			for index in visibleRows {
				startLoadingForConcurrency(indexPath: index)
			}
		}
	}
}
