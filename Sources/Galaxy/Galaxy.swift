import SwiftUI

public protocol GalaxyElement {

    mutating func travel(
        in space: CGSize,
        timeElapsed: TimeInterval,
        frameTimeDelta: TimeInterval
    )

    func draw(
        in space: CGSize,
        timeElapsed: TimeInterval,
        frameTimeDelta: TimeInterval,
        using context: GraphicsContext
    )
}

public struct GalaxyElementCreationInput {
    public let id: Int
    public let spaceSize: CGSize
}

public struct GalaxyView<Symbols: View, Element: GalaxyElement>: View {

    @State private var start = Date.now
    @State private var lastUpdate = Date.now
    @State private var elements: [Element] = []

    private let count: Int
    private let elementBuilder: (GalaxyElementCreationInput) -> Element
    private let symbols: Symbols

    public init(
        count: Int,
        elementBuilder: @escaping (GalaxyElementCreationInput) -> Element,
        @ViewBuilder symbols: () -> Symbols
    ) {
        self.count = count
        self.elementBuilder = elementBuilder
        self.symbols = symbols()
    }

    public var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation) { timeline in
                Canvas { context, size in

                    draw(
                        time: start.distance(to: timeline.date),
                        timeDelta: lastUpdate.distance(to: timeline.date),
                        size: size,
                        context: context
                    )

                    DispatchQueue.main.async {

                        update(
                            time: start.distance(to: timeline.date),
                            timeDelta: lastUpdate.distance(to: timeline.date),
                            size: size
                        )

                        lastUpdate = timeline.date
                    }
                } symbols: {
                    symbols
                }
            }
            .onAppear {
                create(size: proxy.size)
            }
        }
    }

    private func draw(
        time: TimeInterval,
        timeDelta: TimeInterval,
        size: CGSize,
        context: GraphicsContext
    ) {
        elements.forEach { element in
            element.draw(in: size, timeElapsed: time, frameTimeDelta: timeDelta, using: context)
        }
    }

    private func update(time: TimeInterval, timeDelta: TimeInterval, size: CGSize) {
        elements.indices.forEach { idx in
            elements[idx].travel(in: size, timeElapsed: time, frameTimeDelta: timeDelta)
        }
    }

    private func create(size: CGSize) {
        elements = (0..<count).map {
            elementBuilder(GalaxyElementCreationInput(id: $0, spaceSize: size))
        }
    }
}

public extension GalaxyView where Symbols == EmptyView {
    init(
        count: Int,
        elementBuilder: @escaping (GalaxyElementCreationInput) -> Element
    ) {
        self.init(count: count, elementBuilder: elementBuilder, symbols: { EmptyView() } )
    }
}
