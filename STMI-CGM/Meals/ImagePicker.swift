//
//  ImagePicker.swift
//  CGM-Meals
//
//  Created by iMac on 4/6/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

enum ActiveSheet {
    case first, second
}

final class ImagePickerCoordinator: NSObject {
    @Binding var image: UIImage?
    @Binding var takePhoto: Bool

    init(image: Binding<UIImage?>, takePhoto: Binding<Bool>) {
        _image = image
        _takePhoto = takePhoto
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var camera: Bool

    func makeCoordinator() -> ImagePickerCoordinator {
        ImagePickerCoordinator(image: $image, takePhoto: $camera)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.delegate = context.coordinator
        return pickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        switch self.camera {
        case true:
            uiViewController.sourceType = .camera
            uiViewController.showsCameraControls = true
        case false:
            uiViewController.sourceType = .photoLibrary
        }
        uiViewController.allowsEditing = false
    }
}

extension ImagePickerCoordinator: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageOriginal = info[.originalImage] as? UIImage {
            image = resizeImage(image: imageOriginal)
        }
        if let imageEdited = info[.editedImage] as? UIImage {
            image = imageEdited
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func resizeImage(image: UIImage) -> UIImage {
        let width = image.size.width
        let height = image.size.height
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

struct CameraButton: View{
    @Binding var showActionSheet: Bool //binding variables come from other places and are shared within the structs
    
    var body: some View {
        Button(action: {
            self.showActionSheet.toggle()
            print("camera button tapped")
        }){
            Image(systemName: "camera.circle.fill")
            .resizable()
            .imageScale(.large)
            
        }
    }
}



 
