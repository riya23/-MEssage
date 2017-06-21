//
//  ViewController.swift
//  !Message
//
//  Created by Riya Ganguly on 20/06/17.
//  Copyright © 2017 Riya Ganguly. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblUserList: UITableView!
    var nickname:String!
    var users = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblUserList.delegate = self
        self.tblUserList.dataSource = self
        self.tblUserList.tableFooterView = UIView(frame: CGRect.zero)
        self.tblUserList.separatorColor = UIColor.black
        title = "!Message"
        if(nickname == nil){
            self.askForNickname()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func askForNickname() {
        let alertController = UIAlertController(title: "SocketChat", message: "Please enter a nickname:", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField(configurationHandler: nil)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.text?.characters.count == 0 {
                self.askForNickname()
            }
            else {
                self.nickname = textfield.text
                
                SocketIOManager.sharedInstance.connectToServerWithNickname(nickname: self.nickname, completionHandler: { (userList) -> Void in
                        DispatchQueue.main.async(execute: { () -> Void in
                            if userList != nil {
                                self.users = userList!
                                self.tblUserList.reloadData()
                                self.tblUserList.isHidden = false
                            }
                        })
                })
            }
        }
        
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK : Tableview Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
//        cell.sty
        let cellIdentifier = "Cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: cellIdentifier)
        }
        cell?.textLabel?.text = users[indexPath.row]["nickname"] as? String
        cell?.detailTextLabel?.text = (users[indexPath.row]["isConnected"] as! Bool) ? "Online" : "Offline"
        cell?.detailTextLabel?.textColor = (users[indexPath.row]["isConnected"] as! Bool) ? UIColor.green : UIColor.red
        
        return cell!
    }
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
//        return 44.0
//    }

    //MAR
    
    @IBAction func btnExit(_ sender: UIBarButtonItem) {
        SocketIOManager.sharedInstance.exitChatWithNickname(nickname: nickname) { () -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                self.nickname = nil
//                self.users.removeAll()
                self.tblUserList.isHidden = true
                self.askForNickname()
            })
        }
    }
    
    @IBAction func btnChat(_ sender: UIBarButtonItem) {
        
        let chatViewController = self.storyboard?.instantiateViewController(withIdentifier: "chatViewController") as? chatViewController
        chatViewController?.nickname = nickname
        self.navigationController?.pushViewController(chatViewController!, animated: true)
    }
}

