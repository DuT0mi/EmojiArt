//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 05..
//

import Foundation

extension EmojiArtModel{
    enum Background{
        case blank
        case url(URL)
        case imageData(Data) // etc: for JPEG
    }
}
