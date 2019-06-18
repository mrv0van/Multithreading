//
//  ParametersView.swift
//  Multithreading
//
//  Created by mrv0van on 17/06/2019.
//  Copyright © 2019 Sberbank. All rights reserved.
//

import UIKit


protocol ParameterDetails {
	static var parameterName: String! { get }
	static var tag: Int! { get }
	var valueName: String! { get }
	var next: ParameterDetails! { get }
}

enum ControlFlow: ParameterDetails, CaseIterable {
	case sync
	case async
	static var parameterName: String! {
		return "Control flow"
	}
	static var tag: Int! {
		return 1
	}
	var valueName: String! {
		switch self {
		case .sync:  return "Sync"
		case .async: return "Async"
		}
	}
	var next: ParameterDetails! {
		switch self {
		case .sync:  return ControlFlow.async
		case .async: return ControlFlow.sync
		}
	}
}

enum DetachState: ParameterDetails, CaseIterable {
	case detached
	case joined
	static var parameterName: String! {
		return "Detach state"
	}
	static var tag: Int! {
		return 2
	}
	var valueName: String! {
		switch self {
		case .detached: return "Detached"
		case .joined:   return "Joined"
		}
	}
	var next: ParameterDetails! {
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

	static var parameterName: String! {
		return "Quality of service"
	}
	static var tag: Int! {
		return 3
	}
	var valueName: String! {
		switch self {
		case .userInteractive: return "User interactive"
		case .userInitiated:   return "User initiated"
		case .utility:         return "Utility"
		case .background:      return "Background"
		default:               return "Default"
		}
	}
	var next: ParameterDetails! {
		let all = QualityOfService.allCases
		let idx = all.firstIndex(of: self)!
		let next = all.index(after: idx)
		return all[next == all.endIndex ? all.startIndex : next]
	}
}


protocol ParameterViewDelegate {
	func parametersView(_: ParametersView!, didChangeParameter: ParameterDetails!)
}


final class ParametersView: UIView {
	fileprivate enum Constants: CGFloat {
		case spacing = 15
	}
	
	fileprivate var parameters: [Int: ParameterDetails]
	
	var delegate: ParameterViewDelegate?

	
	// MARK: - Life cycle
	
	init(initialValues: [ParameterDetails]) {
		parameters = [ControlFlow.tag:      ControlFlow.sync,
					  DetachState.tag:      DetachState.detached,
					  QualityOfService.tag: QualityOfService.default]

		super.init(frame: .zero)
		
		let buttonsList = createButtons()
		createStackView(arrangedSubviews: buttonsList)
	}
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - UI Creating
	
	fileprivate func createStackView(arrangedSubviews: [UIView]) {
		let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		stackView.alignment = .fill
		stackView.spacing = Constants.spacing.rawValue
		stackView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(stackView)
		
		let constraints = [
			stackView.topAnchor.constraint(equalTo: self.topAnchor),
			stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
			stackView.widthAnchor.constraint(equalTo: self.widthAnchor),
			stackView.heightAnchor.constraint(equalTo: self.heightAnchor)
		]
		constraints.forEach { constraint in
			constraint.priority = .init(rawValue: 999)
		}
		NSLayoutConstraint.activate(constraints)
	}

	fileprivate func createButtons() -> [UIButton] {
		var buttonsList = [UIButton]()
		for tag in parameters.keys.sorted() {
			let parameter = parameters[tag]!
			
			let button = UIButton()
			button.backgroundColor = .lightGray
			button.tag = tag
			button.setTitle(parameter.valueName, for: .normal)
			button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
			button.translatesAutoresizingMaskIntoConstraints = false
			buttonsList.append(button)
		}
		return buttonsList
	}
	

	// MARK: - Parameters
	
	@objc fileprivate func buttonDidTap(sender: UIButton) {
		guard let parameter = parameters[sender.tag] else {
			return
		}
		let parameterNext = parameter.next
		parameters[sender.tag] = parameterNext
		sender.setTitle(parameterNext?.valueName, for: .normal)
		
		delegate?.parametersView(self, didChangeParameter: parameterNext)
	}
}
