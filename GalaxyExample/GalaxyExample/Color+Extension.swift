import SwiftUI

extension Color {
    static var random: Color {
        Color(
            uiColor: UIColor(
                red: .random(in: 0...1),
                green: .random(in: 0...1),
                blue: .random(in: 0...1),
                alpha: 1
            )
        )
    }
}
