//
//  DetailViewController.swift
//  MemoryContacts
//
//  Created by Matt Long on 5/5/16.
//  Copyright © 2016 Matt Long. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var detailItem: NSDictionary? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            guard let givenName = detail["givenName"] as? String, familyName = detail["familyName"] as? String, identifier = detail["identifier"] as? String else {
                return
            }
            self.detailDescriptionLabel?.text = "\(givenName) \(familyName): \(identifier)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

