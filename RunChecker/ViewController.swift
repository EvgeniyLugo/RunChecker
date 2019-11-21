//
//  ViewController.swift
//  RunChecker
//
//  Created by Evgeniy Lugovoy on 19.11.2019.
//  Copyright © 2019 MeadowsPhoneTeam. All rights reserved.
//

import UIKit
import simd

class ViewController: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var resultView: GraphicsResultView!
    
    @IBOutlet var barButtons: [UIBarButtonItem]!
    
//    private var lMax: Float = 0
//    private var lMin: Float = 360
//    private var rMax: Float = 0
//    private var rMin: Float = 360

    var camera: NostalgiaCamera!
    var imageProcessor: ImageProcessor!
    private let appDelegate: AppDelegate! = UIApplication.shared.delegate as? AppDelegate
    ///Параметр, определяющий количество фреймов для усреднения результатов
    private let frameCounts: Int = 3
    private var currentFrame: Int = 0
    private var summaryPoses: [Pose]!
    
    ///Timer
    private var timer = Timer()
    ///Интервал таймера
    private var timeDelta: CGFloat = 0.1
    private var currentTime: Float = 0
    private let totalSeconds: Float = 30
    
    private var isPlaying: Bool = false {
        didSet {
            let img = isPlaying ? UIImage(named: "start_red") : UIImage(named: "start_green")
            btnStart.setImage(img, for: .normal)
            imageProcessor.enableProcessing = isPlaying
            if isPlaying {
                self.startTimer()
            }
            else {
                pauseTimer()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageProcessor = ImageProcessor(controller: self)
        camera = NostalgiaCamera(processor: imageProcessor, andImageView: imgView)
        summaryPoses  = Array(repeating: Pose(), count: frameCounts)
        self.timeLabel.text = "Duration: 0 sec"
        self.progressView.progress = 0
    }
        
    // Start it when it appears
    override func viewDidAppear(_ animated: Bool) {
        camera.start()
    }
    
    // Stop it when it disappears
    override func viewWillDisappear(_ animated: Bool) {
        camera.stop()
    }

    @IBAction func startClicked(_ sender: Any) {
        if isPlaying {
            saveResults()
        }
        else {
            appDelegate.results.removeAll()
            isPlaying = true
        }

    }
    
//    /// Обработчик события делегата о готовности скелета для показа
//    /// - Parameter pose: Содержит номер опознанного скелета (если их несколько), а также номера и позиции ключевых точек
//    /// Номера точек:
//    /// - 0 - нос
//    /// - 1 - левый глаз
//    /// - 2 - правый глаз
//    /// - 3 - левое ухо
//    /// - 4 - правое ухо
//    /// - 5 - левое плечо
//    /// - 6 - правое плечо
//    /// - 7 - левый локоть
//    /// - 8 - правый локоть
//    /// - 9 - левое запястье
//    /// - 10 - правое запястье
//    /// - 11 - левое бедро
//    /// - 12 - правое бедро
//    /// - 13 - левое колено
//    /// - 14 - правое колено
//    /// - 15 - левая лодыжка
//    /// - 16  - правая лодыжка
//    func poseIsReady(_ pose: Pose) {
//        //Пока обрабатываем только одну фигуру
//        if pose.personNumber > 0 || pose.dots.count < 17 {
//            return
//        }
//        var leftAngle: Float = 0
//        var rightAngle: Float = 0
//        //Смотрим на плечи и бедра
//        if let leftShoulder = pose.dots[6] as? PoseDot, let leftHip = pose.dots[12] as? PoseDot, let rightShoulder = pose.dots[5] as? PoseDot, let rightHip = pose.dots[11] as? PoseDot {
//            let leftVec = simd_int2(x: leftHip.dotPos.x - leftShoulder.dotPos.x, y: leftHip.dotPos.y - leftShoulder.dotPos.y)
//            leftAngle = atan2f(Float(leftVec.y), Float(leftVec.x)) * 180 / .pi
//            let rightVec = simd_int2(x: rightHip.dotPos.x - rightShoulder.dotPos.x, y: rightHip.dotPos.y - rightShoulder.dotPos.y)
//            rightAngle = atan2f(Float(rightVec.y), Float(rightVec.x)) * 180 / .pi
////            print("Left: \(leftVec), right: \(rightVec)")
//        }
////        print("Right: \(rightAngle), left: \(leftAngle)")
//        if leftAngle > self.lMax {
//            self.lMax = leftAngle
//        }
//        if leftAngle < lMin {
//            self.lMin = leftAngle
//        }
//        if rightAngle > self.rMax {
//            self.rMax = rightAngle
//        }
//        if rightAngle < rMin {
//            self.rMin = rightAngle
//        }
//        DispatchQueue.main.async {
////            self.leftMax.text = String(format: "%.1f", self.lMax)
////            self.leftMin.text = String(format: "%.1f", self.lMin)
////            self.leftMid.text = String(format: "%.1f", (self.lMin + self.lMax) / 2)
////            self.rightMax.text = String(format: "%.1f", self.rMax)
////            self.rightMin.text = String(format: "%.1f", self.rMin)
////            self.rightMid.text = String(format: "%.1f", (self.rMin + self.rMax) / 2)
//        }
//    }
}

extension ViewController: ImageProcessorDelegate {
    
    /// Обработчик события делегата о готовности скелета для показа
    ///
    /// Номера точек:
    /// - 0 - нос
    /// - 1 - левый глаз
    /// - 2 - правый глаз
    /// - 3 - левое ухо
    /// - 4 - правое ухо
    /// - 5 - левое плечо
    /// - 6 - правое плечо
    /// - 7 - левый локоть
    /// - 8 - правый локоть
    /// - 9 - левое запястье
    /// - 10 - правое запястье
    /// - 11 - левое бедро
    /// - 12 - правое бедро
    /// - 13 - левое колено
    /// - 14 - правое колено
    /// - 15 - левая лодыжка
    /// - 16  - правая лодыжка
    /// - Parameter pose: Содержит номер опознанного скелета (если их несколько), а также номера и позиции ключевых точек
    func poseIsReady(_ pose: Pose) {
        //Пока обрабатываем только одну фигуру
        if pose.personNumber > 0 {
            return
        }
        //Считываем с периодичностью 0,1 сек. Т.к. fps = 30, то сбрасываем после трех кадров
        //Получим три последовательности
        if currentFrame < frameCounts {
            summaryPoses[currentFrame] = pose
            currentFrame += 1
        }
        else {
            currentFrame = 0
            addResults()
        }
    }
    
    private func addResults() {
        var dots = [PoseDot]()
        //Соберем показания
        for i in 0..<17 {
            var x: Int32 = 0
            var y: Int32 = 0
            var count: Int32 = 0
            for pose in summaryPoses {
                if pose.dots.count > i {
                    let dx = (pose.dots[i] as! PoseDot).dotPos.x
                    let dy = (pose.dots[i] as! PoseDot).dotPos.y
                    x += dx
                    y += dy
                    
                    if Int(dx) > appDelegate.maxX {
                        appDelegate.maxX = Int(dx)
                    }
                    if Int(dy) > appDelegate.maxY {
                        appDelegate.maxY = Int(dy)
                    }
                    count += 1
                }
            }
            let dot = PoseDot()
            dot.dotNumber = Int32(i)

            let pos = count > 0 ?  simd_int2(x: x / count, y: y / count) : simd_int2()
            dot.dotPos = pos
            dots.append(dot)
        }
        //Теперь запомним
        for dot in dots {
            let item = ResultItem(time: currentTime, pos: dot)
            appDelegate.results.append(item)
        }
    }
    
    private func saveResults() {
        self.isPlaying = false
        let leftHips = appDelegate.results.filter { $0.dotNumber == 11 }
        let rightHips = appDelegate.results.filter { $0.dotNumber == 12 }
        let leftRes = Results(resultName: "Left hip", items: leftHips, startColor: 0xff7200, finishColor: 0xffff86)
        let rightRes = Results(resultName: "Right hip", items: rightHips, startColor: 0x10ffff, finishColor: 0xbbccff)
        print("Total: \(appDelegate.results.count), leftHips: \(leftHips.count), rightHips: \(rightHips.count)")
        resultView.createScene(results: [leftRes, rightRes])
        resultView.play()
    }
}

extension ViewController {
 
    @IBAction func tnBarClicked(_ sender: Any) {
    }

}

//MARK: - Timer
extension ViewController {
    private func startTimer() -> Void {
        self.currentTime = 0
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.timeDelta), target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    private func pauseTimer() -> Void {
        self.timer.invalidate()
    }

    @objc private func update() {
        self.currentTime += 0.1
        DispatchQueue.main.async {
            self.progressView.progress = self.currentTime / self.totalSeconds
            self.timeLabel.text = String(format: "Duration: %.1f sec", self.currentTime)
        }
        //Все, заканчиваем записывать
        if currentTime > totalSeconds {
            self.saveResults()
        }
    }
}
