//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 08..
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var palette: Palette // cant be private
    
    var body: some View {
        Form{// For that cool looking
            nameSection
            addEmojisSection
            removeEmojiSection
        }
        .navigationTitle("Edit \(palette.name)")
        .frame(minWidth:300, minHeight: 350)
    }
    var nameSection: some View{
        Section(header:Text("Name")){
            TextField("Name",text: $palette.name)// Must to bind, coz the TextField can not work with that plain string
        }
    }
    @State private var emojisToAdd = ""
    var addEmojisSection: some View {
        Section(header: Text("Add emojis")){
            TextField("",text: $emojisToAdd)
                .onChange(of: emojisToAdd){emojis in
                    addEmojis(emojis)
                }
        }
    }
    func addEmojis(_ emojis:String){
        withAnimation{
            palette.emojis = (emojis + palette.emojis)
                .filter {$0.isEmoji}
                .removingDuplicateCharacters
        }
    }
    var removeEmojiSection: some View {
        Section(header: Text("Remove Emoji")) {
            let emojis = palette.emojis.removingDuplicateCharacters.map { String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll(where: { String($0) == emoji })
                            }
                        }
                }
            }
            .font(.system(size: 40))
        }
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor(palette: .constant(PaletteStore(named: "Preview").palette(at: 4)))// constant bindig, coz we do not have any one of it
            .previewLayout(.fixed(width: 300, height: 300))
    }
}
