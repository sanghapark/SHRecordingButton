//
//  ViewController.swift
//  RecordingButton
//
//  Created by ParkSangHa on 2016. 7. 12..
//  Copyright © 2016년 parksangha1021. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var recordingButton : RecordingButton?
    var recordingTimeLabel: RecordingTimeLabel?
    
    var cancelButton = UIButton(frame: CGRectZero)

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    
    
    func initViews() {
        let screenW = UIScreen.mainScreen().bounds.width
        let screenH = UIScreen.mainScreen().bounds.height
        recordingButton = RecordingButton(center: CGPointMake(screenW / 2, screenH - 70), size: CGSizeMake(70, 70))
        recordingButton!.mode = .Pressed
//        recordingButton!.mode = .Pressing
        recordingButton!.timeout = 30.0
        recordingButton!.delegate = self
        view.addSubview(recordingButton!)
        
        
        recordingTimeLabel = RecordingTimeLabel(frame: CGRectZero)
        recordingTimeLabel!.center = CGPointMake(screenW / 2, screenH / 2)
        view.addSubview(recordingTimeLabel!)
        
        
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
        cancelButton.sizeToFit()
        cancelButton.center.y = recordingButton!.center.y
        cancelButton.frame.origin.x = 20
        cancelButton.addTarget(self, action: #selector(ViewController.cancelRecording), forControlEvents: .TouchUpInside)
        view.addSubview(cancelButton)
        cancelButton.hidden = true
    }


    func cancelRecording() {
        recordingButton!.cancelRecording()
        recordingTimeLabel!.updateTime(0.0)
        self.cancelButton.hidden = true
    }


}


extension ViewController: RecordingButtonDelegate {
    func startRecording() {
        cancelButton.hidden = true
        recordingTimeLabel?.startRecording()
    }
    
    func endRecording() {
        cancelButton.hidden = false
        recordingTimeLabel?.endRecording()
    }
    
    func updateProgress(recordingTimeInSec: Float) {
        recordingTimeLabel?.updateTime(recordingTimeInSec)
    }
}



