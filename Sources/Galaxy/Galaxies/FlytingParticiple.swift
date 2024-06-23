import SwiftUI
import simd

extension SIMD2 where Scalar == Double {
    func distance(to other: SIMD2) -> Double {
        simd.distance(self, other)
    }

    func normalized() -> SIMD2 {
        simd.normalize(self)
    }
}

struct Particle: GalaxyElement {

    let startPosition: SIMD2<Double>
    let endPosition: SIMD2<Double>
    var position: SIMD2<Double>
    var speed: Double
    var opacity: Double
    let tag: String
    let color: Color
    let size: CGFloat

    static func create(tag: String, color: Color) -> Self {
        let start = startPosition(firstTime: true)

        return .create(start: start, tag: tag, color: color)
    }

    private static func create(start: SIMD2<Double>, tag: String, color: Color) -> Self {
        let end = endPosition(for: start)

        return Self(
            startPosition: start,
            endPosition: end,
            position: start,
            speed: .random(in: 0.1...0.4),
            opacity: 0,
            tag: tag,
            color: color,
            size: .random(in: 8...10)
        )
    }

    static func reborn(tag: String, color: Color) -> Self {
        let start = startPosition(firstTime: false)
        return .create(start: start, tag: tag, color: color)
    }

    mutating func travel(
        in _: CGSize,
        timeElapsed _: TimeInterval,
        frameTimeDelta delta: TimeInterval
    ) {
        let totalDistance = endPosition.distance(to: startPosition)
        let currentDistance = startPosition.distance(to: position)
        let progress = currentDistance / totalDistance
        if progress <= 0.3 {
            opacity = 3 * progress
        } else {
            opacity = (1 - progress + 0.3)
        }
        let trajectory = (endPosition - SIMD2(0.5, 0.5))
        var offset: SIMD2<Double> = [sin(progress * .pi / 2), cos(progress * .pi / 2)]
        if trajectory.x < 0 {
            offset.x *= -1
        }
        if trajectory.y < 0 {
            offset.y *= -1
        }
        position += (trajectory + offset * speed) * delta * speed
        if position.x < 0 || position.x > 1 || position.y < 0 || position.y > 1 {
            self = Particle.reborn(tag: tag, color: color)
        }
    }

    func draw(
        in space: CGSize,
        timeElapsed: TimeInterval,
        frameTimeDelta: TimeInterval,
        using context: GraphicsContext
    ) {
        var context = context
        let x = position.x * space.width
        let y = position.y * space.height

        if let view = context.resolveSymbol(id: tag) {
            context.addFilter(.colorMultiply(color))
            context.opacity = opacity
            context.draw(view, in: CGRect(x: x, y: y, width: self.size, height: self.size))
        }
    }

    private func distanceFromCenter() -> Double {
        let center = SIMD2<Double>(x: 0.5, y: 0.5)
        return sqrt(pow(position.x - center.x, 2) + pow(position.y - center.y, 2))
    }

    private enum Edge: CaseIterable {
        case leading, trailing, top, bottom

        var startPosition: SIMD2<Double> {
            switch self {
            case .leading:
                [.random(in: 0.45...0.5), .random(in: 0.45...0.55)]
            case .trailing:
                [.random(in: 0.5...0.55), .random(in: 0.45...0.55)]
            case .top:
                [.random(in: 0.45...0.55), .random(in: 0.45...0.5)]
            case .bottom:
                [.random(in: 0.45...0.55), .random(in: 0.5...0.55)]
            }
        }

        static var random: Self {
            allCases.randomElement()!
        }

    }

    private static func startPosition(firstTime: Bool) -> SIMD2<Double> {
        if firstTime {
            [.random(in: 0...1), .random(in: 0...1)]
        } else {
            Edge.random.startPosition
        }
    }

    private static func endPosition(for start: SIMD2<Double>) -> SIMD2<Double> {
        let diffX = abs(0.5 - start.x)
        let diffY = abs(0.5 - start.y)

        let finalX: Double
        let finalY: Double
        if diffX == diffY {
            finalX = start.x < 0.5 ? 0 : 1
            finalY = start.y < 0.5 ? 0 : 1
        } else if diffX < diffY {
            finalY = start.y < 0.5 ? 0 : 1
            let l = 0.5 * abs(0.5 - start.x) / abs(0.5 - start.y)
            finalX = start.x < 0.5 ? 0.5 - l : 0.5 + l
        } else {
            finalX = start.x < 0.5 ? 0 : 1
            let l = 0.5 * abs(0.5 - start.y) / abs(0.5 - start.x)
            finalY = start.y < 0.5 ? 0.5 - l : 0.5 + l
        }

        let end: SIMD2<Double> = [finalX, finalY]

        return end
    }
}

public struct FlyingParticiplesGalaxy: View {

    let participlesCount: Int
    let systemNames: [String]
    let colors: [Color]

    public init(participlesCount: Int = 100, systemNames: [String], colors: [Color]) {
        self.participlesCount = participlesCount
        self.systemNames = systemNames
        self.colors = colors
    }

    public var body: some View {
        GalaxyView(count: participlesCount) { input -> Particle in
            Particle.create(
                tag: systemNames.randomElement()!,
                color: colors.randomElement()!
            )
        } symbols: {
            ForEach(systemNames, id: \.self) { systemName in
                Image(systemName: systemName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFill()
                    .foregroundStyle(.white)
                    .tag(systemName)
            }
        }
    }
}

public struct MathAnimatedCanvas: View {

    let colors: [Color]

    public init(colors: [Color]) {
        self.colors = colors
    }

    public var body: some View {
        FlyingParticiplesGalaxy(
            participlesCount: 100,
            systemNames: [
                "x.squareroot",
                "sum",
                "percent",
                "function",
                "plusminus",
                "divide",
                "plus.forwardslash.minus",
                "angle",
                "compass.drawing",
                "pencil.and.outline",
                "triangle"
            ],
            colors: colors
        )
    }
}
