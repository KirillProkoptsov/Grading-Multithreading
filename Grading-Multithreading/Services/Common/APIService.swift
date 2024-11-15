//
//  APIService.swift
//  Grading-Multithreading
//
//  Created by Prokoptsov on 23.08.2024.
//

import Foundation

enum APIService {
	static func getCharacters(url: URL, completion: @escaping (Result<ResponseModel, Error>) -> Void) {
		let _ = URLSession.custom.dataTask(with: url) { data, _, error in
			if let data {
				do {
					let response = try JSONDecoder().decode(ResponseModel.self, from: data)
					completion(.success(response))
				} catch {
					completion(.failure(error))
				}
			} else if let error {
				completion(.failure(error))
			}
		}
			.resume()
	}
}
