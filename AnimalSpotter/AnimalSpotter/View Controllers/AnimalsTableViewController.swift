//
//  AnimalsTableViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var animalNames: [String] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    let apiController = APIController()
    
    // MARK: - View Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // transition to login view if conditions require
        if apiController.bearer == nil {
            performSegue(withIdentifier: "LoginViewModalSegue", sender: self)
        }
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animalNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = animalNames[indexPath.row]
        
        return cell
    }
    
    // MARK: - Actions
    @IBAction func getAnimals(_ sender: UIBarButtonItem) {
        // fetch all animals from API
        apiController.fetchAllAnimalNames { result in
            do {
                let names = try result.get()
                DispatchQueue.main.async {
                    self.animalNames = names.sorted()
                }
            } catch {
                if let error = error as? NetworkError {
                    self.handleError(error)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginViewModalSegue" {
            if let loginVC = segue.destination as? LoginViewController {
                loginVC.apiController = apiController
            }
        } else if segue.identifier == "ShowAnimalDetailSegue" {
            guard let detailVC = segue.destination as? AnimalDetailViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard indexPath.row < animalNames.count else { return }
            
            detailVC.animalName = animalNames[indexPath.row]
            detailVC.apiController = apiController
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

