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
	
	var name: String! { get }
	
	var qosClass: qos_class_t! { get set }
	
	func performSync(action: Action!) throws
	
	func performAsync(action: Action!) throws
}


extension QualityOfService {
	
	init?(qosClass: qos_class_t) {
		self.init(rawValue: Int(qosClass.rawValue))
	}
}
