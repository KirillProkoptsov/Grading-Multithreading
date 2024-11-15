//
//  ConcurrencyService.swift
//  Grading-Multithreading
//
//  Created by Prokoptsov on 23.08.2024.
//

import Foundation
import UIKit.UIImage

actor SwiftConcurrencyService {
	
	// MARK: - Private properties
	
	private var taskDictionary: [IndexPath: Task<Void, Never>] = [:]
	
	// MARK: - Internal methods
	
	func loadCharacters(from url: URL) async throws -> ResponseModel {
		return try await withCheckedThrowingContinuation { continuation in
			APIService.getCharacters(url: url) { result in
				switch result {
				case .success(let success):
					continuation.resume(returning: success)
				case .failure(let failure):
					continuation.resume(throwing: failure)
				}
			}
		}
	}

	func loadCharacterImage(
		for character: CharacterDomain,
		at indexPath: IndexPath,
		completion: @escaping (CharacterDomain) -> Void
	) {
		var character = character
		guard taskDictionary[indexPath] == nil else { return }
		let task = Task(priority: .userInitiated) {
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

			self.taskDictionary.removeValue(forKey: indexPath)
		}
		
		taskDictionary[indexPath] = task
	}
	
	func suspendAllImageOperations() {
		for task in taskDictionary.values {
			task.cancel()
		}
		taskDictionary.removeAll()
	}
}

