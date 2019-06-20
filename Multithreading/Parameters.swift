//
//  Parameters.swift
//  Multithreading
//
//  Created by mrv0van on 18/06/2019.
//  Copyright © 2019 Sberbank. All rights reserved.
//

import Foundation


protocol ParameterDetails {
	static var parameterName: String { get }
	static var tag: Int { get }
	var valueName: String { get }
	var next: ParameterDetails { get }
}

enum ControlFlow: ParameterDetails, CaseIterable {
	case sync
	case async
	static var parameterName: String {
		return "Control flow"
	}
	static var tag: Int {
		return 1
	}
	var valueName: String {
		switch self {
		case .sync:  return "Sync"
		case .async: return "Async"
		}
	}
	var next: ParameterDetails {
		switch self {
		case .sync:  return ControlFlow.async
		case .async: return ControlFlow.sync
		}
	}
}

enum DetachState: ParameterDetails, CaseIterable {
	case detached
	case joined
	static var parameterName: String {
		return "Detach state"
	}
	static var tag: Int {
		return 2
	}
	var valueName: String {
		switch self {
		case .detached: return "Detached"
		case .joined:   return "Joined"
		}
	}
	var next: ParameterDetails {
		switch self {
		case .detached: return DetachState.joined
		case .joined:   return DetachState.detached
		}
	}
}

extension QualityOfService: ParameterDetails, CaseIterable {
	public typealias AllCases = [QualityOfService]
	public static var allCases: [QualityOfService] {
		return [QualityOfService.userInteractive, .userInitiated, .utility, .background, .default]
	}

	static var parameterName: String {
		return "Quality of service"
	}
	static var tag: Int {
		return 3
	}
	var valueName: String {
		switch self {
		case .userInteractive: return "User interactive"
		case .userInitiated:   return "User initiated"
		case .utility:         return "Utility"
		case .background:      return "Background"
		default:               return "Default"
		}
	}
	var next: ParameterDetails {
		let all = QualityOfService.allCases
		let idx = all.firstIndex(of: self)!
		let next = all.index(after: idx)
		return all[next == all.endIndex ? all.startIndex : next]
	}
}
