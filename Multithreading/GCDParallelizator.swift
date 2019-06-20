//
//  GCDParallelizator.swift
//  Multithreading
//
//  Created by mrv0van on 17/06/2019.
//  Copyright © 2019 Sberbank. All rights reserved.
//

import Foundation


enum GCDParallelizatorError: Error {
	case qualityOfService
}


final class GCDParallelizator: Parallelizator {
	
	// MARK: - Life cycle
	
	init() {
		qosClass = DefaultQosClass
		detached = false
	}
	
	
	// MARK: - Protocol conformance <Parallelizator>
	
	var name: String {
		return "Grand Central Dispatch"
	}
	
	var qosClass: qos_class_t
	var detached: Bool

	func performSync(action: @escaping Parallelizator.Action) throws {
		let qosClass = try dispatchQosClass()
		let workItem = createWorkItem(dispatchQoSClass: qosClass, action: action)
		DispatchQueue.global().sync(execute: workItem)
	}
	
	func performAsync(action: @escaping Parallelizator.Action) throws {
		let qosClass = try dispatchQosClass()
		let workItem = createWorkItem(dispatchQoSClass: qosClass, action: action)
		DispatchQueue.global().async(execute: workItem)
	}
	
	
	// MARK: - Routine
	
	private func dispatchQosClass() throws -> DispatchQoS.QoSClass {
		let dispatchQosClassRaw = DispatchQoS.QoSClass(rawValue: qosClass)
		guard let dispatchQosClass = dispatchQosClassRaw else {
			throw GCDParallelizatorError.qualityOfService
		}
		return dispatchQosClass
	}
	
	private func createWorkItem(dispatchQoSClass: DispatchQoS.QoSClass, action: @escaping Parallelizator.Action) -> DispatchWorkItem {
		let dispatchQoS = DispatchQoS(qosClass: dispatchQoSClass, relativePriority: 0)
		let dispatchFlags: DispatchWorkItemFlags = detached ? [.detached, .enforceQoS] : [.enforceQoS]
		let workItem = DispatchWorkItem(qos: dispatchQoS, flags: dispatchFlags, block: action)
		return workItem
	}
}
