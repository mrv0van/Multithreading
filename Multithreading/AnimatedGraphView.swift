//
//  AnimatedGraphView.swift
//  Multithreading
//
//  Created by Vladimir Ozerov on 14/06/2019.
//  Copyright © 2019 Sberbank. All rights reserved.
//

import Foundation
import UIKit


final class AnimatedGraphView: UIView {
	
	fileprivate enum Constants: CGFloat {
		case maxVelociy = 10
		case pointSize = 4
	}
	fileprivate let numberOfPoints: Int = 5
	fileprivate struct Point {
		var point: CGPoint!
		var velocity: CGPoint!
		var min: CGPoint!
		var max: CGPoint!
	}
	
	fileprivate var shapeLayer: CAShapeLayer!
	fileprivate var pointLayersList: [CALayer]!
	fileprivate var pointsList: [Point]!
	fileprivate var displayLink: CADisplayLink?
	
	
	// MARK: Life cycle
	
	required override init(frame: CGRect) {
		shapeLayer = AnimatedGraphView.createShapeLayer(frame: frame)
		pointLayersList = AnimatedGraphView.createPointLayersList(count: numberOfPoints)
		
		super.init(frame: frame)
		
		layer.backgroundColor = UIColor.white.cgColor
		layer.addSublayer(shapeLayer)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var frame: CGRect {
		didSet {
			shapeLayer.frame = bounds
		}
	}
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		if (window != nil) {
			setUpDisplayLink()
		} else {
			invalidateDispayLink()
		}
	}
	
	
	// MARK: Creating UI
	
	fileprivate static func createShapeLayer(frame: CGRect) -> CAShapeLayer {
		let layer = CAShapeLayer()
		layer.frame = CGRect(origin: .zero, size: frame.size)
		layer.fillColor = nil
		layer.strokeColor = UIColor.black.cgColor
		layer.lineWidth = 1
		return layer
	}
	
	fileprivate static func createPointLayersList(count: Int) -> [CALayer] {
		let layerSize = CGSize(width: Constants.pointSize.rawValue, height: Constants.pointSize.rawValue)
		var layersList = [CALayer]()
		for _ in 0...count {
			let layer = CALayer()
			layer.frame = CGRect(origin: .zero, size: layerSize)
			layer.backgroundColor = UIColor.black.cgColor
			layersList.append(layer)
		}
		return layersList
	}
	
	
	// MARK: Display link
	
	fileprivate func setUpDisplayLink() {
		guard displayLink != nil else {
			return
		}
		displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFrame))
		displayLink?.add(to: .current, forMode: .default)
	}
	
	fileprivate func invalidateDispayLink() {
		guard let displayLink = displayLink else {
			return
		}
		displayLink.invalidate()
		self.displayLink = nil
	}
	
	@objc fileprivate func displayLinkFrame(sender: CADisplayLink) {
	}
	
	
	// MARK: Points
	
	fileprivate static func createPointsList(count: Int) -> [Point] {
		var pointsList = [Point]()
		for _ in 0...count {
		}
	}
}
