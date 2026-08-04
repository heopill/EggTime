//
//  CompletionSoundPlayer.swift
//  EggTimer
//

import AVFoundation

// 포그라운드에서 무음 스위치를 무시하고 타이머 완료음을 재생한다
final class CompletionSoundPlayer: NSObject, AVAudioPlayerDelegate {
    static let shared = CompletionSoundPlayer()

    // 재생이 끝날 때까지 플레이어를 붙잡아 둔다
    private var player: AVAudioPlayer?

    private override init() {}

    /// 현재 선택된 종료음을 재생한다 (완료 시점 사용)
    func play() {
        play(TimerEndSound.current)
    }

    /// 지정한 종료음을 재생한다 (미리듣기 등). 무음 모드에서도 들리도록 .playback 카테고리를 사용
    func play(_ sound: TimerEndSound) {
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "wav") else {
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            // .playback은 무음 스위치를 무시하고 소리를 재생한다
            try session.setCategory(.playback, options: [])
            try session.setActive(true)

            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            self.player = player
            player.play()
        } catch {
            // 재생에 실패해도 배너 알림은 그대로 표시되므로 조용히 무시한다
            // 세션을 켜지 못했거나 재생에 실패했으면 붙잡고 있던 세션을 내려 다른 앱 오디오를 복구한다
            deactivateSession()
        }
    }

    /// 재생이 끝나면 오디오 세션을 내려, 중단됐던 다른 앱의 오디오(음악·팟캐스트 등)가 다시 재생되게 한다
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 더 최근에 시작된 재생이 있으면(연속 미리듣기 등) 세션을 내리지 않는다
        guard player === self.player else {
            return
        }
        self.player = nil

        deactivateSession()
    }

    /// 오디오 세션을 비활성화하고, 중단됐던 다른 앱 오디오의 복귀를 알린다
    private func deactivateSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            // 비활성화 실패는 무시한다 (다음 재생 시 다시 설정된다)
        }
    }
}
