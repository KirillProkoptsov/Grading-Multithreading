//
//  LoadImageOperation.swift
//  Grading-Multithreading
//
//  Created by Prokoptsov on 06.09.2024.
//

import Foundation
import UIKit.UIImage

final class LoadImageOperation: Operation {
	
	private let completion: (CharacterDomain) -> Void
	private var character: CharacterDomain
	
	init(
		character: CharacterDomain,
		completion: @escaping (CharacterDomain) -> Void
	) {
		self.character = character
		self.completion = completion
	}
	
	override func main() {
		guard character.state == .new,
					!isCancelled else {
			completion(character)
			return
		}
		
		guard let url = URL(string: character.image),
					let data = try? Data(contentsOf: url),
					let image = UIImage(data: data),
					!isCancelled else {
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
	}
}
