//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 05..
//


// ViewModel


import SwiftUI

class EmojiArtDocument: ObservableObject {
    
    @Published private(set) var emojiArt: EmojiArtModel{
        didSet{
            autosave()
            if emojiArt.background != oldValue.background{
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    private struct Autosave{
        static let filename = "Autosaved.emojiart"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first // for iOS, for MAC the mask and .first may be other, because there could be more there
            return documentDirectory?.appendingPathComponent(filename)
            
        }
    }
    private func autosave(){
        if let url = Autosave.url{
            save(to: url)
        }
    }
    private func save(to url:URL){// file URL
        let thisFunction = "\(String(describing: self)).\(#function)"
        do{
            let data: Data = try emojiArt.json()
            print("\(thisFunction) json = \(String(data:data, encoding: .utf8) ?? "nil" )")
            try data.write(to: url)
            print("\(thisFunction) success!")
        } catch let encodingError where encodingError is EncodingError{
            print("\(thisFunction) couldn't EmojiArt as JSON because \(encodingError.localizedDescription)") // Not for the user :D
        }
            catch let error {
           // print("EmojiArtDocument.save(to:) error = \(error)") // Also we would get <error variable> without let error
            // same as
            print("\(thisFunction) error = \(error)")
        }
    }
    
    init(){
        
        emojiArt = EmojiArtModel()
       // emojiArt.addEmoji("🐋", at: (-200,-100), size: 80) // 0,0 at the left top
       // emojiArt.addEmoji("🦣", at: (50,100), size: 40)
    }
    var emojis: [EmojiArtModel.Emoji] {emojiArt.emojis}
    var background: EmojiArtModel.Background {emojiArt.background}
    
    @Published var backgroundImage:UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus{
        case idle
        case fetching
    }
    private func fetchBackgroundImageDataIfNecessary(){
        backgroundImage = nil
        switch emojiArt.background{
        case .url(let url):
            // fetch the url
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async {// UI only in the main
                    [weak self] in // cuz we do not want to live in the memory
                    if self?.emojiArt.background == EmojiArtModel.Background.url(url){ // If it is the User want (not the user wanted about 10 min ago)
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil{
                            self?.backgroundImage = UIImage(data:imageData!)
                        }
                    }
                }
            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:break
        }
    }
    
    // MARK: - Intent(s)
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
        print("background set to \(background)")
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}
