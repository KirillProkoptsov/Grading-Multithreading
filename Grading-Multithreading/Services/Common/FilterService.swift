//
//  FilterService.swift
//  Grading-Multithreading
//
//  Created by Prokoptsov on 23.08.2024.
//

import UIKit

enum FilterService {
	static func applyFilter(for image: UIImage) -> UIImage? {
		guard let data = image.pngData() else { return nil }
		let inputImage = CIImage(data: data)

		let context = CIContext(options: nil)

		guard let filter = CIFilter(name: "CISepiaTone") else { return nil }
		filter.setValue(inputImage, forKey: kCIInputImageKey)
		filter.setValue(0.8, forKey: "inputIntensity")

		guard
			let outputImage = filter.outputImage,
			let outImage = context.createCGImage(outputImage, from: outputImage.extent)
		else {
			return nil
		}

		return UIImage(cgImage: outImage)
	}
}
