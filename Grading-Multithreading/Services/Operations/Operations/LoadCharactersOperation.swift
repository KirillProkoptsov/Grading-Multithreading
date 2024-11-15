//
//  LoadCharactersOperation.swift
//  Grading-Multithreading
//
//  Created by Prokoptsov on 06.09.2024.
//

import Foundation

final class LoadCharactersOperation: Operation {

	// MARK: - Internal properties

	var result: Result<ResponseModel, Error> = .failure(CustomError.canceled)

	override var isExecuting: Bool {
		get { return _isExecuting }
		set {
			willChangeValue(forKey: "isExecuting")
			_isExecuting = newValue
			didChangeValue(forKey: "isExecuting")
		}
	}

	override var isFinished: Bool {
		get { return _isFinished }
		set {
			willChangeValue(forKey: "isFinished")
			_isFinished = newValue
			didChangeValue(forKey: "isFinished")
		}
	}

	// MARK: - Private properties

	private let url: URL

	private var _isExecuting: Bool = false
	private var _isFinished: Bool = false

	// MARK: - Init

	init(url: URL) {
		self.url = url
	}

	// MARK: - Lifecycle

	override func start() {
		guard !isCancelled else {
			finish()
			return
		}

		isExecuting = true

		main()
	}

	override func cancel() {
		super.cancel()
		finish()
	}

	override func main() {
		guard !isCancelled else {
			self.result = .failure(CustomError.canceled)
			finish()
			return
		}
		APIService.getCharacters(url: url) { [unowned self] result in
			guard !self.isCancelled else {
				self.result = .failure(CustomError.canceled)
				finish()
				return
			}
			self.result = result
			finish()
		}
	}

	// MARK: - Private methods

	private func finish() {
		isExecuting = false
		isFinished = true
	}
}
