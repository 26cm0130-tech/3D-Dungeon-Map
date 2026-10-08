import AVFoundation
import SwiftUI

/// クリア表示(仕様書§13.1、UI仕様書§14)。プレイ画面の上に重ねて、画面全体を覆って表示する
struct ClearView: View {
    /// 「スタート画面へ」が押されたときの処理
    let onReturn: () -> Void

    @State private var clearAudioPlayer: AVAudioPlayer?

    var body: some View {
        ZStack {
            // 後ろのプレイ画面を操作できないように、画面全体を黒で覆う
            Color.black
                .ignoresSafeArea()

            // 画面全体を囲む、細い白の枠
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                .padding(16)

            VStack(spacing: 16) {
                // 小さい画面でも、1行に収まるように縮小できるようにする
                Text("おめでとう!")
                    .font(.system(size: 60, weight: .bold))
                    .tracking(2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(.white)

                Text("ゲームクリア")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)

                Button(action: onReturn) {
                    Text("スタート画面へ")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 56)
                }
                .buttonStyle(DungeonPressButtonStyle())
                .frame(maxWidth: 280)
            }
            .padding(32)
        }
        .onAppear {
            guard let url = Bundle.main.url(forResource: "レトロなゲームクリア音", withExtension: "mp3"),
                  let player = try? AVAudioPlayer(contentsOf: url) else { return }
            player.prepareToPlay()
            player.play()
            clearAudioPlayer = player
        }
        .onDisappear {
            clearAudioPlayer?.stop()
            clearAudioPlayer = nil
        }
    }
}
