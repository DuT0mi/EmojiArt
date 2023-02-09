//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 05..
//


// ViewModel


import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject {
    
    @Published private(set) var emojiArt: EmojiArtModel{
        didSet{
            scheduleAutosave()
            if emojiArt.background != oldValue.background{
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    private var autosaveTimer: Timer?
    
    private func scheduleAutosave(){
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) {_ in
            self.autosave()
        }
    }
    private struct Autosave{
        static let filename = "Autosaved.emojiart"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first // for iOS, for MAC the mask and .first may be other, because there could be more there
            return documentDirectory?.appendingPathComponent(filename)
            
        }
        static let coalescingInterval = 5.0
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
        if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(url: url){
            emojiArt = autosavedEmojiArt
            fetchBackgroundImageDataIfNecessary()
            // autoloading if it available
        }
        emojiArt = EmojiArtModel()
       // emojiArt.addEmoji("🐋", at: (-200,-100), size: 80) // 0,0 at the left top
       // emojiArt.addEmoji("🦣", at: (50,100), size: 40)
    }
    var emojis: [EmojiArtModel.Emoji] {emojiArt.emojis}
    var background: EmojiArtModel.Background {emojiArt.background}
    
    @Published var backgroundImage:UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
    private var backgroundImageFetchCancellabe: AnyCancellable?
    
    
    private func fetchBackgroundImageDataIfNecessary(){
        backgroundImage = nil
        switch emojiArt.background{
        case .url(let url):
            // fetch the url
            backgroundImageFetchStatus = .fetching
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map{(data,URLResponse) in UIImage(data: data) }
                .replaceError(with: nil) // for cancellabe
            
            backgroundImageFetchCancellabe = publisher
                .assign(to: \EmojiArtDocument.backgroundImage, on:self)
            
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
