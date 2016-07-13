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

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    
    
    func initViews() {
        let screenW = UIScreen.mainScreen().bounds.width
        let screenH = UIScreen.mainScreen().bounds.height
//        recordingButton = RecordingButton(frame: rect)
        recordingButton = RecordingButton(center: CGPointMake(screenW / 2, screenH - 70), size: CGSizeMake(70, 70))
        recordingButton!.mode = .Pressed
//        recordingButton!.mode = .Pressing
        recordingButton!.timeout = 30.0
//        recordingButton!.center = CGPointMake(screenW / 2, screenH - 70)
        recordingButton!.delegate = self
        view.addSubview(recordingButton!)
        
        
        recordingTimeLabel = RecordingTimeLabel(frame: CGRectZero)
        recordingTimeLabel!.center = CGPointMake(screenW / 2, screenH / 2)
        view.addSubview(recordingTimeLabel!)
        
    }





}


extension ViewController: RecordingButtonDelegate {
    func startRecording() {
        recordingTimeLabel?.startRecording()
    }
    
    func endRecording() {
        recordingTimeLabel?.endRecording()
    }
    
    func updateProgress(recordingTimeInSec: Float) {
        recordingTimeLabel?.updateTime(recordingTimeInSec)
    }
}



