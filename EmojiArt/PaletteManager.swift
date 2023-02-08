//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 08..
//

import SwiftUI

struct PaletteManager: View {
    // It is editing the palette store so we definetely need it -> @Enviroment
    @EnvironmentObject var store: PaletteStore
    
    
    var body: some View {
        NavigationView {
            List{
                ForEach(store.palettes){palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])){
                        VStack(alignment: .leading){
                            Text(palette.name)
                            Text(palette.emojis)
                        }
                    }
                }
            }
        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager().environmentObject(PaletteStore(named: "Preview"))
    }
}
