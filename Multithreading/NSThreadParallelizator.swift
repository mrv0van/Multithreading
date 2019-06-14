//
//  NSThreadParallelizator.swift
//  Multithreading
//
//  Created by Vladimir Ozerov on 14/06/2019.
//  Copyright © 2019 Sberbank. All rights reserved.
//

import Foundation


enum NSThreadParallelizatorError: Error {
	case qualityOfService
}



final class NSThreadParallelizator : Parallelizator {

	// MARK: Life cycle
	
	init() {
		qosClass = QOS_CLASS_BACKGROUND
	}
	
	
	// MARK: Protocol conformance <Parallelizator>
	var name: String! {
		return "NSThread"
	}
	
	var qosClass: qos_class_t!

	func performSync(action: Parallelizator.Action!) throws {
		let thread = try createNSThread(action: action)
		thread.start()
		
		while !thread.isFinished {
			Thread.sleep(forTimeInterval: 0.1)
		}
	}
	
	func performAsync(action: Parallelizator.Action!) throws {
		let thread = try createNSThread(action: action)
		thread.start()
	}
	
	
	// MARK: Routine
	
	func createNSThread(action: Parallelizator.Action!) throws -> Thread {
		let thread = Thread(block: action)
		guard let qualityOfService = QualityOfService(qosClass: qosClass) else {
			throw NSThreadParallelizatorError.qualityOfService
		}
		thread.qualityOfService = qualityOfService
		return thread
	}
}
