//
//  RecordingButton.swift
//  RecordingButton
//
//  Created by ParkSangHa on 2016. 7. 12..
//  Copyright © 2016년 parksangha1021. All rights reserved.
//

import UIKit


protocol RecordingButtonDelegate {
    func startRecording()
    func updateProgress(recordingTimeInSec: Double)
    func endRecording()
    func didBecomeIdle()
}

class RecordingButton: UIView {
    enum Mode {
        case Pressing
        case Pressed
    }
    
    enum Status {
        case Idle
        case Paused
        case Recording
    }
    
    let button: UIButton = UIButton(frame: CGRectZero)
    
    var delegate : RecordingButtonDelegate?
    var mode: Mode = Mode.Pressing
    var status: Status = Status.Idle
    
    var timeout:Double = 0
    var timeoutTimer: NSTimer? = nil
    var timer: NSTimer? = nil
    

    var totalRecordingSec: Double {
        var total: Double = 0.0
        for (_, time) in progressPaths {
            total += time
        }
        return total
    }
    
    var startRecordingTime: Double = 0.0
    
    var progressPaths = [(CAShapeLayer, Double)]()
    
    private lazy var progressLayerBackground: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.strokeStart = CGFloat(0.0)
        shape.strokeEnd = CGFloat(0.0)
        shape.fillColor = UIColor.clearColor().CGColor
        return shape
    }()
    
    final let inset: CGFloat = 5.0
    final let lineWidth: CGFloat = 5.0
    final let lineColor = UIColor.redColor()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(center: CGPoint, size: CGSize) {
        super.init(frame: CGRectZero)
        super.frame.size = size
        super.center = center
        setup()
    }
    
    
    func setup() {
        print(self.frame)
        self.layer.cornerRadius = self.frame.height / 2
        self.backgroundColor = UIColor.clearColor()
        
        
        button.frame = CGRectMake(0, 0, frame.width, frame.height)
        button.layer.cornerRadius = button.frame.height / 2
        button.addTarget(self, action: #selector(RecordingButton.didTouchDown(_:)), forControlEvents: .TouchDown)
        button.addTarget(self, action: #selector(RecordingButton.didTouchUp(_:)), forControlEvents: [.TouchUpInside, .TouchUpOutside])
        button.backgroundColor = UIColor.redColor()
        addSubview(button)
        
        layer.addSublayer(progressLayerBackground)
        
        progressLayerBackground.hidden = false
        progressLayerBackground.path = UIBezierPath(semiCircleInSize: self.frame.size, inset: CGFloat(inset)).CGPath
        progressLayerBackground.strokeColor = UIColor.lightGrayColor().CGColor
        progressLayerBackground.lineWidth = CGFloat(lineWidth)
        progressLayerBackground.strokeEnd = 1.0
        
//        layer.addSublayer(progressLayer)
    }
    
    
    
    func didTouchDown(sender: UIButton) {
        if mode == Mode.Pressing {
            addNewProgressPath()
            startRecording()
        }
        else {
            if status == Status.Idle {
                addNewProgressPath()
                startRecording()
            }
            else if status == Status.Paused {
                addNewProgressPath()
                startRecording()
            }
            else if status == Status.Recording {
                delegate?.endRecording()
                pauseRecording()
            }
        }
    }
    
    func didTouchUp(sender: UIButton) {
        if mode == Mode.Pressing {
            delegate?.endRecording()
            pauseRecording()
        }
    }
    
    
    func updateProgress() {
        if let last = progressPaths.last {
            
            let recordingTime = NSDate().timeIntervalSince1970 - self.startRecordingTime
            let startAngle = calculateStartAngle()
            
            
            
            
            last.0.hidden = false
            last.0.path = UIBezierPath(semiCircleInSize: self.frame.size, inset: CGFloat(inset), startAngle: startAngle).CGPath
            last.0.strokeColor = lineColor.CGColor
            last.0.lineWidth = CGFloat(lineWidth)
            
            if progressPaths.count > 1 {
                let elapsedTime = Array(progressPaths[0...progressPaths.count-2]).map{ $0.1 }.reduce(0, combine: +)
                last.0.strokeEnd = CGFloat(recordingTime / (timeout-elapsedTime))
            } else {
                last.0.strokeEnd = CGFloat(recordingTime / timeout)
            }
            
            let updatedPath = (last.0, recordingTime)
            
            progressPaths[progressPaths.count - 1] = updatedPath

            delegate?.updateProgress(totalRecordingSec)
        }
    }
    
    func timeoutRecording() {
        delegate?.endRecording()
        endRecording()
    }
    
    private func addNewProgressPath() -> CAShapeLayer {
        let shape = CAShapeLayer()
        shape.strokeStart = CGFloat(0.0)
        shape.strokeEnd = CGFloat(0.0)
        shape.fillColor = UIColor.clearColor().CGColor
        
        progressPaths.append((shape, 0.0))
        
        layer.addSublayer(shape)
        
        return shape
    }
    
    private func startRecording() {
        self.timer?.invalidate()
        self.timer = nil
        self.timeoutTimer?.invalidate()
        self.timeoutTimer = nil
        
        status = Status.Recording
        button.frame = CGRectMake(0, 0, button.frame.width / 1.3, button.frame.height / 1.3)
        button.center = CGPointMake(frame.width / 2, frame.height / 2)
        button.layer.cornerRadius = button.frame.height / 5
        
        delegate?.startRecording()
        self.startRecordingTime = NSDate().timeIntervalSince1970

        updateProgress()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(RecordingButton.updateProgress), userInfo: nil, repeats: true)
        timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(timeout-totalRecordingSec, target: self, selector: #selector(RecordingButton.timeoutRecording), userInfo: nil, repeats: false)
    }
    
    
    private func pauseRecording() {
        button.enabled = false
        
        self.status = Status.Paused
        
        self.button.enabled = true
        self.button.frame = CGRectMake(0, 0, self.button.frame.width * 1.3, self.button.frame.height * 1.3)
        self.button.center = CGPointMake(self.frame.width / 2.0, self.frame.height / 2.0)
        self.button.layer.cornerRadius = self.button.frame.height / 2.0

        self.timer?.invalidate()
        self.timer = nil
        self.timeoutTimer?.invalidate()
        self.timeoutTimer = nil
    }
    
    
    
    private func endRecording() {
        button.enabled = false
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.status = Status.Idle
            
            self.button.enabled = true
            self.button.frame = CGRectMake(0, 0, self.button.frame.width * 1.3, self.button.frame.height * 1.3)
            self.button.center = CGPointMake(self.frame.width / 2.0, self.frame.height / 2.0)
            self.button.layer.cornerRadius = self.button.frame.height / 2.0
            
            self.timer?.invalidate()
            self.timer = nil
            self.timeoutTimer?.invalidate()
            self.timeoutTimer = nil
        }
    }
    
    
    func cancelRecording() {
        startRecordingTime = 0.0
        for path in progressPaths {
            path.0.hidden = true
            path.0.strokeEnd = 0.0
            path.0.removeFromSuperlayer()
        }
        progressPaths.removeAll()
    }
    
    func backRecording() {
        if let last = progressPaths.last {
            last.0.hidden = true
            last.0.strokeEnd = 0.0
            last.0.removeFromSuperlayer()
        }
        progressPaths.removeLast()
        
        let progress = totalRecordingSec
        delegate?.updateProgress(progress)
        if progressPaths.count <= 0 {
            delegate?.didBecomeIdle()
        }
    }
    
    
    
    private func calculateStartAngle() -> CGFloat {
        
        if progressPaths.count > 1 {
            let elapsedTime = Array(progressPaths[0...progressPaths.count-2]).map{ $0.1 }.reduce(0, combine: +)
            let temp = elapsedTime / timeout
            let prePath = CGFloat(2 * M_PI * temp)
        
//            let elapsedStrokeEnd = Array(progressPaths[0...progressPaths.count-2]).map{ $0.0.strokeEnd }.reduce(0, combine: +)
//            let sePath = CGFloat(2.0 * M_PI) * elapsedStrokeEnd
//            print("sum: \(CGFloat(1.5 * M_PI) + prePath)")
//            print("ste: \(CGFloat(1.5 * M_PI) + sePath)")
            
            return CGFloat(1.5 * M_PI) + prePath
        }
        return CGFloat(1.5 * M_PI)
    }
}


extension UIBezierPath {
    convenience init(semiCircleInSize size: CGSize, inset: CGFloat, startAngle: CGFloat? = nil) {
        self.init()
        let center = CGPointMake(size.width / CGFloat(2.0), size.height / CGFloat(2.0))
        let minSize: CGFloat = size.width + 20
        let radius = minSize / CGFloat(2.0) - inset
        
        let start = startAngle ?? CGFloat(1.5 * M_PI)
        let end = CGFloat(3.5 * M_PI)

        self.addArcWithCenter(center, radius: radius, startAngle: start, endAngle: end, clockwise: true)
    }
}