//
//  NSThreadParallelizator.swift
//  Multithreading
//
//  Created by Vladimir Ozerov on 14/06/2019.
//  Copyright © 2019 Sberbank. All rights reserved.
//

import Foundation


final class NSThreadParallelizator: Parallelizator {

	// MARK: - Life cycle
	
	init() {
		qosClass = DefaultQosClass
		detached = false
	}
	
	
	// MARK: - Protocol conformance <Parallelizator>
	
	var name: String! {
		return "NSThread"
	}
	
	var qosClass: qos_class_t!
	var detached: Bool!

	func performSync(action: @escaping Parallelizator.Action) throws {
		let thread = createNSThread(action: action)
		thread.start()
		
		while !thread.isFinished {
			Thread.sleep(forTimeInterval: 0.1)
		}
	}
	
	func performAsync(action: @escaping Parallelizator.Action) throws {
		let thread = createNSThread(action: action)
		thread.start()
	}
	
	
	// MARK: - Routine
	
	fileprivate func createNSThread(action: @escaping Parallelizator.Action) -> Thread {
		let thread = Thread(block: action)
		thread.qualityOfService = qosClass.qualityOfService
		return thread
	}
}
