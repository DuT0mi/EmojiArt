//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 05..
//

import SwiftUI

@main
struct EmojiArtApp: App {
    var body: some Scene {
        let document = EmojiArtDocument()
        let paletteStore = PaletteStore(named: "Default")
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
