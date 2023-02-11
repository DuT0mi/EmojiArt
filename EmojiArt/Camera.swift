//
//  Camera.swift
//  EmojiArt
//
//  Created by Dudas Tamas Alex on 2023. 02. 11..
//

// View

import SwiftUI

struct Camera: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(handlePickedImage: handlePickedImage)
    }
    
    var handlePickedImage: (UIImage?) -> Void
    
    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    func makeUIViewController(context: Context) -> UIImagePickerController{
        let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.delegate =  context.coordinator       // callback when a photo was taken
        return picker
    }
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate{// Class coz UIKit OO based
        var handlePickedImage: (UIImage?) -> Void
        
        init(handlePickedImage:@escaping (UIImage?) -> Void){
            self.handlePickedImage = handlePickedImage
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            handlePickedImage(nil)
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            handlePickedImage((info[.editedImage] ?? info[.originalImage]) as? UIImage)
        }
    }
    
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context){
        // nothing to do
    }
}
