//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 05..
//


// ViewModel


import SwiftUI
import Combine
import UniformTypeIdentifiers

extension UTType {
    static let emojiart:UTType = UTType(exportedAs: "com.dutomi.emojiart")
}


class EmojiArtDocument: ReferenceFileDocument {
    static var readableContentTypes = [UTType.emojiart]
    static var writableContentTypes = [UTType.emojiart]
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArtModel(json: data)
            fetchBackgroundImageDataIfNecessary()
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        return try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: snapshot)
    }
    // ReferenceFileDocument also implements ObservableObject, so dont need to write it down
    typealias Snapshot = Data
    
    @Published private(set) var emojiArt: EmojiArtModel{
        didSet{
            if emojiArt.background != oldValue.background{
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    init(){
        emojiArt = EmojiArtModel()
        // blank document
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
            backgroundImageFetchCancellabe?.cancel() // For cancelling the previous one(s) (like we did in the old version, checking the old one
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map{(data,URLResponse) in UIImage(data: data) }
                .replaceError(with: nil) // for cancellabe
                .receive(on: DispatchQueue.main)
            
            // Lifetime of a scubcriber attached to a var
            backgroundImageFetchCancellabe = publisher
                .sink{ [weak self] image in
                    self?.backgroundImage = image
                    self?.backgroundImageFetchStatus = (image != nil ) ? .idle : .failed(url)
                }
            
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:break
        }
    }
    
    // MARK: - Intent(s)
    func setBackground(_ background: EmojiArtModel.Background, undoManager:UndoManager?) {
        undoablyPerform(operation: "Set background", with: undoManager){
            emojiArt.background = background
        }
        print("background set to \(background)")
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat, undoManager:UndoManager?) {
        undoablyPerform(operation: "Add \(emoji)", with: undoManager){
            emojiArt.addEmoji(emoji, at: location, size: Int(size))
        }
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize, undoManager:UndoManager?) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            undoablyPerform(operation: "Move", with: undoManager){
                emojiArt.emojis[index].x += Int(offset.width)
                emojiArt.emojis[index].y += Int(offset.height)
            }
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat, undoManager:UndoManager?) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            undoablyPerform(operation: "Scale", with: undoManager){
                emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
            }
        }
    }
    // MARK: - Undo
    
    private func undoablyPerform(operation:String, with undoManager: UndoManager? = nil,doit: ()-> Void){
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self){myself in
            myself.undoablyPerform(operation: operation,with: undoManager){
                myself.emojiArt = oldEmojiArt
            }// re-do
        }
        undoManager?.setActionName(operation)
    }
}
