//
//  ViewController.swift
//  SeeFood
//
//  Created by Jeff on 5/26/20.
//  Copyright © 2020 Jeff Corp. All rights reserved.
//

import UIKit
//MARK: - Note 1: Download the InceptionV3 model; drag and drop into app file structure; xcode will automatically genereate swift model class. Import CoreML into class declaration. Import Vision framework; this will help us process images easily and work with CoreML.
import CoreML
import Vision

//MARK: - Note 2: Set up UIPickerImage class; start by adding its delegate class: 'UIImagePickerControllerDelegte'; in order for this to work it also needs the 'UINavigationControllerDelegate'. In Main.storyboard embed a navigation controller to the ViewController. From the library, drag in bar button; change to camera icon from system item. Drag in from the library an imageView; stretch into fill view controller; set constraints - uncheck constrain to margins; bottom and top are deprecated, meaning, top and bottom are no longer valid constraint settings; go into file inspecter, Interface Builder Documentaion, and select 'safe area layout guides'.
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: - Note 4: Create UIImageView IBOutletPicker.
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Note 5: Create a new 'imagePicker' object. (Use the empty () as we are creating a new object form the class, UIImagePickerController.)
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Note 6: set this delegate as the current class, ie. this view controller.
        imagePicker.delegate = self
        //MARK: - Note 7: Set additional properties: .sourceType and allowsEditing. sourceType property is the type of picker interface to be displayed by the controller - '.camera' which allows user to take an image (easiest way to implement camera function in any app). If you want the user to access media from their photo library, change '.camera' to '.photoLibrary'
        imagePicker.sourceType = .photoLibrary
        //MARK: - Note 8: Set allowsEddint property, this is a bool value, to indicate if user can edit the selected media. A better definition when you option click the statement.
        imagePicker.allowsEditing = false
    
    }
    
    //MARK: - Note 11: call the delegate method that comes from the UIImagePickerControllerDelegate, 'UIImagePickerController, didFinishPickingMediaWithInfo'; lets talk through some of the parameters: 'picker' is the UIImagerPickerController we used to pick the image, in this case its the 'imagePicker'; 'didFinishPickingMediaWithInfo info' contains the image the user picked and it can be tapped into using this method.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //MARK: - Note 12: Check if an image was picked and it wasn't nil: in a  constant, 'userPickedImage', set this to the image the user picked using the UIImagePickerContoller. Tap into the 'info' parameter, a dictionary, specify the key that will yield the image picked: '.originalImage', original unedited image selected by the user. Notice that we're providing a key to the dictionary and getting a value based on that key but xcode does not know what the data type is. 'info' has a data type for key and 'Any' for it's value. This data cannont be set into an 'image' property of the 'imageView'. To do this, set an optional binding and downcast it as an UIImage to make it more explicit. Downcast to say, 'info[.originalImage] as? UIImage' this data should be a UIImage data type. Add an 'if' to make this an optional bind: meaning, if this peice of data can be downcasted to an UIImage data type then execute the line of code inside '{}'; which is to set the 'imageView' image property to the user picked image.
        if let userPickedImage = info[.originalImage] as? UIImage {
            //MARK: - Note 13: Set 'imageView' to the background that ws picked. tap into the 'image' property and set it to the user selected image. Cannot assign a value of type 'Any?' to type 'UIImage?'.
            imageView.image = userPickedImage
            //MARK: - Note 14: Dissmiss the image picker and go back to the view controller. So, when this delegate method is called it can be dismissed by using its UIImagePickerController object that was created, 'imagePicker' then call the 'dismiss' property. Remember to add to the 'Information Property List' or 'info.plist': Add 'Privacy Camera Usage Description' and 'Privacy Photo Library Usage'; add a description.
            imagePicker.dismiss(animated: true, completion: nil)
            //MARK: - Note 15: Convert UIImage into a CIImage, Core Image Image, this is a special type of image that will allow us to use the Vision framework and the CoreML framework to get an interpertation from it. Use the user picked image from earlier. Add a security feature to make it safer by adding a 'guard' statement, in front of the 'let', followed by a trailing 'else' statement that will trigger a, 'fatalError("")' if the convert from UIImage to CIImage failes. This has to be followed by at method that will process this CIImage and get an interpertation or classification out of it.
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage into CIImage")
            }
            
            //MARK: - Note 18: Call the new 'detect' method to process the image. Pass this CIImage into this method 'detect' so image can be used to be classified by our model.
            detect(image: ciImage)
        }
    }
    
    //MARK: - Note 16: New method: 'detect' that will take one paremeter with a data type CIImage: 'detect(image: CIImage)'. Inside this method it will use the InceptionV3 model. Create a new object called, 'model', use the VNCoreMLModel as a container for our MLModel, which is called 'Inceptionv3()', use the () to create a new object of that class. Then we can tap into its 'model' property. So, this is an object called 'model' using the VNCoreMLModel container and creating a new object of 'Inceptionv3' and gettings 'model' property loaded up. This model will classify our image. This line of code can throw an error; use 'try?' (try? - the error is handled by truning it into an optional statement) statement, this will attempt to perfrom this operation that might throw an error. If it succeeds the result will be wrapped as an optional but it it fails, if an error was thrown, then the result of this line will be 'nil'. So to guard against those situations where it fails, a nil model, we want to know why it did by sending an error message to our debug console. So, this must be wrapped in a 'gurad' and 'else' statemnt. Instead of 'if let' it'll be a 'guard let', meaning, if the model is nil, then trigger an else statement that will trigger an 'fatalError("Loading CoreML Model failed")'. VNCoreMLModel comes from the Vision framework which allows us to perfrom an image analysis request that uses our CoreML model to process images.
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        //MARK: - Note 17 A: To use this model that exists without it being nil, create a CoreMLRequet object, 'request', with a completion handler. Use the newly created model, 'Enter' to incert the code and name them respectively: request and error. Then for the code to happen when the request has completed is to process the results of that request. Create an object called 'results' set equal to 'request.results' then downcast 'as?' its data type to: array of '[VNCLassificationsObservations]'. Use a guard to exit so the code can exit and to tell us why and were it failed. Then actually perfrom this request, it has a model but it doesnt know which image to perfrom this request on.
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            //MARK: - Note 20: Change the title bar text to say, "Hotdog" or "Not hotdog". Check in the results we get back for the first item  with the highest confidence interval. Tap into the frist result with a new optionally chained property: 'firstResult = results.first'. Inside here, tap into fristResult and its property to check if it contains a string called "hotdog": '.identifier.contains("hotdog")'; the classification was certain that it contained a "hotdog". In this case change the navigation bar title to "Hotdog": 'self.navigationItem.title = "Hotdog" 'else' if it doesnt contain the word "hotdog" then set the navigationItem.title = "Not Hotdog". So this will check to see if it has a first result value, and then we use that value to check that its identifer contains the word hotdog. So in the console is an array of all the VNClassificationObservations. The items contain a few properties and one of those properties is the percentage confidence the model has in its prediction. The string that says "hotdog bun, hotdog" is the indentifier property of the first result. So the line of code is checking to see if that line of string contains "hotdog".
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog"
                } else {
                    self.navigationItem.title = "Not Hotdog"
                }
            }
        }
        //MARK: - Note 17 B: Creat a 'handler' = 'VNImageRequestHandler(ciImage: 'parameter name')' 'Try!' using the handler to perfrom the request. Force it '!' or a safer way is to enclose it in a 'do', 'try', 'catch' block. Finally call this method to pass the CIImage from 'imagePickerController' (note 18).
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    //MARK: - Note 3: Creat an IBAction
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        //MARK: - Note 9: Specify what time point we want the image to appear. Most logical point for this to appear is when the camera button is tapped. Call 'present' because its a view controller, '(which view controller to present: 'imagePicker', completion handler as nil cause we dont want anything to happen after we finish presenting the image picker.
        present(imagePicker, animated: true, completion: nil)
    }
    

}

//MARK: - Note 10: 1-9 review: Set the current 'ViewController' as a delegate of the UIImagePickerControllerDelegate aswell as the UINavigationControllerDelegate. Then create a new UIImagePickerController object, 'imagePicker', and set its properties: delegate, sourceType, allowsEditing. Finally, when the camera button gets tapped, 'cameraTapped', we're asking the app to 'present' the imagerPicker to the user to use camera or photo album to pick an image. After the image gets picked, it needs to be sent to the machine learning model by using a delegate method: 'UIImagePickerController, didFinishPickingMediaWithInfo'.

//MARK: - Note 19: Review 11-17 review: Use the image the user picked in the imagePickerController and convert that image into a CIImage, pass that CIImage into detect image metohd. In the detect method we load up our model, using the imported Inceptionv3 model and then we create a request that asks the model to classify whatever the data we pass it. The data we pass it defined using a handler. Then we use the image handler to perfrom the request of classifying the image. When this process completes, then a callback get triggered and get back a request or an error.


