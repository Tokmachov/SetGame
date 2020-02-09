//
//  ShapeView.swift
//  SetGame
//
//  Created by mac on 08/02/2020.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit

@IBDesignable
class ShapeView: UIView {
    var shapeColor: UIColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1) { didSet { setNeedsDisplay() } }
    var numberOfShapes: Int = 3 { didSet { setNeedsDisplay() } }
    var shading: Shading = .stripped { didSet { setNeedsDisplay() } }
    var highlight: Highlight = .plain {
        didSet {
            switch highlight {
            case .plain: backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1).withAlphaComponent(0.4)
            case .green: backgroundColor = UIColor.green.withAlphaComponent(0.4)
            case .red: backgroundColor = UIColor.red.withAlphaComponent(0.4)
            case .orange: backgroundColor = UIColor.orange.withAlphaComponent(0.4)
            }
        }
    }
    var isSelected: Bool = false { didSet { setNeedsDisplay() } }
    override func draw(_ rect: CGRect) {
        let grid = makeGrid(rect: rect, numberOfShapes: numberOfShapes)
        //Draw selection
        if isSelected {
            let path = UIBezierPath(roundedRect: rect.inset(by: ShapeSizes.cardRectInsets), cornerRadius: ShapeSizes.selectionFrameCornerRadius)
            path.lineWidth = ShapeSizes.selectionFrameLineWidth
            UIColor.blue.setStroke()
            highlight.color.setFill()
            path.stroke()
            path.fill()
        } else {
            let path = UIBezierPath(roundedRect: rect.inset(by: ShapeSizes.cardRectInsets), cornerRadius: ShapeSizes.selectionFrameCornerRadius)
            highlight.color.setFill()
            path.fill()
        }
            // Draw shape
        let rects = (0..<numberOfShapes).map {
            grid[$0]!.inset(by: ShapeSizes.shapeRectInsets)
        }
        let path = shapePath(in: rects)
        shapeColor.setStroke()
        path.lineWidth = ShapeSizes.shapeLineWidth
        path.addClip()
        path.stroke()
        //Draw shading
        switch shading {
        case .stripped:
            let path = strippedPath(in: rect)
            shapeColor.setStroke()
            path.lineWidth = ShapeSizes.stripingLineWidth
            path.stroke()
        case .filled:
            let path = UIBezierPath(rect: rect)
            shapeColor.setFill()
            path.fill()
        case .unfilled: break
        }
    }
    private func makeGrid(rect: CGRect, numberOfShapes: Int) -> Grid {
        var grid: Grid
        if rect.height >= rect.width {
            grid = Grid(layout: .aspectRatio(ShapeSizes.horisontalShapeAspectRatio), frame: rect)
        } else {
            grid = Grid(layout: .aspectRatio(ShapeSizes.verticalShapeAspectRatio), frame: rect)
        }
        grid.cellCount = numberOfShapes
        return grid
    }
    func shapePath(in rects: [CGRect]) -> UIBezierPath {
        return UIBezierPath()
    }
    
    private func strippedPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        if rect.width >= rect.height {
            for x in stride(from: rect.minX, to: rect.maxX, by: rect.maxY / ShapeSizes.numberOfStrippedLines) {
                path.move(to: CGPoint(x: x, y: rect.minY))
                path.addLine(to: CGPoint(x: x, y: rect.maxY))
            }
        } else {
            for y in stride(from: rect.minY, to: rect.maxY, by: rect.maxY / ShapeSizes.numberOfStrippedLines) {
                path.move(to: CGPoint(x: rect.minX, y: y))
                path.addLine(to: CGPoint(x: rect.maxX, y: y))
            }
        }
        return path
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor.clear
    }
}

extension ShapeView {
    enum Shading {
        case stripped, filled, unfilled
    }
    struct ShapeSizes {
        static var horisontalShapeAspectRatio: CGFloat = 2
        static var verticalShapeAspectRatio: CGFloat = 0.5
        static var shapeRectInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        static var cardRectInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        static var shapeLineWidth: CGFloat = 0.5
        static var stripingLineWidth: CGFloat = 0.5
        static var numberOfStrippedLines: CGFloat = 30.0
        static var selectionFrameCornerRadius: CGFloat = 10
        static var selectionFrameLineWidth: CGFloat = 1
        static var selectionFrameColor = UIColor.blue
    }
    enum Highlight {
        case plain, red, green, orange
        var color: UIColor {
            switch self {
            case .plain: return #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1).withAlphaComponent(0.4)
            case .green: return UIColor.green.withAlphaComponent(0.4)
            case .red: return UIColor.red.withAlphaComponent(0.4)
            case .orange: return UIColor.orange.withAlphaComponent(0.4)
            }
        }
    }
}
class OvalShapeView: ShapeView {
    override func shapePath(in rects: [CGRect]) -> UIBezierPath {
        let resultPath = UIBezierPath()
        for rect in rects {
            let path = UIBezierPath(ovalIn: rect)
            resultPath.append(path)
        }
        return resultPath
    }
}

