//
//  MasterViewController.swift
//  MemoryContacts
//
//  Created by Matt Long on 5/5/16.
//  Copyright © 2016 Matt Long. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

extension CNContact {
    var dictionary : NSDictionary {
        
        var contact = [String: AnyObject]()
        let phoneNumbers = NSMutableArray()
        
        contact["identifier"]         = self.identifier
        contact["givenName"]          = self.givenName
        contact["familyName"]         = self.familyName
        contact["imageDataAvailable"] = self.imageDataAvailable
        
        if (self.imageDataAvailable) {
            let thumbnailImageDataAsBase64String = self.thumbnailImageData!.base64EncodedStringWithOptions([])
            contact["thumbnailImageData"] = thumbnailImageDataAsBase64String
        }
        
        if (self.isKeyAvailable(CNContactPhoneNumbersKey)) {
            for number in self.phoneNumbers {
                var numbers = [String: AnyObject]()
                let phoneNumber = (number.value as! CNPhoneNumber).valueForKey("digits") as! String
                let countryCode = (number.value as! CNPhoneNumber).valueForKey("countryCode") as? String
                let label = CNLabeledValue.localizedStringForLabel(number.label)
                numbers["number"] = phoneNumber
                numbers["countryCode"] = countryCode
                numbers["label"] = label
                phoneNumbers.addObject(numbers)
            }
            contact["phoneNumbers"] = phoneNumbers
        }
        
        let contactAsNSDictionary = contact as NSDictionary
        
        return contactAsNSDictionary;
    }
}

class MasterViewController: UITableViewController, UISearchResultsUpdating {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()
    var resultSearchController:UISearchController!
    var searchResults:[NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        self.resultSearchController = UISearchController(searchResultsController: nil)
        
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.hidesNavigationBarDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        self.resultSearchController.searchBar.translucent = true
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
    }
    
    // MARK: Search Controller Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        self.searchResults?.removeAll(keepCapacity: false)
        
        if let searchText = searchController.searchBar.text where searchText.characters.count > 2 {
            self.searchContacts(searchText) { (object) in
                self.searchResults = object[1] as? [NSDictionary]
            }
        }
        
        self.tableView.reloadData()
    }
    
    func searchContacts(searchText: String?, callback: (NSArray) -> ()) -> Void {
        let contactStore = CNContactStore()
        
        let keysToFetch = [ CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataAvailableKey, CNContactThumbnailImageDataKey ]
        
        do {
            var contacts = [NSDictionary]();

            let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
            
            fetchRequest.sortOrder = CNContactSortOrder.GivenName
            fetchRequest.predicate = CNContact.predicateForContactsMatchingName(searchText!)
            
            try contactStore.enumerateContactsWithFetchRequest(fetchRequest) { (cNContact, pointer) -> Void in
                contacts.append(cNContact.dictionary)
            }
            
            callback([NSNull(), contacts])
        }
        catch let error as NSError {
            NSLog("Problem getting unified Contacts")
            NSLog(error.localizedDescription)
            
            callback([error.localizedDescription, NSNull()])
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let contact = searchResults?[indexPath.row] {
                    UIApplication.sharedApplication().keyWindow?.endEditing(true)
                    let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                    controller.detailItem = contact
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }

            }
        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        if let contact = searchResults?[indexPath.row] {
            if let givenName = contact["givenName"] as? String, familyName = contact["familyName"] as? String {
                cell.textLabel!.text = "\(givenName) \(familyName)"
            }
        }
        return cell
    }

}

