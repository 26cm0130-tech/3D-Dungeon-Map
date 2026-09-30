import SwiftUI

/// アプリの最初の画面。画面の状態(AppFlow)に従って、
/// スタート画面・プレイ画面・クリア表示を切り替える
struct ContentView: View {
    @StateObject private var flow = AppFlow()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch flow.screen {
            case .start:
                // スタート画面(面を選ぶ)
                StartView(stages: Stages.all, onSelect: flow.startGame)

            case .playing, .cleared:
                // プレイ画面。クリアしたときは、上にクリア表示を重ねる
                if let game = flow.game {
                    PlayView(game: game)
                        .overlay {
                            if flow.screen == .cleared {
                                ClearView(onReturn: flow.returnToStart)
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
