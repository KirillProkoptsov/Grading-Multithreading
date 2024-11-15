import Foundation

gcdExample()
operationsExample()
concurrencyExample()

// Helpers

private func gcdExample() {
	let lock = NSLock()
	let queue = DispatchQueue(label: "dataRace.gcd.queue", attributes: .concurrent)
	let dispatchGroup = DispatchGroup()

	var sharedData = 0

	for _ in 1...1000 {
//		dispatchGroup.enter()
		queue.async {
			lock.lock()
			sharedData += 1
			lock.unlock()
//			dispatchGroup.leave()
		}
	}

	dispatchGroup.notify(queue: .main) {
		print("GCD Result: \(sharedData)")
	}
}

private func operationsExample() {
	let lock = NSLock()

	var sharedData = 0

	let operationQueue = OperationQueue()
	let operations = (1...1000).map { _ in
		BlockOperation {
			lock.lock()
			sharedData += 1
			lock.unlock()
		}
	}

	operationQueue.addOperations(operations, waitUntilFinished: false)

	operationQueue.addBarrierBlock {
		DispatchQueue.main.async {
			print("Operations Result: \(sharedData)")
		}
	}
}

private func concurrencyExample() {
	let sharedData = SharedData()

	Task {
		await withTaskGroup(of: Void.self) { taskGroup in
			for _ in 1...1000 {
				taskGroup.addTask {
					await sharedData.increment()
				}
			}
		}

		print("Concurrency Result: \(await sharedData.value)")
	}
}

fileprivate actor SharedData {
	var value = 0

	func increment() {
		value += 1
	}
}
