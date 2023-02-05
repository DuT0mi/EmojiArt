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
                Color.yellow
                ForEach(document.emojis){emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .position(position(for:emoji, in: geometry))
                }
            }.onDrop(of: [.plainText],isTargeted: nil){
                providers,location in return drop(providers: providers, at: location, in: geometry)
            }
            
        }
    }
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy)->Bool{
        return providers.loadObjects(ofType: String.self){string in
            if let emoji = string.first, emoji.isEmoji{
                document.addEmoji(
                                String(emoji),
                                at: convertToEmojiCoordinates(location, in:geometry),
                                size: defaultEmojiFontsize
                                )
            }
        }
    }
    private func position(for emoji:EmojiArtModel.Emoji, in geometry: GeometryProxy)->CGPoint{
        convertFromCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertFromCoordinates(_ location: (x: Int,y: Int), in geometry: GeometryProxy)-> CGPoint{
        let center = geometry.frame(in: .local).center // Returns a CGReact but there is a func which is convert it to CGpoint : UtilityExtensions.swift
        return CGPoint(
            x: center.x + CGFloat(location.x),
            y: center.y + CGFloat(location.y)
        )
    }
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy)->(x: Int, y:Int) {
        let center = geometry.frame(in: .local).center // Returns a CGReact but there is a func which is convert it to CGpoint : UtilityExtensions.swift
        let location = CGPoint(
            x: location.x - center.x,
            y: location.y - center.y
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
