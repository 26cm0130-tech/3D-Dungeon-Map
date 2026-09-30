import SwiftUI

/// スタート画面(仕様書§13.3、UI仕様書§13)。面を選んで開始する
struct StartView: View {
    /// 選べる面の一覧(表示順)
    let stages: [Stage]
    /// 面が選ばれたときの処理
    let onSelect: (Stage) -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Dungeon Game")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)

            // 面を選ぶボタン(コマンドボタンと同じ様式)
            VStack(spacing: 12) {
                ForEach(stages.indices, id: \.self) { index in
                    let stage = stages[index]
                    Button {
                        onSelect(stage)
                    } label: {
                        Text(stage.title)
                            .font(.system(size: 20, weight: .bold))
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .overlay(Rectangle().stroke(Color.white, lineWidth: 2))
                    }
                }
            }
            .frame(maxWidth: 320)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}
