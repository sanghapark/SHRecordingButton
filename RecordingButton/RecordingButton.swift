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
    
    var timeout:Double = 10
    var timeoutTimer: NSTimer? = nil
    var timer: NSTimer? = nil
    

    var totalRecordingSec: Double {
        var total: Double = 0.0
        for time in recordingTimes {
            total += time
        }
        return total
    }
    
    var startRecordingTime: Double = 0.0
    var recordingTimes = [Double]()
    
    private lazy var progressLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.strokeStart = CGFloat(0.0)
        shape.strokeEnd = CGFloat(0.0)
        shape.fillColor = UIColor.clearColor().CGColor
        return shape
    }()
    
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
        
        layer.addSublayer(progressLayer)
    }
    
    
    
    func didTouchDown(sender: UIButton) {
        print("touch down")
        
        if mode == Mode.Pressing {
            startRecording()
        }
        else {
            if status == Status.Idle {
                startRecording()
            }
            else if status == Status.Paused {
                recordingTimes.append(0.0)
                startRecording()
            }
            else if status == Status.Recording {
                delegate?.endRecording()
                pauseRecording()
            }
        }
    }
    
    func didTouchUp(sender: UIButton) {
        print("touch up inside")
        if mode == Mode.Pressing {
            delegate?.endRecording()
            pauseRecording()
        }
    }
    
    
    func updateProgress() {
        print("updateProgress")
        
        let recordingTime = NSDate().timeIntervalSince1970 - self.startRecordingTime
        if recordingTimes.count > 0 {
            recordingTimes[recordingTimes.count-1] = recordingTime
        } else {
            recordingTimes.append(recordingTime)
        }
        
        let progress = totalRecordingSec
        
        progressLayer.hidden = false
        progressLayer.path = UIBezierPath(semiCircleInSize: self.frame.size, inset: CGFloat(inset)).CGPath
        progressLayer.strokeColor = lineColor.CGColor
        progressLayer.lineWidth = CGFloat(lineWidth)
        progressLayer.strokeEnd = CGFloat(progress) / CGFloat(timeout)
        
        delegate?.updateProgress(progress)
    }
    
    func timeoutRecording() {
        print("time out recording...")
        delegate?.endRecording()
        endRecording()
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
        self.progressLayer.hidden = true
        self.progressLayer.strokeEnd = 0
        
        self.startRecordingTime = 0.0
        self.recordingTimes.removeAll()
    }
    
    func backRecording() {
        self.recordingTimes.removeLast()
        
        let progress = totalRecordingSec
        
        progressLayer.path = UIBezierPath(semiCircleInSize: self.frame.size, inset: CGFloat(inset)).CGPath
        progressLayer.strokeColor = lineColor.CGColor
        progressLayer.lineWidth = CGFloat(lineWidth)
        progressLayer.strokeEnd = CGFloat(progress) / CGFloat(timeout)
        
        delegate?.updateProgress(progress)
        
        if recordingTimes.count <= 0 {
            delegate?.didBecomeIdle()
        }
    }
}


extension UIBezierPath {
    convenience init(semiCircleInSize size: CGSize, inset: CGFloat) {
        self.init()
        let center = CGPointMake(size.width / CGFloat(2.0), size.height / CGFloat(2.0))
        let minSize: CGFloat = size.width + 20
        let radius = minSize / CGFloat(2.0) - inset
        
        let startAngle = CGFloat(1.5 * M_PI)
        let endAngle = CGFloat(3.5 * M_PI)

        self.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
}