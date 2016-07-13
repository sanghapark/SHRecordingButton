//
//  RecordingTimeLabel.swift
//  RecordingButton
//
//  Created by ParkSangHa on 2016. 7. 12..
//  Copyright © 2016년 parksangha1021. All rights reserved.
//

import UIKit

class RecordingTimeLabel: UILabel {

    var redDotView: UIView?
    
    var redDotTimer: NSTimer?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    
    func setup() {
        backgroundColor = UIColor.clearColor()
        text = convertSecToMinSec(0)
        sizeToFit()
        
        let rect = CGRectMake(0, 0, 5, 5)
        redDotView = UIView(frame: rect)
        redDotView!.layer.cornerRadius = redDotView!.frame.height / 2
        redDotView!.center = CGPointMake(0, 0)
        redDotView!.backgroundColor = UIColor.redColor()
        redDotView!.hidden = true
        self.addSubview(redDotView!)
    }
    
    
    func updateTime(recordingTime: Double) {
        text = convertSecToMinSec(recordingTime)
        sizeToFit()
    }
    
    func startRecording() {
        updateTime(0)
        redDotTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(RecordingTimeLabel.recording), userInfo: nil, repeats: true)
    }
    
    func endRecording() {
        redDotView!.hidden = true
        redDotTimer?.invalidate()
        redDotTimer = nil
    }
    
    func recording() {
        redDotView!.hidden = !redDotView!.hidden
    }

    
    private func convertSecToMinSec(sec: Double) -> String {
        let secInt = Int(sec)
        let secondsOnesPlace = secInt % 10
        let secondsTensPlace = (secInt % 60) / 10
        let remainingMinutes = secInt / 60
        let remainingMinutesOncePlace = remainingMinutes % 10
        let remainingMinutesTensPlace = (remainingMinutes / 10) % 10
        return "\(remainingMinutesTensPlace)\(remainingMinutesOncePlace):\(secondsTensPlace)\(secondsOnesPlace)"
    }
}


