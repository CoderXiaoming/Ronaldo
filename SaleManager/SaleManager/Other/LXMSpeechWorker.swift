//
//  LXMSpeechWorker.swift
//  SaleManager
//
//  Created by apple on 17/2/8.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit
import Speech

@available(iOS 10.0, *)
class LXMSpeechWorker: SFSpeechRecognizer {
    //MARK: - 开始录音
    class func startRecording() {
        
        //0-请求权限
        SFSpeechRecognizer.requestAuthorization { (status) in
            
            //如果允许
            if status == .authorized {
                speechRecognizer.speechResults.removeAllObjects()
                
                if speechRecognizer.recognitionTask != nil {  //1
                    speechRecognizer.recognitionTask?.cancel()
                    speechRecognizer.recognitionTask = nil
                }
                
                let audioSession = AVAudioSession.sharedInstance()  //2
                do {
                    try audioSession.setCategory(AVAudioSessionCategoryRecord)
                    try audioSession.setMode(AVAudioSessionModeMeasurement)
                    try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
                } catch {
                }
                
                speechRecognizer.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
                
                guard let inputNode = speechRecognizer.audioEngine.inputNode else {
                    fatalError("Audio engine has no input node")
                }  //4
                
                guard let recognitionRequest = speechRecognizer.recognitionRequest else {
                    fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
                } //5
                
                recognitionRequest.shouldReportPartialResults = true  //6
                
                speechRecognizer.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
                    
                    var isFinal = false  //8
                    
                    if result != nil {
                        
                        let text = result?.bestTranscription.formattedString  //9
                        speechRecognizer.speechResults.add(text ?? "")
                        isFinal = (result?.isFinal)!
                    }
                    
                    if error != nil || isFinal {  //10
                        speechRecognizer.audioEngine.stop()
                        inputNode.removeTap(onBus: 0)
                        
                        speechRecognizer.recognitionRequest = nil
                        speechRecognizer.recognitionTask = nil
                    }
                })
                
                let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                    speechRecognizer.recognitionRequest?.append(buffer)
                }
                
                speechRecognizer.audioEngine.prepare()  //12
                
                do {
                    try speechRecognizer.audioEngine.start()
                } catch {
                    print("audioEngine couldn't start because of an error.")
                }
            }
        }
    }
    
    class func stopRecording() {
        speechRecognizer.audioEngine.stop()
        speechRecognizer.recognitionRequest?.endAudio()
        
        //设置加载hud
        let hud = SAMHUD.showAdded(to: KeyWindow!, animated: true)
        hud!.labelText = NSLocalizedString("", comment: "HUD loading title")
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            hud?.hide(true)
            
            if speechRecognizer.speechResults.count == 0 { //没有数据
                _ = SAMHUD.showMessage("你好，大舌头😆😆😆", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                
            }else {
                
                let resultStr = speechRecognizer.speechResults.lastObject as? String
                var finalResult = ""
                for obj in (resultStr?.characters)! {
                    let str = String(obj)
                    if speechRecognizer.speechDictionary[str] != nil {
                        finalResult += speechRecognizer.speechDictionary[str]!
                    }
                }
                //判断结果
                if finalResult == "" {
                    _ = SAMHUD.showMessage("你好，大舌头😆😆😆", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                }else {
                    //发出通知
                    NotificationCenter.default.post(name: NSNotification.Name.init(SAMStockConSearchControllerSpeechSuccessNotification), object: nil, userInfo: ["searchString": finalResult])
                }
            }
        }
    }
    
    //MARK: - 属性
    static let speechRecognizer = LXMSpeechWorker(locale: Locale.init(identifier: "zh-cn"))!
    fileprivate var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    fileprivate let audioEngine = AVAudioEngine()
    
    //语音识别结果数组
    fileprivate let speechResults = NSMutableArray()
    fileprivate let speechDictionary = ["零": "0", "一": "1", "二": "2", "三": "3", "四": "4", "五": "5", "六": "6", "七": "7", "八": "8", "九": "9", "0": "0", "1": "1", "2": "2", "3": "3", "4": "4", "5": "5", "6": "6", "7": "7", "8": "8", "9": "9", "杠": "-"]
}
