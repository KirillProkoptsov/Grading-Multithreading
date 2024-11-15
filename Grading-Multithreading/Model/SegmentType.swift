//
//  SegmentType.swift
//  Grading-Multithreading
//
//  Created by Prokoptsov on 23.08.2024.
//

import Foundation

enum SegmentType: Int, CaseIterable {
	case operations
	case gcd
	case swiftConcurrency

	var title: String {
		switch self {
		case .operations:
			return "Operations"
		case .gcd:
			return "GCD"
		case .swiftConcurrency:
			return "Swift Concurrency"
		}
	}
}
