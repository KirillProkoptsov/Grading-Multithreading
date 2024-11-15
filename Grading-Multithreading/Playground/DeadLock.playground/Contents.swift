import Foundation

private func gcdExample() {
	// Можно исправить использованием асинхронных очередей и барьеров

	let queue = DispatchQueue(label: "deadlock.queue")

	queue.sync {
		print("1")

		queue.sync {
			print("2")
		}
	}
}

private func operationsExample() {
	// Deadlock в operations можно поймать создав циклическую зависимость операций от друг друга

	let operationQueue = OperationQueue()

	let operation1 = BlockOperation {
		print("1")
	}

	let operation2 = BlockOperation {
		print("2")
	}

	operation1.addDependency(operation2)
	operation2.addDependency(operation1)

	operationQueue.addOperations([operation1, operation2], waitUntilFinished: false)
}

private func concurrencyExample() {
	// Deadlock в concurrency может случиться только в случае, если задача в Actor вызывает саму себя.
	actor Resource {
		func updateData() {
			Task {
				await self.updateData()
			}
		}
	}
}


