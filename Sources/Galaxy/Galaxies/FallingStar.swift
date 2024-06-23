import SwiftUI

private struct FallingStar: GalaxyElement {

    var position: CGPoint
    let velocity: CGFloat
    let color: Color

    static func random(in space: CGSize, color: Color) -> Self {
        FallingStar(
            position: CGPoint(
                x: .random(in: 0...space.width),
                y: .random(in: 0...space.height)
            ),
            velocity: .random(in: 2...5),
            color: color
        )
    }

    mutating func travel(
        in space: CGSize,
        timeElapsed _: TimeInterval,
        frameTimeDelta _: TimeInterval
    ) {
        position.y += velocity
        if position.y > space.height {
            position = CGPoint(
                x: .random(in: 0...space.width),
                y: 0
            )
        }
    }

    func draw(
        in space: CGSize,
        timeElapsed _: TimeInterval,
        frameTimeDelta _: TimeInterval,
        using context: GraphicsContext
    ) {
        let rect = CGRect(
            x: position.x,
            y: position.y,
            width: 2,
            height: 2
        )
        context.fill(Path(ellipseIn: rect), with: .color(color))
    }
}

public struct FallingStarsGalaxy: View {

    let starsCount: Int
    let color: () -> Color

    public init(
        starsCount: Int = 100,
        color: @autoclosure @escaping () -> Color = { .white }()
    ) {
        self.starsCount = starsCount
        self.color = color
    }

    public var body: some View {
        GalaxyView(count: starsCount) { input -> FallingStar in
            FallingStar.random(in: input.spaceSize, color: color())
        }
    }
}
