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
        
        var url: URL?{
            switch self{
            case .url(let url): return url
            default: return nil
            }
        }
        
        var imageData: Data?{
            switch self{
            case .imageData(let data): return data
            default:return nil
            }
        }
    }
}
