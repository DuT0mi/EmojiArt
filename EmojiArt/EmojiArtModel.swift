//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 05..
//

import Foundation


struct EmojiArtModel {

    var background = Background.blank
    var emojis = [Emoji]()
    private var uniqeEmojiId = 0
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int),size: Int)-> Void{
        uniqeEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size,id: uniqeEmojiId))
    }
    
    init() {}
    struct Emoji: Identifiable,Hashable{
        let text: String
        var x: Int
        var y: Int
        var size: Int
        let id:Int
        
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
}
