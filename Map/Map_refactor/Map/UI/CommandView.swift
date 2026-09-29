import SwiftUI

/// ③ コマンド表示(左旋回・前進・右旋回)
struct CommandView: View {
    let onTurnLeft: () -> Void
    let onForward: () -> Void
    let onTurnRight: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            commandButton("左旋回", onTurnLeft)
            commandButton("前進", onForward)
            commandButton("右旋回", onTurnRight)
        }
    }

    private func commandButton(_ title: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Color.black)
                .foregroundColor(.white)
                .overlay(Rectangle().stroke(Color.white, lineWidth: 2))
        }
    }
}
