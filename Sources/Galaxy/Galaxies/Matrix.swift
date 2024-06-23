import SwiftUI

extension Font {
    static func matrix(size: CGFloat) -> Self {
        .custom("Matrix Code NFI", size: size)
    }
}

enum MatrixFont {
    static func registerFonts() {
        registerFont(bundle: .module, fontName: "Matrix Code NFI", fontExtension: "ttf")
    }

    private static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {
        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
              let provider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(provider) else {
            assertionFailure("Couldn't create font from filename: \(fontName).\(fontExtension)")
            return
        }

        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error)
    }
}

private let constants = "abcdefghijklmnopqrstuvwxyz1234567890"

private struct MatrixRainColumn: View {

    @State private var random = 0
    let size: CGFloat

    var body: some View {

        VStack {
            ForEach(0..<constants.count, id: \.self) { idx in
                let char = Array(constants)[randomIndex(index: idx)]
                Text(String(char))
                    .font(.matrix(size: size))
                    .foregroundStyle(.black)
            }
        }
        .onReceive(Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()) { _ in
            random = Int.random(in: 0..<constants.count)
        }
    }

    private func randomIndex(index: Int) -> Int {
        let min = 0
        let max = constants.count - 1

        return if index + random > max {
            if index - random < min {
                index
            } else {
                index - random
            }
        } else {
            index + random
        }
    }
}

private struct MatrixGalaxyElement: GalaxyElement {

    let idx: Int
    let width: CGFloat
    var offset: CGFloat

    private static func randomOffset(in space: CGSize) -> CGFloat {
        -space.height * .random(in: 1...3)
    }

    static func create(idx: Int, width: CGFloat, space: CGSize) -> Self {
        let columnsSize = space.width / width
        let realWidth = space.width / columnsSize
        return Self(
            idx: idx,
            width: realWidth,
            offset: randomOffset(in: space) + space.height / 2
        )
    }

    mutating func travel(
        in space: CGSize,
        timeElapsed: TimeInterval,
        frameTimeDelta delta: TimeInterval
    ) {
        offset += delta * 100
        if offset > space.height {
            offset = Self.randomOffset(in: space)
        }
    }

    func draw(
        in space: CGSize,
        timeElapsed: TimeInterval,
        frameTimeDelta: TimeInterval,
        using context: GraphicsContext
    ) {
        var context = context
        let x: CGFloat = width * CGFloat(idx)
        let y: CGFloat = 0

        if let view = context.resolveSymbol(id: idx) {

            context.clip(to:  Path(CGRect(x: x, y: offset, width: width, height: space.height)))

            context.draw(view, in: CGRect(x: x, y: 0, width: width, height: space.height))


            context.blendMode = .sourceAtop

            context.fill(
                Path(
                    CGRect(x: x, y: offset, width: width, height: space.height)),
                with: .linearGradient(
                    Gradient(colors: [Color.green.opacity(0.1), Color.green]),
                    startPoint: CGPoint(x: x, y: offset),
                    endPoint: CGPoint(x: x, y: space.height)
                )
            )
        }
    }
}

public struct Matrix: View {

    let size: CGFloat

    public init(size: CGFloat = 25) {
        self.size = size
        MatrixFont.registerFonts()
    }

    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let count: Int = Int(size.width / self.size)
            let freeSpace = size.width - CGFloat(count) * self.size

            GalaxyView(count: count) { input -> MatrixGalaxyElement in
                MatrixGalaxyElement.create(idx: input.id, width: self.size, space: input.spaceSize)
            } symbols: {
                ForEach(0..<count, id: \.self) { idx in
                    MatrixRainColumn(size: self.size)
                        .frame(width: self.size)
                        .id(idx)
                }
            }
            .padding(.horizontal, freeSpace / 2)
        }
    }
}

#Preview {
    Matrix(size: 25)
}
