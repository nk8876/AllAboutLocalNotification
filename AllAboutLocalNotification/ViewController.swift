//
//  ViewController.swift
//  AllAboutLocalNotification
//
//  Created by Dheeraj Arora on 10/10/19.
//  Copyright © 2019 Dheeraj Arora. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    let notificationCenter = UNUserNotificationCenter.current()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (didAllow, error) in
           if !didAllow {
                print("User has declined notifications")
            }
        }
        localNotificationAction()
    }

    func localNotificationAction()   {
        //Notification Content
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "alarm"
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.sound = UNNotificationSound.default
        content.userInfo = ["name":"Naresh Kumar"]
        
        //Content Image Attached
        guard let imageUrl = Bundle.main.url(forResource: "localNotification", withExtension: ".jpeg") else { return }
        let attachment = try! UNNotificationAttachment(identifier: "image", url: imageUrl, options: [:])
        content.attachments = [attachment]
        
        
        //Trigger Time
        var dateComponents = DateComponents()
        dateComponents.hour = 11
        dateComponents.minute = 46
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)  // for every day repeats
        //let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false) // FIRE AFETR 5 SECOND
        let request = UNNotificationRequest.init(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        let date = Date().addingTimeInterval(10)
        let dateCom = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        let tri = UNCalendarNotificationTrigger(dateMatching: dateCom, repeats: false)
        let uuidString = UUID().uuidString
        let req = UNNotificationRequest(identifier: uuidString, content: content, trigger: tri)
        notificationCenter.add(req) { (error) in
            print("\(String(describing: error?.localizedDescription))")
        }

        
        //Add Request to Notification Center
        notificationCenter.add(request) { (error) in
            print("\(String(describing: error?.localizedDescription))")
        }
        
        
        //Notification Action
        let like = UNNotificationAction.init(identifier: "Like", title: "Like", options: .foreground)
        let delete = UNNotificationAction.init(identifier: "Delete", title: "Delete", options: .destructive)
        let category = UNNotificationCategory.init(identifier: content.categoryIdentifier, actions: [like, delete], intentIdentifiers: [], options: [])
        notificationCenter.setNotificationCategories([category])
        
        
    }
    
}
extension ViewController: UNUserNotificationCenterDelegate{
    // Delegate Methods for Present Notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    // Delegate Methods for jump to next vc and data pass
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        if let info = response.notification.request.content.userInfo as? [AnyHashable:Any]{
            secondVC.info = info["name"] as! String
        }
        self.navigationController?.pushViewController(secondVC, animated: true)
    }
}
