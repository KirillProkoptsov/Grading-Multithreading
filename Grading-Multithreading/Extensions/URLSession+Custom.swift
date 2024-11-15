//
//  URLSession+Custom.swift
//  Grading-Multithreading
//
//  Created by Prokoptsov on 23.08.2024.
//

import Foundation

extension URLSession {
	static let custom: URLSession = {
		let configuration = URLSessionConfiguration.default
		configuration.waitsForConnectivity = true
		configuration.timeoutIntervalForRequest = 30
		configuration.timeoutIntervalForResource = 60
		configuration.urlCache = nil
		return URLSession(configuration: configuration)
	}()
}
