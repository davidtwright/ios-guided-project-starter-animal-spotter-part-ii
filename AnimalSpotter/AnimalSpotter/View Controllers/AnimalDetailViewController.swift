//
//  AnimalDetailViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 6/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var timeSeenLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var animalImageView: UIImageView!
    
    var animalName: String?
    var apiController: APIController?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDetails()
    }
    
    // MARK: - Get Details

    private func getDetails() {
        guard let apiController = apiController,
            let animalName = animalName else {
                print("AnimalDetailViewController: apiController and animalName are required dependencies.")
                return
        }
        
        apiController.fetchDetails(for: animalName) { result in
            do {
                let animal = try result.get()
                self.updateViews(with: animal)
                
                apiController.fetchImage(at: animal.imageURL) { result in
                    guard let animalImage = try? result.get() else { return }
                    self.updateImage(with: animalImage)
                }
            } catch {
                if let error = error as? NetworkError {
                    self.handleError(error)
                }
            }
        }
    }
    
    // MARK: - Update Views

    private func updateViews(with animal: Animal) {
        DispatchQueue.main.async {
            self.title = animal.name
            self.descriptionLabel.text = animal.description
            self.coordinatesLabel.text = "lat: \(animal.latitude), long: \(animal.longitude)"
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            self.timeSeenLabel.text = dateFormatter.string(from: animal.timeSeen)
        }
    }
    
    private func updateImage(with image: UIImage) {
        DispatchQueue.main.async {
            self.animalImageView.image = image
        }
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: NetworkError) {
        switch error {
        case .noAuth:
            print("No bearer token exists")
            showAlert(title: "Not Signed In", message: "Please sign in.")
        case .badAuth:
            print("Bearer token invalid")
            showAlert(title: "User Authentication Failed", message: "Try signing out and signing back in.")
        case .otherError:
            print("Other error occurred, see log")
            showAlert(title: "A Problem Occured", message: "Please try again.")
        case .badData:
            print("No data received, or data corrupted")
            showAlert(title: "Error Loading Page", message: "Please try again.")
        case .decodingError:
            print("JSON could not be decoded")
            showAlert(title: "Error Loading Page", message: "Please try again.")
        }
    }
    
    private func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(alertAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
