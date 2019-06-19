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
	private enum Constants: CGFloat {
		case maxVelociy = 2
		case pointSize = 10
        case pointFloatingZone = 0.5
	}
	private let numberOfPoints: Int = 5
	private class ShapePoint {
		lazy var point: CGPoint! = {
			return CGPoint(x: 0.5, y: 0.5)
		} ()
		lazy var velocity: CGPoint! = {
			return .zero
		} ()
	}
	
	private var shapeLayer: CAShapeLayer!
	private var pointLayersList: [CALayer]!
	private var shapePointsList: [ShapePoint]!
	private var displayLink: CADisplayLink?
	
	static let defaultGraphColor: UIColor = .black
	var graphColor: UIColor! {
		didSet {
			shapeLayer.strokeColor = graphColor.cgColor
			pointLayersList.forEach { layer in
				layer.backgroundColor = graphColor.cgColor
			}
		}
	}
	
	
	// MARK: - Life cycle
	
	required override init(frame: CGRect) {
		shapeLayer      = AnimatedGraphView.createShapeLayer(frame: frame)
		pointLayersList = AnimatedGraphView.createPointLayersList(count: numberOfPoints)
        shapePointsList = AnimatedGraphView.createShapePointsList(count: numberOfPoints)
		graphColor      = AnimatedGraphView.defaultGraphColor
		
		super.init(frame: frame)
		
		layer.backgroundColor = UIColor.white.cgColor
		layer.addSublayer(shapeLayer)
		pointLayersList.forEach { pointLayer in
			layer.addSublayer(pointLayer)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		if (window != nil) {
			setUpDisplayLink()
		} else {
			invalidateDispayLink()
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.shapeLayer.frame = bounds
	}
	
	
	// MARK: - Creating UI
	
	private static func createShapeLayer(frame: CGRect) -> CAShapeLayer {
		let layer = CAShapeLayer()
		layer.frame = CGRect(origin: .zero, size: frame.size)
		layer.fillColor = nil
		layer.strokeColor = AnimatedGraphView.defaultGraphColor.cgColor
		layer.lineWidth = 1
		return layer
	}
	
	private static func createPointLayersList(count: Int) -> [CALayer] {
		let layerSize = CGSize(width: Constants.pointSize.rawValue, height: Constants.pointSize.rawValue)
		var layersList = [CALayer]()
		for _ in 0...count - 1 {
			let layer = CALayer()
			layer.frame = CGRect(origin: .zero, size: layerSize)
			layer.backgroundColor = AnimatedGraphView.defaultGraphColor.cgColor
			layer.cornerRadius = Constants.pointSize.rawValue / 2.0
			layersList.append(layer)
		}
		return layersList
	}
	
	
	// MARK: - Display link
	
	private func setUpDisplayLink() {
		guard displayLink == nil else {
			return
		}
		displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFrame))
		displayLink?.add(to: .current, forMode: .default)
	}
	
	private func invalidateDispayLink() {
		guard let displayLink = displayLink else {
			return
		}
		displayLink.invalidate()
		self.displayLink = nil
	}
	
	@objc private func displayLinkFrame(sender: CADisplayLink) {
		evaluateNextFrame()
		let coordinatesList = evaluatePointCoordinatesList()
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		shapeLayer.path = createShapePath(coordinatesList: coordinatesList)
		updatePointLayersFrames(coordinatesList: coordinatesList)
		CATransaction.commit()
	}
	
	
	// MARK: - Points
	
	private static func createShapePointsList(count: Int) -> [ShapePoint] {
		var shapePointsList = [ShapePoint]()
		for _ in 0...count - 1 {
			let shapePoint = ShapePoint()
			shapePointsList.append(shapePoint)
		}
		return shapePointsList
	}
	
	private func evaluateNextFrame() {
		guard let displayLink = displayLink else {
			return
		}
		let frameDuration = CGFloat(displayLink.timestamp - displayLink.targetTimestamp)
		for shapePoint in shapePointsList {
			let velocityDelta = CGPoint(x: 0.1 - CGFloat(arc4random_uniform(200)) / 1000,
									  	y: 0.1 - CGFloat(arc4random_uniform(200)) / 1000)
			let maxVelocity = Constants.maxVelociy.rawValue
			var velocity = CGPoint(x: max(-maxVelocity, min(maxVelocity, shapePoint.velocity.x + velocityDelta.x)),
								   y: max(-maxVelocity, min(maxVelocity, shapePoint.velocity.y + velocityDelta.y)))
			var point = CGPoint(x: shapePoint.point.x + velocity.x * frameDuration,
								y: shapePoint.point.y + velocity.y * frameDuration)
			
			if point.x < 0 || point.x > 1 {
				velocity.x = -velocity.x
				point.x = max(0, min(1, point.x))
			}
			if point.y < 0 || point.y > 1 {
				velocity.y = -velocity.y
				point.y = max(0, min(1, point.y))
			}
			shapePoint.point = point
			shapePoint.velocity = velocity
		}
	}
	
	private func evaluatePointCoordinatesList() -> [CGPoint] {
		var coordinatesList = [CGPoint]()
		for i in 0...shapePointsList.count - 1 {
			let coordinate = evaluatePointCoordinate(pointIndex: i)
			coordinatesList.append(coordinate)
		}
		return coordinatesList
	}
	
	private func evaluatePointCoordinate(pointIndex: Int) -> CGPoint {
		let pointZoneWidth = bounds.width / CGFloat(numberOfPoints)
		let pointZoneX = pointZoneWidth * CGFloat(pointIndex)
		
		let decreaseFactor = 1.0 - CGFloat(Constants.pointFloatingZone.rawValue)
		let decreaseSize = CGSize(width: pointZoneWidth * decreaseFactor, height: bounds.height * decreaseFactor)
		let pointFloatingZone = CGRect(x: pointZoneX + decreaseSize.width / 2.0,
									   y: decreaseSize.height / 2.0,
									   width: pointZoneWidth - decreaseSize.width,
									   height: bounds.height - decreaseSize.height)
		let pointCoordinate = CGPoint(x: pointFloatingZone.minX + pointFloatingZone.width * shapePointsList[pointIndex].point.x,
									  y: pointFloatingZone.minY + pointFloatingZone.height * shapePointsList[pointIndex].point.y)
		return pointCoordinate
	}
	
	private func createShapePath(coordinatesList: [CGPoint]) -> CGPath {
		let path = CGMutablePath()
		path.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
		coordinatesList.forEach { coordinate in
			path.addLine(to: coordinate)
		}
		path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
		return path.copy()!
	}
	
	private func updatePointLayersFrames(coordinatesList: [CGPoint]) {
		for (index, coordinate) in coordinatesList.enumerated() {
			pointLayersList[index].position = coordinate
		}
	}
}
