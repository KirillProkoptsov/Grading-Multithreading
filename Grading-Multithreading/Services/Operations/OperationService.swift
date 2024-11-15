//
//  OperationService.swift
//  Grading-Multithreading
//
//  Created by Prokoptsov on 23.08.2024.
//

import Foundation
import UIKit.UIImage

final class OperationService {

	// MARK: - Private properties

	private let charactersListOperationQueue = OperationQueue()

	private lazy var imageProccessingInProgress: [IndexPath: Operation] = [:]
	private lazy var imageProccessingQueue: OperationQueue = {
		var queue = OperationQueue()
		queue.name = "imageProccessing queue"
		return queue
	}()

	private let processingQueue = DispatchQueue(label: "com.app.operationService.processingQueue")

	// MARK: - Internal methods

	func loadCharacters(from url: URL, completion: @escaping (Result<ResponseModel, Error>) -> Void) {
		let loadOperation = LoadCharactersOperation(url: url)
		loadOperation.completionBlock = {
			completion(loadOperation.result)
		}
		charactersListOperationQueue.addOperation(loadOperation)
	}

	func loadCharacterImage(
		for character: CharacterDomain,
		at indexPath: IndexPath,
		completion: @escaping (CharacterDomain) -> Void
	) {
		processingQueue.sync {
			guard imageProccessingInProgress[indexPath] == nil else { return }
		}

		let loadImageOperation = LoadImageOperation(character: character) { updatedChar in
			completion(updatedChar)

			self.processingQueue.async {
				if self.imageProccessingInProgress[indexPath] != nil {
					self.imageProccessingInProgress.removeValue(forKey: indexPath)
				}
			}
		}

		processingQueue.sync {
			self.imageProccessingInProgress[indexPath] = loadImageOperation
		}
		imageProccessingQueue.addOperation(loadImageOperation)
	}

	func suspendAllImagesOperations() {
		charactersListOperationQueue.isSuspended = true
	}

	func resumeAllImagesOperations() {
		charactersListOperationQueue.isSuspended = false
	}

	func resetAll() {
		charactersListOperationQueue.cancelAllOperations()
		imageProccessingQueue.cancelAllOperations()
		processingQueue.sync {
			imageProccessingInProgress = [:]
		}
	}

	func startOperationsFor(for indexpaths: [IndexPath]?, and characters: [CharacterDomain]) -> [IndexPath] {
		if let pathsArray = indexpaths {
			let allPendingOperations = Set(imageProccessingInProgress.keys)

			let canceledOperations = allPendingOperations.subtracting(Set(pathsArray))

			let startingOperations = Set(pathsArray).subtracting(allPendingOperations)

			for indexPath in canceledOperations {
				if let pendingOperation = imageProccessingInProgress[indexPath] {
					pendingOperation.cancel()
				}
				imageProccessingInProgress.removeValue(forKey: indexPath)
			}

			return Array(startingOperations)
		} else {
			return []
		}
	}
}