class DiamondShapeView: ShapeView {
    override func shapePath(in rects: [CGRect]) -> UIBezierPath {
        let resultPath = UIBezierPath()
        for rect in rects {
            let left = CGPoint(x: rect.minX , y: rect.midY)
            let top = CGPoint(x: rect.midX, y: rect.minY)
            let right = CGPoint(x: rect.maxX, y: rect.midY)
            let bottom = CGPoint(x: rect.midX, y: rect.maxY)
            let path = UIBezierPath()
            path.move(to: left)
            path.addLine(to: top)
            path.addLine(to: right)
            path.addLine(to: bottom)
            path.close()
            resultPath.append(path)
        }
        return resultPath
    }
}

class SquiggleShapeView: ShapeView {
    override func shapePath(in rects: [CGRect]) -> UIBezierPath {
        let resultingPath = UIBezierPath()
        for rect in rects {
            if rect.width >= rect.height {
                let path = pathForSquiggle(inHorrisontalRect: rect)
                resultingPath.append(path)
            } else {
                let path = pathForSquiggle(inVerticalRect: rect)
                resultingPath.append(path)
            }
        }
        return resultingPath
    }
    private func pathForSquiggle(inHorrisontalRect rect: CGRect) -> UIBezierPath {
        let radius = rect.height / 4
        let lowerEndCenter = CGPoint(x: rect.minX + radius, y: rect.maxY - radius)
        let path = UIBezierPath()
        path.addArc(
            withCenter: lowerEndCenter,
            radius: radius,
            startAngle: CGFloat.pi / 2,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true
        )
        let upperEndTop = CGPoint(x: rect.maxX - radius, y: rect.minY)
        let upperCurveCP1 = CGPoint(x: rect.maxX / 2, y: rect.maxY - (2 * radius))
        let upperCurveCP2 = CGPoint(x: rect.maxX / 2, y: rect.minY)
        path.addCurve(
            to: upperEndTop,
            controlPoint1: upperCurveCP1,
            controlPoint2: upperCurveCP2
        )
        let upperEndCenter = CGPoint(x: rect.maxX - radius, y: rect.minY + radius)
        path.addArc(
            withCenter: upperEndCenter,
            radius: radius,
            startAngle: 3 * CGFloat.pi / 2,
            endAngle: CGFloat.pi / 2,
            clockwise: true
        )
        let lowerEndBottom = CGPoint(x: rect.minX + radius, y: rect.maxY)
        let lowerCurveCP1 = CGPoint(x: rect.maxX / 2, y: rect.minY + 2 * radius)
        let lowerCurveCP2 = CGPoint(x: rect.maxX / 2, y: rect.maxY)
        path.addCurve(
            to: lowerEndBottom,
            controlPoint1: lowerCurveCP1,
            controlPoint2: lowerCurveCP2
        )
        return path
    }
    private func pathForSquiggle(inVerticalRect rect: CGRect) -> UIBezierPath {
        let radius = rect.width / 4
        let lowerEndCenter = CGPoint(x: rect.maxX - radius, y: rect.maxY - radius)
        let path = UIBezierPath()
        path.addArc(
            withCenter: lowerEndCenter,
            radius: radius,
            startAngle: 0,
            endAngle: CGFloat.pi,
            clockwise: true
        )
        let upperEndLeft = CGPoint(x: rect.minX, y: rect.minY + radius)
        let leftCurveCP1 = CGPoint(x: rect.maxX - (2 * radius), y: rect.maxY / 2)
        let leftCurveCP2 = CGPoint(x: rect.minX, y: rect.maxY / 2)
        path.addCurve(
            to: upperEndLeft,
            controlPoint1: leftCurveCP1,
            controlPoint2: leftCurveCP2
        )
        let upperEndCenter = CGPoint(x: rect.minX + radius, y: rect.minY + radius)
        path.addArc(
            withCenter: upperEndCenter,
            radius: radius,
            startAngle: CGFloat.pi,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        )
        let lowerEndRight = CGPoint(x: rect.maxX, y: rect.maxY - radius)
        let rightCurveCP1 = CGPoint(x: rect.minX + (2 * radius), y: rect.maxY / 2)
        let rightCurveCP2 = CGPoint(x: rect.maxX, y: rect.maxY / 2)
        path.addCurve(
            to: lowerEndRight,
            controlPoint1: rightCurveCP1,
            controlPoint2: rightCurveCP2
        )
        return path
    }
}

struct CardViewsFactoy {
    enum ShapeType {
        case oval, diamond, squiggle
    }
    static func makeCardView(type: ShapeType) -> ShapeView {
        switch type {
        case .squiggle: return SquiggleShapeView()
        case .oval: return OvalShapeView()
        case .diamond: return DiamondShapeView()
        }
    }
}

