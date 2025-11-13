//
//  CameraView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 22/10/25.
//

import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    var onCapture: (UIImage?) -> Void
    
    /// Determina el tipo de fuente disponible para evitar crasheos en simulador o dispositivos sin cámara.
    private var availableSourceType: UIImagePickerController.SourceType {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            return .camera
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            return .photoLibrary
        } else {
            return .savedPhotosAlbum
        }
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = availableSourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage?) -> Void
        init(onCapture: @escaping (UIImage?) -> Void) { self.onCapture = onCapture }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            onCapture(image)
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCapture(nil)
            picker.dismiss(animated: true)
        }
    }
}
