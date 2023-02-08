//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 08..
//

import SwiftUI

struct PaletteChooser: View {
    var emojiFontSize: CGFloat = 40
    var emojiFont:Font {.system(size:emojiFontSize)}
    
    @EnvironmentObject var store: PaletteStore
    @State private var chosenPaletteIndex = 0
    
    var body: some View{
        HStack{
            paletteControlButton
            body(for: store.palette(at: chosenPaletteIndex))// id:1 - Vehicles, id:2 - Sport, id:3 - Faces
        }
        .clipped()
    }
    @ViewBuilder
    var contextMenu: some View{
        AnimatedActionButton(title: "New", systemImage: "plus"){
            store.insertPalette(named: "New",emojis: "",at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle"){
           chosenPaletteIndex = store.removePalette(at: chosenPaletteIndex)
        }
    }
    var paletteControlButton: some View{
        Button{
            chosenPaletteIndex = (chosenPaletteIndex + 1) % store.palettes.count
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
        .contextMenu {contextMenu }
    }
    func body(for palette: Palette)-> some View{
        HStack{
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        .id(palette.id)
        .transition(rollTransition)
    }
    var rollTransition: AnyTransition {
        AnyTransition.asymmetric(insertion: .offset(x: 0,y: emojiFontSize), removal: .offset(x: 0 , y: -emojiFontSize))
    }
}

struct ScrollingEmojisView: View {
    let emojis: String

    
    var body: some View{
        ScrollView(.horizontal){
            HStack{
                ForEach(emojis.removingDuplicateCharacters.map {String($0)}, id: \.self ) {emoji in
                    Text(emoji).onDrag{ NSItemProvider(object: emoji as NSString)}
                }
            }
        }
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser()
    }
}
