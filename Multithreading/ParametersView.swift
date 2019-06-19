//
//  ParametersView.swift
//  Multithreading
//
//  Created by mrv0van on 17/06/2019.
//  Copyright © 2019 Sberbank. All rights reserved.
//

import UIKit


protocol ParameterViewDelegate {
	func parametersView(_: ParametersView!, didChangeParameter: ParameterDetails!)
}


final class ParametersView: UIView {
	private enum Constants: CGFloat {
		case spacing = 15
	}
	
	private var parameters: [Int: ParameterDetails]
	
	var delegate: ParameterViewDelegate?

	
	// MARK: - Life cycle
	
	init(initialValues: [ParameterDetails]) {
		parameters = [Int: ParameterDetails]()
		for parameter in initialValues {
			parameters[type(of:parameter).tag] = parameter
		}

		super.init(frame: .zero)
		
		let buttonsList = createButtons()
		createStackView(arrangedSubviews: buttonsList)
	}
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - UI Creating
	
	private func createStackView(arrangedSubviews: [UIView]) {
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

	private func createButtons() -> [UIButton] {
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
	
	@objc private func buttonDidTap(sender: UIButton) {
		guard let parameter = parameters[sender.tag] else {
			return
		}
		let parameterNext = parameter.next
		parameters[sender.tag] = parameterNext
		sender.setTitle(parameterNext?.valueName, for: .normal)
		
		delegate?.parametersView(self, didChangeParameter: parameterNext)
	}
}
