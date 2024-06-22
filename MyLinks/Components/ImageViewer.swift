import SwiftUI

struct ImageViewer: View {
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var rotation: Angle = .zero
    @State private var lastRotation: Angle = .zero
    @State private var doubleTapScale: CGFloat = 2.0
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(scale)
            .rotationEffect(rotation)
            .offset(x: offset.width, y: offset.height)
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = lastScale * value
                        }
                        .onEnded { value in
                            lastScale = scale
                        },
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(width: lastOffset.width + value.translation.width, height: lastOffset.height + value.translation.height)
                        }
                        .onEnded { value in
                            lastOffset = offset
                        }
                )
            )
            .gesture(
                RotationGesture()
                    .onChanged { angle in
                        rotation = lastRotation + angle
                    }
                    .onEnded { angle in
                lastRotation = rotation
                }
            )
            .gesture(
                TapGesture(count: 2)
                    .onEnded {
                        if scale == 1.0 {
                            scale = doubleTapScale
                        } else {
                            scale = 1.0
                        }
                        lastScale = scale
                        withAnimation {
                            offset = .zero
                            lastOffset = .zero
                            rotation = .zero
                            lastRotation = .zero
                        }
                    }
            )
            .animation(.easeInOut, value: scale)
            .animation(.easeInOut, value: offset)
            .animation(.easeInOut, value: rotation)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
