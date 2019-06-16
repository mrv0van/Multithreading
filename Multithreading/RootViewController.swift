//
//  RootViewController.swift
//  Multithreading
//
//  Created by Vladimir Ozerov on 13/06/2019.
//  Copyright © 2019 Sberbank. All rights reserved.
//

import UIKit


final class RootViewController: UIViewController {
	
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
	fileprivate var shouldDetachThread: Bool
	

	// MARK: - Life cycle

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		actionsList = []
		shouldDetachThread = false
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		navigationItem.title = "Ways of parallelism"
	}
	
	
	// MARK: - View life cycle
	
	override func loadView() {
		view = createMainView()
		guard let view = view else {
			return
		}
		
		let switcher          = createAsyncSwitcher()
		let pThreadButton     = createListAction(title: "PThread", parallelizator: PThreadParallelizator())
		let nsThreadButton    = createListAction(title: "NSThread", parallelizator: NSThreadParallelizator())
		let animatedGraphView = createAnimatedGraphView()
		let space             = createFlexibleSpace()

		let stackView = createStackView(arrangedSubviews: [
			switcher,
			pThreadButton,
			nsThreadButton,
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
	
	fileprivate func createAsyncSwitcher() -> UIView {
		let view = UIView()
		view.backgroundColor = .lightGray
		
		let label = UILabel()
		label.text = "Should detach thread";
		label.numberOfLines = 2
		label.font = .systemFont(ofSize: 18)
		label.textColor = .white
		view.addSubview(label)
		
		let switcher = UISwitch()
		switcher.isOn = shouldDetachThread
		switcher.addTarget(self, action: #selector(asyncSwitcherHandler), for: .valueChanged)
		view.addSubview(switcher)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		label.translatesAutoresizingMaskIntoConstraints = false
		switcher.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.heightAnchor.constraint(equalToConstant: Constants.rowHeight.rawValue),
			label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.spacing.rawValue),
			label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			switcher.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.spacing.rawValue),
			switcher.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
		return view
	}
	
	fileprivate func createListAction(title: String!, parallelizator: Parallelizator!) -> UIView {
		let button = UIButton()
		button.setTitle(title, for: .normal)
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
				if (shouldDetachThread)
				{
					try performAsyncTask(parallelizator: action.parallelizator)
				}
				else
				{
					try performSyncTask(parallelizator: action.parallelizator)
				}
			}
			catch {
				print("Parallelizator error: \(error)")
			}
			return
		}
	}
	
	@objc fileprivate func asyncSwitcherHandler(sender: UISwitch!) {
		shouldDetachThread = sender.isOn
	}
	
	fileprivate func performSyncTask(parallelizator: Parallelizator!) throws {
		try parallelizator.performSync { [weak self] in
			self?.performTask(name: parallelizator.name, mode: "sync")
		}
	}

	fileprivate func performAsyncTask(parallelizator: Parallelizator!) throws {
		try parallelizator.performAsync { [weak self] in
			self?.performTask(name: parallelizator.name, mode: "async")
		}
	}
	
	fileprivate func performTask(name: String!, mode: String!) {
		let uid = UUID().uuidString.suffix(5).lowercased()
		print("Thread work[\(uid)] started: \(name!), \(mode!)")

		let beginTime = CACurrentMediaTime()
		
		var work: Float = 0
		for i in 0...1_000_000 {
			work += Float(arc4random_uniform(UInt32(i)))
		}
		
		let duration = CACurrentMediaTime() - beginTime
		
		print("Thread work[\(uid)] done in \(duration) s.")
	}
}

