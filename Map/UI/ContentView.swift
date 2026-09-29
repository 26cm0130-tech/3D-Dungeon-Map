import SwiftUI

/// プレイ画面。表示と入力の受け渡しだけを行い、ゲームの状態は GameManager が持つ
struct ContentView: View {
    @StateObject private var game = GameManager(map: Stages.honban)

    var body: some View {
        VStack(spacing: 12) {
            // ① 3Dダンジョン
            DungeonView(isWall: game.isWallRelative)

            // ② オートマップ
            AutoMapView(
                map: game.map,
                explored: game.state.explored,
                player: game.state.player
            )
            .frame(maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)

            // メッセージ
            Text(game.state.message)
                .foregroundColor(.white)
                .frame(height: 24)

            // ③ コマンド
            CommandView(
                onTurnLeft: game.turnLeft,
                onForward: game.moveForward,
                onTurnRight: game.turnRight
            )
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
}
