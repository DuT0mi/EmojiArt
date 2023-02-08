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
            .toolbar{
                ToolbarItem {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading){
                    if presentationMode.wrappedValue.isPresented, UIDevice.current.userInterfaceIdiom != .pad {
                        Button("Close"){
                            // it is not neccessary on iPad (the User can tap anywhere else to leave), but on iPhone (.phone) it is
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
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
