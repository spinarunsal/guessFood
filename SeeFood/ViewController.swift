//
//  ViewController.swift
//  SeeFood
//
//  Created by Pinar Unsal on 2018-11-18.
//  Copyright © 2018 S Pinar Unsal. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    //create imagePicker object
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        //bring up ImagePicker that contains the camera module
        //allow take an image using rear or front camera
        imagePicker.sourceType = .camera
        //imagePicker.sourceType = .photoLibrary
        
        imagePicker.allowsEditing = false
    }
    
    //didFinishPickingMediaWithInfo
    //tells the delagate user is picked an image or video
    //time point that we pick the image
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         //hold the selected image info[]
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            // change uiimage to ciimage
            guard  let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage into CIImage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            print(results)
            if let firstResult = results.first {
                if firstResult.identifier.contains("banana") {
                    self.navigationItem.title = "Yayy Banana!"
                } else {
                    self.navigationItem.title = "Not Banana!"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}

