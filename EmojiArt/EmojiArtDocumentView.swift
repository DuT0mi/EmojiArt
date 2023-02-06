//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 05..
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    let defaultEmojiFontsize: CGFloat = 40
    var body: some View {
        VStack(spacing: 0){
            documentBody
            palette
        }
    }
    var documentBody: some View{
        GeometryReader{ geometry in
            ZStack{
                Color.white.overlay{
                    OptionalImage(uiImage: document.backgroundImage) // In the extension
                        .scaleEffect(zoomScale)
                        .position(convertFromCoordinates((0,0), in: geometry))// 0,0 is the middle in that (converted) coordinate system
                }
                .gesture(doubleTapToZoom(in:geometry.size))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(2)
                }else {
                ForEach(document.emojis){emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .scaleEffect(zoomScale)
                        .position(position(for:emoji, in: geometry))
                }
             }
            }.clipped()
            .onDrop(of: [.plainText, .url, .image],isTargeted: nil){
                providers,location in return drop(providers: providers, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            // That's the way of adding multiple gestures
        }
    }
    private func doubleTapToZoom(in size: CGSize)->some Gesture{
        TapGesture(count: 2)
            .onEnded{
                withAnimation{
                    zoomToFit(document.backgroundImage,in: size)
                }
            }
    }
    
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffSet: CGSize = CGSize.zero
    
    private var panOffsetSize:CGSize {
       (steadyStatePanOffset + gesturePanOffSet) * zoomScale // Added extension to the CGSize (func + )
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffSet){latestDragGestureValue, gesturePanOffSet, _ in
                // In that enviroment (gesturePanOffSet) is an In-Out version of the gesture's version
                gesturePanOffSet = latestDragGestureValue.translation / zoomScale
            }
            .onEnded{ finalDragGestureValue in
            steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
        }
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale){ latestGestureScale, gestureZoomScale, transaction in
                // In that enviroment (gestureZoomScale) is an In-Out version of the gesture's version
                gestureZoomScale = latestGestureScale
                
            }
            .onEnded{gestureScaleAtEnd in
                steadyStateZoomScale *= gestureScaleAtEnd
                
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize){
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0{
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStateZoomScale = min(hZoom,vZoom)
        }
    }
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy)->Bool{
        var found = providers.loadObjects(ofType: URL.self ){url in
            document.setBackground(EmojiArtModel.Background.url(url.imageURL)) // in UtilityExtension.swift
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self ){image in
                if let data = image.jpegData(compressionQuality: 1.0){
                    document.setBackground(.imageData(data))
                }
            }
        }
        if !found {
            found =  providers.loadObjects(ofType: String.self){string in
                if let emoji = string.first, emoji.isEmoji{
                    document.addEmoji(
                        String(emoji),
                        at: convertToEmojiCoordinates(location, in:geometry),
                        size: defaultEmojiFontsize / zoomScale
                    )
                }
            }
        }
        return found
    }
    private func position(for emoji:EmojiArtModel.Emoji, in geometry: GeometryProxy)->CGPoint{
        convertFromCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertFromCoordinates(_ location: (x: Int,y: Int), in geometry: GeometryProxy)-> CGPoint{
        let center = geometry.frame(in: .local).center // Returns a CGReact but there is a func which is convert it to CGpoint : UtilityExtensions.swift
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale,
            y: center.y + CGFloat(location.y) * zoomScale
        )
    }
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy)->(x: Int, y:Int) {
        let center = geometry.frame(in: .local).center // Returns a CGReact but there is a func which is convert it to CGpoint : UtilityExtensions.swift
        let location = CGPoint(
            x: (location.x - center.x) / zoomScale,
            y: (location.y - center.y) / zoomScale
        )
        return (Int(location.x),Int(location.y))
    }
    private func fontSize(for emoji: EmojiArtModel.Emoji)->CGFloat{
        CGFloat(emoji.size)
    }
    var palette: some View{
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size:defaultEmojiFontsize))
    }
    
    
    
    
    
    let testEmojis = "😀😷🦠💉👻👀🐶🌲🌎🌞🔥🍎⚽️🚗🚓🚲🛩🚁🚀🛸🏠⌚️🎁🗝🔐❤️⛔️❌❓✅⚠️🎶➕➖🏳️"
}

struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View{
        ScrollView(.horizontal){
            HStack{
                ForEach(emojis.map {String($0)}, id: \.self ) {emoji in
                    Text(emoji).onDrag{ NSItemProvider(object: emoji as NSString)}
                }
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
