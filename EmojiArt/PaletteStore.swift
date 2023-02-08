//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 07..
//

import SwiftUI

// ViewModel too
struct Palette: Identifiable,Codable,Hashable{
    var name:String
    var emojis: String
    var id: Int
    // for adding a palette to the palette storage
    fileprivate init(name: String, emojis: String, id: Int) {
        self.name = name
        self.emojis = emojis
        self.id = id
    }
}

class PaletteStore: ObservableObject {
    let name:String
    @Published var palettes = [Palette](){ // the model
        didSet{
            storeInUserDefaults()
        }
    }
    private var userDefaultsKey:String {
        "PaletteStore:" + name
    }
    private func storeInUserDefaults(){
        // More elegant
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes),forKey: userDefaultsKey)
    }
    private func restoreFromUserDefaults(){
        // Much nicer
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedPalettes = try? JSONDecoder().decode(Array<Palette>.self, from: jsonData){
            palettes = decodedPalettes
        }
        
        
    }
    init(named name: String){
        self.name = name
        restoreFromUserDefaults()
        if palettes.isEmpty{
            print("using built-in palettes")
            insertPalette(named: "Vehicles", emojis: "🚗🚕🚙🚌🚎🏎️🚓🚜🚛🚚🛻🚐🚒🚑")
            insertPalette(named: "Sport",emojis: "⚽️🏀🏈⚾️🥎🥎🏐🎾🪀🏓🎱🥏🏉")
            insertPalette(named: "Faces",emojis: "😀😃😄😁😆🥹😅🙂😇😊☺️🥲🤣😂🙃😉😌😍🥰😘😗🤪😜😝😛😋😚😙")
        }else{
            print("successfully loaded palettes from UserDefaults \(palettes)")
        }
    }
    //MARK: - Intent(s)
    
    func palette(at index: Int)-> Palette{
        let safeIndex = min(max(index,0),palettes.count - 1)
        return palettes[safeIndex]
    }
    @discardableResult
    func removePalette(at index:Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index){
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    
    func insertPalette(named name: String, emojis: String? = nil, at index: Int = 0){
        let unique = (palettes.max(by: {$0.id < $1.id})?.id ?? 0) + 1
        let palette = Palette(name: name, emojis: emojis ?? "", id: unique)
        let safeIndex = min(max(index,0),palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
    
}
