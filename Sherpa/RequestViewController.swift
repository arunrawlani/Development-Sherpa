//
//  RequestViewController.swift
//  Sherpa
//
//  Created by Praynaa Rawlani on 8/5/15.
//  Copyright (c) 2015 Arun Rawlani. All rights reserved.
//

import Foundation
import Parse

class RequestViewController: UIViewController{
   
    @IBOutlet weak var approvedTours: UILabel!
    @IBOutlet weak var awaitingApproval: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var requestSegment: UISegmentedControl!
    var requestedTour: [Request] = []
    var approvedTour: [Request] = []
    var segRequests: [Request] = []
    
    //Queries
    var awaitingQuery: PFQuery?
    var approvedQuery: PFQuery?
   
   
   override func viewDidLoad() {
    
    super.viewDidLoad()
    
    self.approvedTours.hidden = true
    
    
    //MARK: Returns requests that have NOT BEEN APROVED
    
    let requestQuery = Request.query()
    requestQuery!.whereKey("toUser", equalTo: PFUser.currentUser()!)
   
    if let requestQuery = requestQuery {
            self.awaitingQuery = PFQuery.orQueryWithSubqueries([requestQuery])
            self.awaitingQuery!.whereKey("isApproved", equalTo: false)
        
        self.awaitingQuery!.includeKey("toUser")
        self.awaitingQuery!.includeKey("fromUser")
        self.awaitingQuery!.includeKey("toTour")
    }
    else{
        println("Optional related error?")
    }
    
    awaitingQuery!.findObjectsInBackgroundWithBlock {(result: [AnyObject]?, error: NSError?) -> Void in
        self.requestedTour = result as? [Request] ?? []
        self.tableView.reloadData()
    }
    
    //MARK: Returns requests that have BEEN APPROVED
    let requestQuery2 = Request.query()
    requestQuery2!.whereKey("toUser", equalTo: PFUser.currentUser()!)
    
    if let requestQuery2 = requestQuery2 {
        self.approvedQuery = PFQuery.orQueryWithSubqueries([requestQuery2])
        self.approvedQuery!.whereKey("isApproved", equalTo: true)
        
        self.approvedQuery!.includeKey("toUser")
        self.approvedQuery!.includeKey("fromUser")
        self.approvedQuery!.includeKey("toTour")
    }
    else{
        println("Optional related error?")
    }
    
    approvedQuery!.findObjectsInBackgroundWithBlock {(result: [AnyObject]?, error: NSError?) -> Void in
        
        self.approvedTour = result as? [Request] ?? []
        self.tableView.reloadData()
        
    
    println(self.approvedTour.count)
    }
    
    }
    
    
    @IBAction func indexChanged(sender: AnyObject) {
        switch requestSegment.selectedSegmentIndex
        {
        case 0:
            self.awaitingApproval.hidden = false
            self.approvedTours.hidden = true
            self.tableView.reloadData()
        case 1:
            self.awaitingApproval.hidden = true
            self.approvedTours.hidden = false
            self.tableView.reloadData()
        default:
            break
            
        }
  
 
    }
    
}

extension RequestViewController: UITableViewDataSource{
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if (requestSegment.selectedSegmentIndex == 0){
            println(self.requestedTour.count)
            count = self.requestedTour.count ?? 0
        }
        else{
            println(self.approvedTour.count)
            count = self.approvedTour.count ?? 0
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell") as! RequestTableViewCell
        //Cell parameters:
        if (requestSegment.selectedSegmentIndex == 0){
        let test = requestedTour[indexPath.row].toTour
        requestedTour[indexPath.row].toTour!.fetchIfNeeded()
        cell.tourNameLabel.text = requestedTour[indexPath.row].toTour!["tourName"] as? String
        cell.tourDateLabel.text = requestedTour[indexPath.row].requestedDate
        cell.touristLabel.text = requestedTour[indexPath.row].fromUser!.username
        cell.approveMessage.hidden = true
        cell.rejectMessage.hidden = true
        cell.processingMessage.hidden = true
        cell.approveButton.hidden = false
        cell.rejectButton.hidden = false
        cell.timeLabel.text = requestedTour[indexPath.row].requestedTime
        cell.request = requestedTour[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
            
        else {
        let test = approvedTour[indexPath.row].toTour
        approvedTour[indexPath.row].toTour!.fetchIfNeeded()
        cell.tourNameLabel.text = approvedTour[indexPath.row].toTour!["tourName"] as? String
        cell.tourDateLabel.text = approvedTour[indexPath.row].requestedDate
        cell.touristLabel.text = approvedTour[indexPath.row].fromUser!.username
        cell.approveMessage.hidden = true
        cell.rejectMessage.hidden = true
        cell.processingMessage.hidden = true
        cell.approveButton.hidden = true
        cell.rejectButton.hidden = true
        cell.timeLabel.text = approvedTour[indexPath.row].requestedTime
        cell.request = approvedTour[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
            
        }
        //TODO implement price range cell.rating = allBusinesses[indexPath.row].reviews
        return cell
    }
        
    
}