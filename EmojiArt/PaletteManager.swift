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
    @Environment (\.colorScheme) var colorScheme
    @Environment (\.presentationMode) var presentationMode
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes){palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])){
                        VStack(alignment: .leading){
                            Text(palette.name)
                              //  .font(colorScheme == .dark ? .largeTitle : .caption)
                              //  .font(editMode == .active ? .largeTitle : .caption)
                            Text(palette.emojis)
                        }
                        .gesture(editMode == .active ? tap : nil)
                    }
                }.onDelete{indexSet in
                    store.palettes.remove(atOffsets: indexSet)
                }
                .onMove{ IndexSet,newOffSet in
                    store.palettes.move(fromOffsets: IndexSet, toOffset: newOffSet)
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
           // .environment(\.colorScheme, .dark)
            .dismissable {
                presentationMode.wrappedValue.dismiss()
            }
            .toolbar{
                ToolbarItem {
                    EditButton()
                }
            }
            .environment(\.editMode, $editMode) // Now the EditButton and the whole List{} looking for that editMode
        }
    }
    var tap: some Gesture {
        TapGesture().onEnded {  }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .environmentObject(PaletteStore(named: "Preview"))
            
    }
}
