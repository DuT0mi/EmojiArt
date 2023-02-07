//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 05..
//

import Foundation

extension EmojiArtModel{
    enum Background:Equatable,Codable{

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
        enum CodingKeys:String, CodingKey { // CodingKey is mainly just to mark it to keyedBy
            case url = "theURL"
            case imageData
            // rawValue <- :String
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let url = try? container.decode(URL.self, forKey: .url){
                self = .url(url)
            } else if let imageData = try? container.decode(Data.self, forKey: .imageData){
                self = .imageData(imageData)
            } else {
                self = .blank
            }
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self{
            case .url(let url): try container.encode(url, forKey: .url)
            case .imageData(let data): try container.encode(data, forKey: .imageData)
            case .blank: break
            }
        }
        
    }
}
