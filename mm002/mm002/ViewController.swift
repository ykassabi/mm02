//
//  ViewController.swift
//  mm002
//
//  Created by Yosef K on 2021-05-04.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBottom: UITextField!
    @IBOutlet weak var imageViewPhotoSelected: UIImageView!
    @IBOutlet weak var controlBarMenu: UIStackView!
    
//    var textOnTop : String
//    var textOnBottom :  String
//    var imageSelected : UIImage
    
    
    // Mark Style for text field
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.yellow ,
        NSAttributedString.Key.foregroundColor: UIColor.yellow,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  3.5
    ]

    
    // Mark Loading and View Events
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldTop.delegate = self
        textFieldBottom.delegate = self
        
        textFieldTop.defaultTextAttributes = memeTextAttributes
        textFieldBottom.defaultTextAttributes = memeTextAttributes
        
        textFieldTop.text = "TOP"
        textFieldBottom.text = "BOTTOM"
        textFieldTop.textAlignment = .center
        textFieldBottom.textAlignment = .center
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    // Mark Keyboard manipulation
    
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if textFieldBottom.isFirstResponder {
           view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if textFieldBottom.isFirstResponder {
           view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    
// MARK Text Field input
    

    @IBAction func textFieldPressed(_ sender: UITextField) {
        
        textFieldTop.endEditing(true)
        textFieldBottom.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textFieldTop.text == "TOP" {
            textFieldTop.text = ""
        }
        
        if textFieldBottom.isFirstResponder {
            textFieldBottom.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
//        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    
    }
    
    

    // MARK Image Picker
    
    @IBAction func pickAnImage(_ sender: Any) {
        let pickController = UIImagePickerController()
        pickController.delegate = self
        pickController.sourceType = .photoLibrary
        present(pickController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                shareButton.isEnabled = true
                    imagePickerView.image = image
        }else{
            shareButton.isEnabled = false
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {

         let imagePicker = UIImagePickerController()
         imagePicker.delegate = self
         present(imagePicker, animated: true, completion: nil)
     }
    
    
    
    
    
    // MARK Meme

    
    struct Meme {
           let topText: String
           let bottomText: String
           let originalImage: UIImage
           let memedImage: UIImage
       }
    
    func generateMemedImage(objectToToggle: UIStackView) -> UIImage {
            
            objectToToggle.isHidden = true
            
            // Render view to an image ViewController
            UIGraphicsBeginImageContext(self.view.frame.size)
            view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
            let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        
        objectToToggle.isHidden = false

            return memedImage
        }
       
    
       func save() {
        
        
           _ = Meme(
               topText:self.textFieldTop.text!,
               bottomText: self.textFieldBottom.text!,
               originalImage: self.imagePickerView.image!,
               memedImage: generateMemedImage(objectToToggle: controlBarMenu))
        
        self.resetViewPropreties()
       }
    
       @IBAction func Share(_ sender: Any) {
           let sharedImage = generateMemedImage(objectToToggle: controlBarMenu)
           // generate the meme
           let activityController = UIActivityViewController(activityItems:    [sharedImage], applicationActivities: nil)
           self.present(activityController, animated: true, completion: nil)
           
           activityController.completionWithItemsHandler = { (activity, success, items, error) in
                   self.save()
            
               }
            
       }
        
    func resetViewPropreties() {
        textFieldTop.text = ""
        textFieldBottom.text = ""
        imageViewPhotoSelected.image = nil
        
        shareButton.isEnabled = false
    }
}

extension UIViewController
{
    func setupToHideKeyboardOnTapOnView()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

