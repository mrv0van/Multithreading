//
//  QualityOfService+Multithreading.swift
//  Multithreading
//
//  Created by mrv0van on 18/06/2019.
//  Copyright © 2019 Sberbank. All rights reserved.
//

import Foundation


let DefaultQosClass: qos_class_t = QOS_CLASS_BACKGROUND


extension QualityOfService {
	var qosClass: qos_class_t {
		get {
			switch self {
			case .userInteractive: return QOS_CLASS_USER_INTERACTIVE
			case .userInitiated:   return QOS_CLASS_USER_INITIATED
			case .utility:         return QOS_CLASS_UTILITY
			case .background:      return QOS_CLASS_BACKGROUND
			default:               return QOS_CLASS_DEFAULT
			}
		}
	}
}


extension qos_class_t {
	var qualityOfService: QualityOfService {
		get {
			switch self {
			case QOS_CLASS_USER_INTERACTIVE: return .userInteractive
			case QOS_CLASS_USER_INITIATED:   return .userInitiated
			case QOS_CLASS_UTILITY:          return .utility
			case QOS_CLASS_BACKGROUND:       return .background
			default:                         return .default
			}
		}
	}
}
