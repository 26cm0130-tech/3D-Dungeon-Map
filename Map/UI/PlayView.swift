import SwiftUI

/// プレイ画面。表示と入力の受け渡しだけを行い、ゲームの状態は GameManager が持つ
struct PlayView: View {
    /// 現在のプレイ(AppFlow が作って渡す)
    @ObservedObject var game: GameManager

    /// ギブアップが確定したときの処理(スタート画面へ戻る)
    let onGiveUp: () -> Void

    /// ギブアップの確認を表示中か
    @State private var isConfirmingGiveUp = false
    /// 鍵取得演出を表示中か
    @State private var isShowingKeyAcquisition = false

    /// プレイヤーが鍵のあるマスにいるか
    private var isStandingAtKey: Bool {
        game.map.cell(at: game.state.player.position) == .key
    }

    /// 添付画面で正面を示す、カーソルが左（西）を指す向き
    private var isFacingKeyChest: Bool {
        game.state.player.direction == .west
    }

    /// イベントの状況メッセージを優先し、なければ現在のチュートリアル案内を表示する
    private var displayedMessage: String {
        if !game.state.message.isEmpty {
            return game.state.message
        }
        return game.state.tutorialStep?.instruction ?? ""
    }

    var body: some View {
        VStack(spacing: 12) {
            // ① ダンジョン画面
            DungeonView(
                map: game.map,
                player: game.state.player
            )
            .overlay {
                if isStandingAtKey {
                    KeyAcquisitionView(
                        hasKey: game.state.hasKey,
                        isAcquiringKey: isShowingKeyAcquisition,
                        isFacingChest: isFacingKeyChest,
                        onFinished: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                isShowingKeyAcquisition = false
                            }
                        }
                    )
                    .padding(2)
                    .transition(.opacity)
                }
            }

            // ② メッセージ(段階案内と状況メッセージを、固定の高さに表示する)
            Text(displayedMessage)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
                .frame(height: 48)

            // ③ 探索マップ
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
        .onChange(of: game.state.hasKey) { hadKey, hasKey in
            // hasKey が初めて false から true になったときだけ演出する
            if !hadKey && hasKey {
                withAnimation(.easeIn(duration: 0.12)) {
                    isShowingKeyAcquisition = true
                }
            }
        }
        .onChange(of: isStandingAtKey) { _, isAtKey in
            // 演出中に鍵のあるマスを離れたら、再入場時は空の宝箱を表示する
            if !isAtKey {
                isShowingKeyAcquisition = false
            }
        }
    }
}
