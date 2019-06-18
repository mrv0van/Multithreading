//
//  PThread.swift
//  Multithreading
//
//  Created by Vladimir Ozerov on 13/06/2019.
//  Copyright © 2019 Sberbank. All rights reserved.
//

import Foundation


enum PThreadParallelizatorError: Error {
	case attributesInit
	case detachState
	case qosClass
	case pThreadCreate
}


final class PThreadParallelizator: Parallelizator {
	
	// MARK: - Life cycle
	
	init() {
		qosClass = DefaultQosClass
		detached = false
	}
	
	
	// MARK: - Protocol conformance <Parallelizator>

	var name: String! {
		return "pthread"
	}
	
	var qosClass: qos_class_t!
	var detached: Bool!

	func performSync(action: @escaping Parallelizator.Action) throws {
		let pThread = try createPThread(action: action)
		pthread_join(pThread, nil)
	}
	
	func performAsync(action: @escaping Parallelizator.Action) throws {
		let pThread = try createPThread(action: action)
		pthread_detach(pThread)
	}
	
	
	// MARK: - Routine
	
	fileprivate func createPThread(action: @escaping Parallelizator.Action) throws -> pthread_t {
		var attributesPtr = UnsafeMutablePointer<pthread_attr_t>.allocate(capacity: 1)
		let attributesInitResult = pthread_attr_init(attributesPtr)
		guard 0 == attributesInitResult else {
			throw PThreadParallelizatorError.attributesInit
		}
		
		defer {
			pthread_attr_destroy(attributesPtr)
		}
		
		let detachedState = detached ? PTHREAD_CREATE_DETACHED : PTHREAD_CREATE_JOINABLE
		let setDetachStateResult = pthread_attr_setdetachstate(attributesPtr, detachedState)
		guard 0 == setDetachStateResult else {
			throw PThreadParallelizatorError.detachState
		}
		
		let setQosClassResult = pthread_attr_set_qos_class_np(attributesPtr, qosClass, 0)
		guard 0 == setQosClassResult else {
			throw PThreadParallelizatorError.qosClass
		}
		
		let contextPtr = UnsafeMutablePointer<Parallelizator.Action>.allocate(capacity: 1)
		contextPtr.initialize(to: action)
		contextPtr.pointee = action
		
		var pThread: pthread_t? = nil
		let pthreadCreateResult = pthread_create(&pThread, attributesPtr, pThreadBody, contextPtr)
		guard 0 == pthreadCreateResult, let createdPThread = pThread else {
			throw PThreadParallelizatorError.pThreadCreate
		}
		
		return createdPThread
	}
}


fileprivate func pThreadBody(pointer: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
	let contextPtr = pointer.bindMemory(to: Parallelizator.Action.self, capacity: 1)
	defer {
		contextPtr.deinitialize(count: 1)
		contextPtr.deallocate()
	}
	let action = contextPtr.pointee
	action()
	return nil
}
