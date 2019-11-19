//
//  ViewController.swift
//  RunChecker
//
//  Created by Evgeniy Lugovoy on 19.11.2019.
//  Copyright © 2019 MeadowsPhoneTeam. All rights reserved.
//

import UIKit
import simd

class ViewController: UIViewController, ImageProcessorDelegate {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnStart: UIButton!

    @IBOutlet weak var leftMax: UILabel!
    @IBOutlet weak var leftMin: UILabel!
    @IBOutlet weak var leftMid: UILabel!
    
    @IBOutlet weak var rightMax: UILabel!
    @IBOutlet weak var rightMin: UILabel!
    @IBOutlet weak var rightMid: UILabel!

    private var lMax: Float = 0
    private var lMin: Float = 360
    private var rMax: Float = 0
    private var rMin: Float = 360

    var camera: NostalgiaCamera!
    var imageProcessor: ImageProcessor!
    
    private var isPlaying: Bool = false {
        didSet {
            let title = isPlaying ? "Стоп" : "Старт"
            btnStart.setTitle(title, for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        let resourceURL = Bundle.main.url(forResource: "chavan", withExtension: "mov")
//        print(resourceURL as Any)
//        videoPlayer = VideoPlayer(fileUrl: resourceURL!, imageView: imgView)
        imageProcessor = ImageProcessor(controller: self)
        camera = NostalgiaCamera(processor: imageProcessor, andImageView: imgView)
    }
    
    @IBAction func startClicked(_ sender: Any) {
//        videoPlayer!.start()
        if isPlaying {
            camera.stop()
            isPlaying = false
        }
        else {
            camera.start()
            isPlaying = true
            leftMin.text = ""
            leftMid.text = ""
            leftMax.text = ""
            rightMin.text = ""
            rightMid.text = ""
            rightMax.text = ""
        }
    }
    
    /// Обработчик события делегата о готовности скелета для показа
    /// - Parameter pose: Содержит номер опознанного скелета (если их несколько), а также номера и позиции ключевых точек
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
    func poseIsReady(_ pose: Pose) {
        //Пока обрабатываем только одну фигуру
        if pose.personNumber > 0 || pose.dots.count < 17 {
            return
        }
        var leftAngle: Float = 0
        var rightAngle: Float = 0
        //Смотрим на плечи и бедра
        if let leftShoulder = pose.dots[6] as? PoseDot, let leftHip = pose.dots[12] as? PoseDot, let rightShoulder = pose.dots[5] as? PoseDot, let rightHip = pose.dots[11] as? PoseDot {
            let leftVec = simd_int2(x: leftHip.dotPos.x - leftShoulder.dotPos.x, y: leftHip.dotPos.y - leftShoulder.dotPos.y)
            leftAngle = atan2f(Float(leftVec.y), Float(leftVec.x)) * 180 / .pi
            let rightVec = simd_int2(x: rightHip.dotPos.x - rightShoulder.dotPos.x, y: rightHip.dotPos.y - rightShoulder.dotPos.y)
            rightAngle = atan2f(Float(rightVec.y), Float(rightVec.x)) * 180 / .pi
//            print("Left: \(leftVec), right: \(rightVec)")
        }
//        print("Right: \(rightAngle), left: \(leftAngle)")
        if leftAngle > self.lMax {
            self.lMax = leftAngle
        }
        if leftAngle < lMin {
            self.lMin = leftAngle
        }
        if rightAngle > self.rMax {
            self.rMax = rightAngle
        }
        if rightAngle < rMin {
            self.rMin = rightAngle
        }
        DispatchQueue.main.async {
            self.leftMax.text = String(format: "%.1f", self.lMax)
            self.leftMin.text = String(format: "%.1f", self.lMin)
            self.leftMid.text = String(format: "%.1f", (self.lMin + self.lMax) / 2)
            self.rightMax.text = String(format: "%.1f", self.rMax)
            self.rightMin.text = String(format: "%.1f", self.rMin)
            self.rightMid.text = String(format: "%.1f", (self.rMin + self.rMax) / 2)
        }
    }

}

