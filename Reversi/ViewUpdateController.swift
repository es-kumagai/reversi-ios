//
//  ViewUpdateController.swift
//  Reversi
//
//  Created by Tomohiro Kumagai on 2020/04/26.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

/// ビューのアップデートタイミングを制御するコントローラーです。
class ViewUpdateController : NSObject {
    
    /// アップデート状況を通知するデリゲートです。
    @IBOutlet private weak var delegate: ViewUpdateControllerDelegate?
    
    /// タイミングを管理するメッセージループの実行間隔です。
    private var messageLoopInterval = 0.005
    
    /// タイミングを管理する処理を実行するスレッドです。
    private var processingQueue = DispatchQueue(label: "reversi.viewupdatecontroller")
    
    /// ビューの更新リクエストを溜め込むキューです。
    private var requestQueue: Queue<ViewUpdateRequest> = []
    
    /// タイミングを管理するメッセージループです。
    private var messageLoopSource: DispatchSourceTimer!
    
    /// キュー内のメッセージ処理を先送りする回数です。
    private var messageLoopSleepCount = 0 as Double
    
    /// ストーリーボードから呼び出される初期化処理です。
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        let source = DispatchSource.makeTimerSource(flags: [], queue: processingQueue)
        
        source.schedule(deadline: .now(), repeating: messageLoopInterval)
        source.setEventHandler(handler: messageLoop)
        
        messageLoopSource = source
        messageLoopSource.resume()
    }
    
    /// キューに溜まってる更新リクエストを消去します。
    func resetRequests() {
    
        processingQueue.async {
            
            self.requestQueue.clear()
            self.messageLoopSleepCount = 0
        }
    }
    
    /// 盤面を一括で更新します。
    func request(_ request: ViewUpdateRequest) {
        
        if case .sleep(interval: 0) = request {
        
            return
        }
        
        processingQueue.async {
            
            self.requestQueue.enqueue(request)
        }
    }
    
    /// 更新タイミングを処理するメッセージループの処理本体です。
    private func messageLoop() {
        
        guard messageLoopSleepCount == 0 else {
            
            messageLoopSleepCount = max(messageLoopSleepCount - 1, 0)
            return
        }
        
        guard let request = requestQueue.dequeue() else {
            
            return
        }
        
        switch request {
            
        case .square(state: let state, location: let location):
            DispatchQueue.main.async {

                self.delegate?.viewUpdateController(self, updateSquare: state, location: location, animated: true)
            }
            
        case .board(board: let board):
            DispatchQueue.main.async {

                self.delegate?.viewUpdateController(self, updateBoard: board, animated: true)
            }
            
        case .sleep(interval: let interval):
            messageLoopSleepCount = interval / messageLoopInterval
        }
    }
}
