//
//  ProfileViewController.swift
//  RunTracker
//
//  Created by Sergio Viudes Carbonell on 11/03/2020.
//  Copyright © 2020 Sergio Viudes Carbonell. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makePhotoRounded()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = ["public.image"]
        
        photoImageView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(onPhotoClicked)) )
        genderImageView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(onGenderImageClicked)) )
        nameLabel.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(onNameLabelClicked)) )
        ageLabel.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(onAgeLabelClicked)) )
        weightLabel.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(onWeightLabelClicked)) )
        heightLabel.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(onHeightLabelClicked)) )
        genderLabel.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(onGenderLabelClicked)) )
        
        refreshUi(true)
    }
    
    private func makePhotoRounded() {
        self.photoImageView.layer.cornerRadius = self.photoImageView.frame.size.width / 2
        self.photoImageView.clipsToBounds = true
        photoImageView.contentMode = .scaleAspectFill
    }
    
    private func refreshUi(_ loadPhoto : Bool = false) {
        let name = Settings.getProfileName()
        let age = Settings.getProfileAge()
        let weight = Settings.getProfileWeight()
        let height = Settings.getProfileHeight()
        let gender = Settings.getProfileGender()
        
        nameLabel.text = name == "" ? "Escribe aquí tu nombre" : name
        ageLabel.set(html: age == 0 ? "Edad: _______" : "Edad: <b>\(String(age)) años</b>")
        weightLabel.set(html: weight == 0 ? "Peso: _______" : "Peso: <b>\(String(weight)) kg</b>")
        heightLabel.set(html: height == 0 ? "Altura: _______" : "Altura: <b>\(String(height)) cm</b>")
        genderLabel.text = gender == Gender.UNDEFINED ? "Sexo: _______" : "Sexo: "
        genderImageView.isHidden = gender == Gender.UNDEFINED
        genderImageView.image = UIImage.init(named: gender == Gender.FEMALE ? "icon_female" : "icon_male" )
        
        if loadPhoto, let photo = getSavedImage() {
            photoImageView.image = photo
        }
    }
    
    @objc private func onNameLabelClicked(sender: UITapGestureRecognizer) {
        promptName()
    }
    
    @objc private func onAgeLabelClicked(sender: UITapGestureRecognizer) {
        promptAge()
    }
    
    @objc private func onWeightLabelClicked(sender: UITapGestureRecognizer) {
        promptWeight()
    }
    
    @objc private func onHeightLabelClicked(sender: UITapGestureRecognizer) {
        promptHeight()
    }
    
    @objc private func onGenderLabelClicked(sender: UITapGestureRecognizer) {
        changeGender()
    }
    
    @objc private func onGenderImageClicked(sender: UITapGestureRecognizer) {
        changeGender()
    }
    
    @objc private func onPhotoClicked(sender: UITapGestureRecognizer) {
        promptPhoto()
    }
    
    private func promptName() {
        let regex = try! NSRegularExpression(pattern: ".{1,30}")
        let rule = TextValidationRule.regularExpression(regex)
        
        let alert = UIAlertController(title: "Nombre",
                                      message: "¿Cómo te llamas?",
                                      cancelButtonTitle: "Cancelar",
                                      okButtonTitle: "Aceptar",
                                      validate: rule,
                                      textFieldConfiguration: nil,
                                      onCompletion: { returnValue in
                                        switch returnValue {
                                        case .ok(let stringValue):
                                            Settings.setProfileName(stringValue)
                                            self.refreshUi()
                                            break
                                        case .cancel:
                                            break;
                                        }
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func promptAge() {
        let regex = try! NSRegularExpression(pattern: "[1-9][0-9]|[3-9]")
        let rule = TextValidationRule.regularExpression(regex)
        
        let alert = UIAlertController(title: "Edad",
                                      message: "¿Cuántos años tienes?",
                                      cancelButtonTitle: "Cancelar",
                                      okButtonTitle: "Aceptar",
                                      validate: rule,
                                      textFieldConfiguration: { textField in
                                        textField.keyboardType = UIKeyboardType.numberPad
        }, onCompletion: { returnValue in
            
            switch returnValue {
            case .ok(let stringValue):
                Settings.setProfileAge(value: Int(stringValue)!)
                self.refreshUi()
                break
            case .cancel:
                break;
            }
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func promptWeight() {
        let regex = try! NSRegularExpression(pattern: "[1][0-9][0-9]|[1-9][0-9]")
        let rule = TextValidationRule.regularExpression(regex)
        
        let alert = UIAlertController(title: "Peso",
                                      message: "¿Cuántos kg pesas?",
                                      cancelButtonTitle: "Cancelar",
                                      okButtonTitle: "Aceptar",
                                      validate: rule,
                                      textFieldConfiguration: { textField in
                                        textField.keyboardType = UIKeyboardType.numberPad
        }, onCompletion: { returnValue in
            
            switch returnValue {
            case .ok(let stringValue):
                Settings.setProfileWeight(value: Int(stringValue)!)
                self.refreshUi()
                break
            case .cancel:
                break;
            }
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func promptHeight() {
        let regex = try! NSRegularExpression(pattern: "[1-2][0-9][0-9]")
        let rule = TextValidationRule.regularExpression(regex)
        
        let alert = UIAlertController(title: "Altura",
                                      message: "¿Cuántos cm mides?",
                                      cancelButtonTitle: "Cancelar",
                                      okButtonTitle: "Aceptar",
                                      validate: rule,
                                      textFieldConfiguration: { textField in
                                        textField.keyboardType = UIKeyboardType.numberPad
        }, onCompletion: { returnValue in
            
            switch returnValue {
            case .ok(let stringValue):
                Settings.setProfileHeight(value: Int(stringValue)!)
                self.refreshUi()
                break
            case .cancel:
                break;
            }
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func changeGender() {
        let gender = Settings.getProfileGender()
        Settings.setProfileGender(gender == Gender.FEMALE ? Gender.MALE : Gender.FEMALE)
        refreshUi()
    }
    
    private func promptPhoto() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Cámara") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Carrete") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Fotos") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = photoImageView
            alertController.popoverPresentationController?.sourceRect = photoImageView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

       present(alertController, animated: true)
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.imagePicker.sourceType = type
            self.present(self.imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoImageView.image = pickedImage
            _ = saveImage(image: pickedImage)
        }
     
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("runTrackerUserProfile.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func getSavedImage() -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("runTrackerUserProfile.png").path)
        }
        return nil
    }
    
}
