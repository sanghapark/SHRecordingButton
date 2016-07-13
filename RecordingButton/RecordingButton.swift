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
    func updateProgress(recordingTimeInSec: Float)
    func endRecording()
}

class RecordingButton: UIButton {
    
    enum Mode {
        case Pressing
        case Pressed
    }
    
    enum Status {
        case Idle
        case Recording
    }
    
    var delegate : RecordingButtonDelegate?
    var mode: Mode = Mode.Pressing
    var status: Status = Status.Idle
    
    var timeout:Double = 10
    var timeoutTimer: NSTimer? = nil
    var timer: NSTimer? = nil
    
    var progress: Float = 0

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
    final let lineColor = UIColor.blueColor()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup() {
        self.layer.cornerRadius = self.frame.height / 2
        self.backgroundColor = UIColor.redColor()
        self.addTarget(self, action: #selector(RecordingButton.didTouchDown(_:)), forControlEvents: .TouchDown)
        self.addTarget(self, action: #selector(RecordingButton.didTouchUp(_:)), forControlEvents: [.TouchUpInside, .TouchUpOutside])
        
        
        layer.addSublayer(progressLayerBackground)
        
        progressLayerBackground.hidden = false
        progressLayerBackground.path = UIBezierPath(semiCircleInRect: bounds, inset: CGFloat(inset)).CGPath
        progressLayerBackground.strokeColor = UIColor.lightGrayColor().CGColor
        progressLayerBackground.lineWidth = CGFloat(lineWidth)
        progressLayerBackground.strokeEnd = 1.0
        
        layer.addSublayer(progressLayer)
    }
    
    
    
    func didTouchDown(sender: UIButton) {
        print("touch down")
        
        if mode == Mode.Pressing {
            startRecording()
        } else {
            if status == Status.Idle {
                startRecording()
            } else if status == Status.Recording {
                delegate?.endRecording()
                endRecording()
            }
        }
    }
    
    func didTouchUp(sender: UIButton) {
        print("touch up inside")
        if mode == Mode.Pressing {
            delegate?.endRecording()
            endRecording()
        }
    }

    
    func updateProgress() {
        print("updateProgress")
        progress += 0.1
        
        delegate?.updateProgress(progress)
        
        progressLayer.hidden = false
        progressLayer.path = UIBezierPath(semiCircleInRect: bounds, inset: CGFloat(inset)).CGPath
        progressLayer.strokeColor = lineColor.CGColor
        progressLayer.lineWidth = CGFloat(lineWidth)
        progressLayer.strokeEnd = CGFloat(progress) / CGFloat(timeout)
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
        
        delegate?.startRecording()
        
        self.progress = 0.0
        updateProgress()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(RecordingButton.updateProgress), userInfo: nil, repeats: true)
        timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(timeout, target: self, selector: #selector(RecordingButton.timeoutRecording), userInfo: nil, repeats: false)
    }
    
    private func endRecording() {
        enabled = false
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.enabled = true
            self.status = Status.Idle
            self.progressLayer.hidden = true
            self.progressLayer.strokeEnd = 0
            self.progress = 0.0
            self.timer?.invalidate()
            self.timer = nil
            self.timeoutTimer?.invalidate()
            self.timeoutTimer = nil
        }
    }
}



extension UIBezierPath {
    convenience init(semiCircleInRect rect: CGRect, inset: CGFloat) {
        self.init()
        let center = CGPointMake(CGRectGetWidth(rect) / CGFloat(2.0),
                                 CGRectGetHeight(rect) / CGFloat(2.0))
        //        let minSize = min(CGRectGetWidth(rect), CGRectGetHeight(rect)) / 3
//        let minSize:CGFloat = 80.0
        let minSize: CGFloat = rect.size.width + 20
        let radius = minSize / CGFloat(2.0) - inset
        
        let startAngle = CGFloat(1.5 * M_PI)
        let endAngle = CGFloat(3.5 * M_PI)
        self.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
}