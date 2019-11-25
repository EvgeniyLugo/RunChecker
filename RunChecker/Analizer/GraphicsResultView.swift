//
//  GraphicsResult.swift
//  RunChecker
//
//  Created by Evgeniy Lugovoy on 21.11.2019.
//  Copyright © 2019 MeadowsPhoneTeam. All rights reserved.
//

import Macaw

open class GraphicsResultView: MacawView {
    private struct ScoreLine {
        
        var points: [(x: Double, y: Double)]
        var leftGradientColor: Int
        var rightGradientColor: Int
        
        init() {
            self.points = Array()
            self.leftGradientColor = 0xff7200
            self.rightGradientColor = 0xffff86
        }
    }

    private var animationRect = Shape(form: Rect())

    private var animations = [Animation]()
    private var scoreLines = [ScoreLine]()
    private let cubicCurve = CubicCurveAlgorithm()
    private var chartWidth: Double = 240
    private var chartHeight: Double = 160
    private let milesCaptionWidth: Double = 40
    private let backgroundLineSpacing: Double = 20
    private let captionsX = ["0", "5", "10", "15", "20", "25", "30"]
    private let captionsY = ["1.0", "0.8", "0.6", "0.4", "0.2"]

    private let appDelegate: AppDelegate! = UIApplication.shared.delegate as? AppDelegate

    func createScene(results: [Results]) {
        animations.removeAll()
        scoreLines.removeAll()
        chartWidth = Double(self.frame.size.width - 8)
        chartHeight = Double(self.frame.size.height - 8)
        for result in results {
            var scoreLine = ScoreLine()
            scoreLine.leftGradientColor = result.startColor
            scoreLine.rightGradientColor = result.finishColor
            for item in result.items {
                let x = Double(item.currentTime) / 30 * chartWidth + 4
                let y = Double(item.yPosition) / Double(appDelegate.maxY - appDelegate.minY) * chartHeight
                scoreLine.points.append((x: x, y: y))
            }
            scoreLines.append(scoreLine)
        }

        let chartLinesGroup = Group()
        chartLinesGroup.place = Transform.move(dx: Double(milesCaptionWidth), dy: 0)
        scoreLines.forEach { scoreLine in
            let dataPoints = scoreLine.points.map { CGPoint(x: $0.x, y: $0.y) }
            let controlPoints = self.cubicCurve.controlPointsFromPoints(dataPoints: dataPoints)
            var path: PathBuilder = MoveTo(x: scoreLine.points[0].x, y: scoreLine.points[0].y)
            for index in 0...dataPoints.count - 2 {
                path = path.cubicTo(
                    x1: Double(controlPoints[index].controlPoint1.x),
                    y1: Double(controlPoints[index].controlPoint1.y),
                    x2: Double(controlPoints[index].controlPoint2.x),
                    y2: Double(controlPoints[index].controlPoint2.y),
                    x: Double(dataPoints[index + 1].x),
                    y: Double(dataPoints[index + 1].y)
                )
            }
            let shape = Shape(
                form: path.build(),
                stroke: Stroke(
                    fill: LinearGradient(degree: 0, from: Color(val: scoreLine.leftGradientColor), to: Color(val: scoreLine.rightGradientColor)),
                    width: 2
                )
            )
            chartLinesGroup.contents.append(shape)
        }

        animationRect = Shape(
            form: Rect(x: 0, y: 0, w: chartWidth + 1, h: chartHeight + backgroundLineSpacing),
            fill: Color(val: 0x4a2e7d)
        )
        chartLinesGroup.contents.append(animationRect)
//
//        let lineColor = Color.rgba(r: 255, g: 255, b: 255, a: 0.1)
//        let captionColor = Color.rgba(r: 255, g: 255, b: 255, a: 0.5)
//        var captionIndex = 0
//        for index in 0...Int(chartWidth / backgroundLineSpacing) {
//            let x = backgroundLineSpacing * Double(index)
//            let y2 = index % 2 == 0 ? chartHeight + backgroundLineSpacing : chartHeight
//            chartLinesGroup.contents.append(
//                Line(
//                    x1: x,
//                    y1: 0,
//                    x2: x,
//                    y2: y2
//                ).stroke(fill: lineColor)
//            )
//            if index % 2 == 0 {
//                let text = Text(
//                    text: captionsX[captionIndex],
//                    font: Font(name: "Serif", size: 14),
//                    fill: captionColor
//                )
//                text.align = .mid
//                text.place = .move(
//                    dx: x,
//                    dy: y2 + 10
//                )
//                text.opacity = 1
//                chartLinesGroup.contents.append(text)
//                captionIndex += 1
//            }
//        }
//        
//        let milesCaptionGroup = Group()
//        for index in 0...Int(chartHeight / (backgroundLineSpacing * 2)) {
//            let text = Text(
//                text: captionsY[index],
//                font: Font(name: "Serif", size: 14),
//                fill: captionColor
//            )
//            text.place = .move(
//                dx: 0,
//                dy: backgroundLineSpacing * 2 * Double(index)
//            )
//            text.opacity = 1
//            milesCaptionGroup.contents.append(text)
//        }
        
        self.node = [chartLinesGroup].group()
        self.backgroundColor = UIColor(cgColor: Color(val: 0x4a2e7d).toCG())

    }
    
    private func createAnimations() {
        animations.removeAll()
        animations.append(
            animationRect.placeVar.animation(to: Transform.move(dx: Double(self.frame.width), dy: 0), during: 2)
        )
    }
    
    open func play() {
//        createScene()
        createAnimations()
        animations.forEach {
            $0.play()
        }
    }
}
