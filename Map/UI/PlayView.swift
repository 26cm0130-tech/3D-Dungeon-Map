import SwiftUI

/// プレイ画面。表示と入力の受け渡しだけを行い、ゲームの状態は GameManager が持つ
struct PlayView: View {
    /// 現在のプレイ(AppFlow が作って渡す)
    @ObservedObject var game: GameManager

    /// ギブアップが確定したときの処理(スタート画面へ戻る)
    let onGiveUp: () -> Void

    /// ギブアップの確認を表示中か
    @State private var isConfirmingGiveUp = false

    var body: some View {
        VStack(spacing: 12) {
            // ① 3Dダンジョン
            DungeonView(
                map: game.map,
                player: game.state.player
            )

            // ② メッセージ(1行分の高さを確保し、画面が動かないようにする)
            Text(game.state.message)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .frame(height: 24)

            // ③ オートマップ
            AutoMapView(
                map: game.map,
                explored: game.state.explored,
                player: game.state.player
            )
            .frame(maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)

            // ④ コマンド
            CommandView(
                onTurnLeft: game.turnLeft,
                onForward: game.moveForward,
                onTurnRight: game.turnRight,
                onGiveUp: { isConfirmingGiveUp = true }   // まず確認を表示する
            )
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        // ギブアップの確認(表示中は、後ろの操作を受け付けない)
        .overlay {
            if isConfirmingGiveUp {
                GiveUpConfirmView(
                    onYes: onGiveUp,
                    onNo: { isConfirmingGiveUp = false }
                )
            }
        }
    }
}
