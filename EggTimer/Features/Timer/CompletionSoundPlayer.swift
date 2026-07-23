//
//  CompletionSoundPlayer.swift
//  EggTimer
//

import AVFoundation

// 포그라운드에서 무음 스위치를 무시하고 타이머 완료음을 재생한다
final class CompletionSoundPlayer {
    static let shared = CompletionSoundPlayer()

    // 재생이 끝날 때까지 플레이어를 붙잡아 둔다
    private var player: AVAudioPlayer?

    private init() {}

    /// 번들의 완료음을 재생한다 (무음 모드에서도 들리도록 .playback 카테고리를 사용)
    func play() {
        guard let url = Bundle.main.url(forResource: "fanfare", withExtension: "wav") else {
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            // .playback은 무음 스위치를 무시하고 소리를 재생한다
            try session.setCategory(.playback, options: [])
            try session.setActive(true)

            let player = try AVAudioPlayer(contentsOf: url)
            self.player = player
            player.play()
        } catch {
            // 재생에 실패해도 배너 알림은 그대로 표시되므로 조용히 무시한다
        }
    }
}
