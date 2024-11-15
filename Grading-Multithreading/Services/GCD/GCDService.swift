//
//  GCDService.swift
//  Grading-Multithreading
//
//  Created by Prokoptsov on 23.08.2024.
//

import Foundation
import UIKit.UIImage

final class GCDService {

	// MARK: - Private properties

	private var imageProcessingInProgress: [IndexPath: DispatchWorkItem] = [:]

	// MARK: - Internal methods

	func loadCharacters(from url: URL, completion: @escaping (Result<ResponseModel, Error>) -> Void) {
		DispatchQueue.global(qos: .background).async {
			APIService.getCharacters(url: url) { result in
				completion(result)
			}
		}
	}

	func startImageLoadingFor(for indexPaths: [IndexPath]?, and characters: [CharacterDomain]) -> [IndexPath] {
		guard let pathsArray = indexPaths else { return [] }
		
		let allPendingOperations = Set(imageProcessingInProgress.keys)
		let canceledOperations = allPendingOperations.subtracting(Set(pathsArray))
		let startingOperations = Set(pathsArray).subtracting(allPendingOperations)
		
		for indexPath in canceledOperations {
			if let pendingTask = imageProcessingInProgress[indexPath] {
				pendingTask.cancel()
			}
			imageProcessingInProgress.removeValue(forKey: indexPath)
		}
		
		return Array(startingOperations)
	}

	func loadCharacterImage(
		for character: CharacterDomain,
		at indexPath: IndexPath,
		completion: @escaping (CharacterDomain) -> Void
	) {
		guard imageProcessingInProgress[indexPath] == nil else { return }
		var character = character
		let workItem = DispatchWorkItem { [weak self] in
			guard let self = self else { return }
			guard character.state == .new else {
				return
			}

			guard let url = URL(string: character.image),
						let data = try? Data(contentsOf: url),
						let image = UIImage(data: data) else {
				character.state = .error
				completion(character)
				return
			}

			guard let filteredImage = FilterService.applyFilter(for: image) else {
				character.state = .error
				completion(character)
				return
			}

			character.state = .filtered
			character.filteredImage = filteredImage
			completion(character)

			DispatchQueue.main.async {
				self.imageProcessingInProgress.removeValue(forKey: indexPath)
			}
		}

		imageProcessingInProgress[indexPath] = workItem
		DispatchQueue.global(qos: .userInitiated).async(execute: workItem)
	}

	func suspendAllImageOperations() {
		for workItem in imageProcessingInProgress.values {
			workItem.cancel()
		}
		imageProcessingInProgress.removeAll()
	}
}
