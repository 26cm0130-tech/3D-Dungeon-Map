import SwiftUI

/// クリア表示(仕様書§13.1、UI仕様書§14)。プレイ画面の上に重ねて表示する
struct ClearView: View {
    /// 「スタート画面へ」が押されたときの処理
    let onReturn: () -> Void

    var body: some View {
        ZStack {
            // 後ろのプレイ画面を操作できないように、画面全体を覆う
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("ゲームクリア!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Button(action: onReturn) {
                    Text("スタート画面へ")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .overlay(Rectangle().stroke(Color.white, lineWidth: 2))
                }
                .frame(maxWidth: 320)
            }
            .padding()
        }
    }
}
