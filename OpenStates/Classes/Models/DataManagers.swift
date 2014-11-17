//
//  DataManagers.swift
//  OpenStates
//
//  Created by Daniel Cloud on 11/17/14.
//  Copyright (c) 2014 Sunlight Foundation. All rights reserved.
//

import UIKit
import OCDKit

typealias FetchCompletion = (NSArray?, NSError?) -> Void

class OpenCivicDataManager: NSObject, UITableViewDataSource {
    private let api:OpenCivicData
    var items: NSMutableArray

    override init() {
        self.items = NSMutableArray()

        let config = AppConfiguration()
        let apiKey = config.ocdApiKey!
        self.api = OpenCivicData(apiKey: apiKey)

        super.init()
    }

    func fetchItems(onCompletion: FetchCompletion) {
        let jurisdiction_id = "ocd-jurisdiction/country:us/state:nc/government"

        self.api.organizations(["jurisdiction_id": jurisdiction_id]).responseJSON({ (request, _, JSON, error) -> Void in

            if let jsonResult = JSON as? Dictionary<String, AnyObject> {
                let results: NSArray? = jsonResult["results"] as? NSArray
                let meta: NSDictionary? = jsonResult["meta"] as? NSDictionary
                let errorMessage = jsonResult["error"] as? String

                if let resultsList = results {
                    println("Found \(resultsList.count) results")
                    self.items.removeAllObjects()
                    self.items.addObjectsFromArray(resultsList)
                    onCompletion(self.items, error)
                }
            }
        })
    }

    func itemForIndexPath(indexPath: NSIndexPath) -> NSDictionary? {
        return self.items[indexPath.row] as? NSDictionary
    }

    // MARK: - UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count ?? 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        if let object = self.itemForIndexPath(indexPath) {
            if let title = object["name"] as? String {
                cell.textLabel.text = title
            }
            if let subtitle = object["id"] as? String {
                cell.detailTextLabel?.text = subtitle
            }
        }
        return cell
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
}

class LegislatorDataManager: OpenCivicDataManager {
    override func fetchItems(onCompletion: FetchCompletion) {
        self.api.people().responseJSON({ (request, _, JSON, error) -> Void in

            if let jsonResult = JSON as? Dictionary<String, AnyObject> {
                let results: NSArray? = jsonResult["results"] as? NSArray
                let meta: NSDictionary? = jsonResult["meta"] as? NSDictionary
                let errorMessage = jsonResult["error"] as? String

                if let resultsList = results {
                    println("Found \(resultsList.count) results")
                    self.items.removeAllObjects()
                    self.items.addObjectsFromArray(resultsList)
                    onCompletion(self.items, error)
                }
            }
        })
    }

}