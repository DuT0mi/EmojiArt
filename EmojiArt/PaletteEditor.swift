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
            TextField("Name",text: $palette.name)// Must to bind, coz the TextField can not work with that plain string
        }
        .frame(minWidth:300, minHeight: 350)
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        Text("Fix me")
      //  PaletteEditor()
            .previewLayout(.fixed(width: 300, height: 300))
    }
}
