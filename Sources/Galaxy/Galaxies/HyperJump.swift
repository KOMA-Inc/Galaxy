import SwiftUI

private struct HyperJump: GalaxyElement {

    enum DrawingType {
        case line
        case circle
    }

    var position: CGPoint
    let radius: CGFloat
    var speed: CGFloat
    let maxSpeed: CGFloat
    let minSpeed: CGFloat
    let speedChange: CGFloat
    let color: Color
    let type: DrawingType

    static func random(in space: CGSize, type: DrawingType, color: Color) -> Self {
        HyperJump(
            position: CGPoint(
                x: .random(in: 0...space.width),
                y: .random(in: 0...space.height)
            ),
            radius: 2 + CGFloat.random(in: 0..<1),
            speed: .random(in: 2...5),
            maxSpeed: .random(in: 2...5),
            minSpeed: .random(in: 2...5),
            speedChange: .random(in: 2...5),
            color: color,
            type: type
        )
    }

    mutating func travel(in space: CGSize, timeElapsed: TimeInterval, frameTimeDelta: TimeInterval) {
        speed -= speedChange
        speed = max(minSpeed, min(speed, maxSpeed))
        let center = CGPoint(x: space.width / 2, y: space.height / 2)
        let angle = atan2(position.y - center.y, position.x - center.x)

        position.x += speed * cos(angle)
        position.y += speed * sin(angle)

        if position.x > space.width + 200
            || position.x < 0  - 200
            || position.y < 0  - 200
            || position.y > space.height + 200 {
            position.x = CGFloat.random(in: 0..<space.width)
            position.y = CGFloat.random(in: 0..<space.height)
        }
    }

    func draw(
        in space: CGSize,
        timeElapsed: TimeInterval,
        frameTimeDelta: TimeInterval,
        using context: GraphicsContext
    ) {
        switch type {

        case .line:
            let path = Path { path in
                path.move(to: position)
                let center = CGPoint(x: space.width / 2, y: space.height / 2)
                let weight: CGFloat = 5
                let pastPosition = CGPoint(
                    x: (weight * position.x + center.x) / (weight + 1),
                    y: (weight * position.y + center.y) / (weight + 1)
                )

                path.addLine(to: pastPosition)
            }
            context.stroke(path, with: .color(color))

        case .circle:
            let rect = CGRect(
                x: position.x,
                y: position.y,
                width: radius,
                height: radius
            )
            context.fill(Path(ellipseIn: rect), with: .color(color))
        }
    }
}

public struct HyperJumpCircleGalaxy: View {

    let elementsCount: Int
    let color: () -> Color

    public init(
        elementsCount: Int = 100,
        color: @autoclosure @escaping () -> Color = { .white }()
    ) {
        self.elementsCount = elementsCount
        self.color = color
    }

    public var body: some View {
        GalaxyView(count: elementsCount) { input -> HyperJump in
            HyperJump.random(in: input.spaceSize, type: .circle, color: color())
        }
    }
}

public struct HyperJumpLineGalaxy: View {

    let elementsCount: Int
    let color: () -> Color

    public init(
        elementsCount: Int = 100,
        color: @autoclosure @escaping () -> Color = { .white }()
    ) {
        self.elementsCount = elementsCount
        self.color = color
    }

    public var body: some View {
        GalaxyView(count: elementsCount) { input -> HyperJump in
            HyperJump.random(in: input.spaceSize, type: .line, color: color())
        }
    }
}
