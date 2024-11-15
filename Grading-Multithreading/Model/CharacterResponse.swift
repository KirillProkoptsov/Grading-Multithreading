//
//  CharacterResponse.swift
//  Grading-Multithreading
//
//  Created by Prokoptsov on 23.08.2024.
//

import UIKit

struct ResponseModel: Decodable {
	let results: [Character]
}

// MARK: - Character

struct Character: Decodable {
	let id: Int
	let name: String
	let status: String
	let species: String
	let type: String
	let gender: String
	let image: String
}


struct CharacterDomain {
	let id: Int
	let name: String
	let status: String
	let species: String
	let type: String
	let gender: String
	let image: String
	var state: CharacterState

	var filteredImage: UIImage?

	init(from response: Character) {
		self.init(
			id: response.id,
			name: response.name,
			status: response.status,
			species: response.species,
			type: response.type,
			gender: response.gender,
			image: response.image,
			state: .new
		)
	}

	init(
		id: Int,
		name: String,
		status: String,
		species: String,
		type: String,
		gender: String,
		image: String,
		state: CharacterState
	) {
		self.id = id
		self.name = name
		self.status = status
		self.species = species
		self.type = type
		self.gender = gender
		self.image = image
		self.state = state
	}
}

enum CharacterState {
 case new, filtered, error
}
