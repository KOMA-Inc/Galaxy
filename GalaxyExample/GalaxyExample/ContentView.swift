import Galaxy
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Falling Stars") {
                    NavigationLink("White Star") {
                        FallingStarsGalaxy()
                            .ignoresSafeArea()
                            .background(.black)
                    }

                    NavigationLink("Random Color Star") {
                        FallingStarsGalaxy(color: .random)
                            .ignoresSafeArea()
                            .background(.black)
                    }
                }

                Section("Hyper Jump") {
                    NavigationLink("White Circle") {
                        HyperJumpCircleGalaxy()
                            .ignoresSafeArea()
                            .background(.black)
                    }

                    NavigationLink("Pink / Purple Line") {
                        HyperJumpLineGalaxy(color: [Color.pink, Color.purple].randomElement()!)
                            .ignoresSafeArea()
                            .background(.black)
                    }
                }

                Section("Flying Participles") {
                    NavigationLink("Math") {
                        MathAnimatedCanvas(
                            colors: [
                                .primary400,
                                .primary500,
                                .primary600
                            ]
                        )
                        .frame(height: 250)
                    }

                    NavigationLink("Custom") {
                        FlyingParticiplesGalaxy(
                            systemNames: [
                                "flag.2.crossed",
                                "house",
                                "r.joystick",
                                "circle.hexagongrid.circle.fill",
                                "globe.americas",
                                "character.bubble",
                                "waveform.path.ecg.rectangle",
                                "face.smiling",
                                "crown",
                                "airpodspro"
                            ],
                            colors: [
                                .red,
                                .blue,
                                .purple,
                                .pink,
                                .yellow,
                                .teal,
                                .cyan
                            ]
                        )
                        .frame(height: 250)
                        .overlay {
                            Image(systemName: "face.smiling")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .foregroundStyle(.yellow)
                        }
                    }

                }

                Section("Matrix") {
                    NavigationLink("Matrix") {
                        Matrix()
                            .ignoresSafeArea()
                            .background(.black)
                    }
                }
            }
            .navigationTitle("Galaxy Examples")
        }
    }
}

#Preview {
    ContentView()
}
