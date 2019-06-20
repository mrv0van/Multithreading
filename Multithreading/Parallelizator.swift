//
//  Parallelizator.swift
//  Multithreading
//
//  Created by Vladimir Ozerov on 14/06/2019.
//  Copyright © 2019 Sberbank. All rights reserved.
//

import Foundation


protocol Parallelizator: AnyObject {	
	typealias Action = () -> Void
	
	var name: String { get }
	
	var qosClass: qos_class_t { get set }
	var detached: Bool { get set }
	
	func performSync(action: @escaping Action) throws
	
	func performAsync(action: @escaping Action) throws
}
