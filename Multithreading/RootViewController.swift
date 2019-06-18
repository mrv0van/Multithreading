//
//  RootViewController.swift
//  Multithreading
//
//  Created by Vladimir Ozerov on 13/06/2019.
//  Copyright © 2019 Sberbank. All rights reserved.
//

import UIKit


final class RootViewController: UIViewController, ParameterViewDelegate {
	fileprivate enum Constants: CGFloat {
		case spacing = 30
		case rowHeight = 60
		case graphHeight = 120
	}

	fileprivate typealias Action = () -> Void
	fileprivate struct ListAction {
		let button: UIButton!
		let parallelizator: Parallelizator!
	}
	fileprivate var actionsList: [ListAction]
	
	fileprivate var controlFlow: ControlFlow!
	fileprivate var detachState: DetachState!
	fileprivate var qualityOfService: QualityOfService!
	

	// MARK: - Life cycle

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		actionsList = []
		controlFlow = .sync
		detachState = .detached
		qualityOfService = .default
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		navigationItem.title = "Ways of parallelism"
	}
	
	
	// MARK: - View life cycle
	
	override func loadView() {
		view = createMainView()
		guard let view = view else {
			return
		}
		
		let parametersView    = createParametersView()
		let pThreadButton     = createListAction(parallelizator: PThreadParallelizator())
		let nsThreadButton    = createListAction(parallelizator: NSThreadParallelizator())
		let gcdButton         = createListAction(parallelizator: GCDParallelizator())
		let animatedGraphView = createAnimatedGraphView()
		let space             = createFlexibleSpace()

		let stackView = createStackView(arrangedSubviews: [
			parametersView,
			pThreadButton,
			nsThreadButton,
			gcdButton,
			space,
			animatedGraphView
		])
		view.addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.spacing.rawValue),
			stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.spacing.rawValue),
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.spacing.rawValue),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.spacing.rawValue)
		])
	}

	
	// MARK: - Creating UI

	fileprivate func createMainView() -> UIView {
		let view = UIView()
		view.backgroundColor = .white
		return view
	}

	fileprivate func createStackView(arrangedSubviews: [UIView]) -> UIStackView {
		let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
		stackView.axis = .vertical
		stackView.distribution = .fillProportionally
		stackView.alignment = .fill
		stackView.spacing = Constants.spacing.rawValue
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}
	
	fileprivate func createParametersView() -> ParametersView {
		let initialValues: [ParameterDetails] = [controlFlow, detachState, qualityOfService]
		let view = ParametersView(initialValues: initialValues)
		view.delegate = self
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.heightAnchor.constraint(equalToConstant: Constants.rowHeight.rawValue),
		])
		return view
	}
	
	fileprivate func createListAction(parallelizator: Parallelizator!) -> UIView {
		let button = UIButton()
		button.setTitle(parallelizator.name, for: .normal)
		button.backgroundColor = .gray
		button.addTarget(self, action: #selector(buttonActionHandler), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			button.heightAnchor.constraint(equalToConstant: Constants.rowHeight.rawValue)
		])
		
		let listAction = ListAction(button: button, parallelizator: parallelizator)
		actionsList.append(listAction)
		
		return button
	}
	
	fileprivate func createFlexibleSpace() -> UIView {
		let space = UIView()
		space.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			space.heightAnchor.constraint(greaterThanOrEqualToConstant: 1)
		])
		return space
	}
	
	fileprivate func createAnimatedGraphView() -> AnimatedGraphView {
		let view = AnimatedGraphView()
		view.backgroundColor = .lightGray
		view.graphColor = .black
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.heightAnchor.constraint(equalToConstant: Constants.graphHeight.rawValue)
		])
		return view
	}
	

	// MARK: - Action handling
	
	@objc fileprivate func buttonActionHandler(sender: UIButton!) {
		for action in actionsList {
			guard action.button == sender else {
				continue
			}
			do {
				guard let parallelizator = action.parallelizator else {
					return
				}
				
				let name = parallelizator.name
				let parameters: [ParameterDetails] = [controlFlow, detachState, qualityOfService]
				let actionBlock: () -> Void = { [weak self] in
					self?.performTask(name: name!, parameters: parameters)
				}

				parallelizator.qosClass = qualityOfService.qosClass
				parallelizator.detached = detachState == .detached
				if controlFlow == .sync {
					try parallelizator.performSync(action: actionBlock)
				} else {
					try parallelizator.performAsync(action: actionBlock)
				}
			}
			catch {
				print("Parallelizator error: \(error)")
			}
			return
		}
	}
	
	fileprivate func performTask(name: String, parameters: [ParameterDetails]) {
		let uid = UUID().uuidString.suffix(5).lowercased()
		let parametersValueNames = parameters.map { $0.valueName! }
		print("🚀 \(name)[\(uid)] \(parametersValueNames)")

		let beginTime = CACurrentMediaTime()
		
		var work: Float = 0
		for i in 0...1_000_000 {
			work += Float(arc4random_uniform(UInt32(i)))
		}
		
		let duration = CACurrentMediaTime() - beginTime
		
		print("🏁 \(name)[\(uid)] in \(duration) s.")
	}
	
	
	// MARK: - Protocol conformance <ParametersViewDelegate>
	
	func parametersView(_: ParametersView!, didChangeParameter parameter: ParameterDetails!) {
		switch parameter {
		case let controlFlow as ControlFlow: self.controlFlow = controlFlow
		case let detachState as DetachState: self.detachState = detachState
		case let qualityOfService as QualityOfService: self.qualityOfService = qualityOfService
		default: return
		}
	}
}

