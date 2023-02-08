//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 08..
//

import SwiftUI

struct PaletteEditor: View {
    @Binding private var palette: Palette = PaletteStore(named: "Text").palette(at: 2)
    
    var body: some View {
        Form{// For that cool looking
            TextField("Name",text: $palette.name)// Must to bind, coz the TextField can not work with that plain string
        }
        .frame(minWidth:300, minHeight: 350)
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor().previewLayout(.fixed(width: 300, height: 300))
    }
}
