//
//  ViewController.swift
//  PowerNapTimer
//
//  Created by James Pacheco on 4/12/16.
//  Copyright © 2016 James Pacheco. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    let myTimer = MyTimer()
    let userNotificationIdentifier = "timerNotification"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTimer.delegate = self
        
        setView()
    }
    
    func setView() {
        updateTimerLabel()
        // If timer is running, start button title should say "Cancel". If timer is not running, title should say "Start nap"
        if myTimer.isOn {
            startButton.setTitle("Cancel", for: UIControlState())
        } else {
            startButton.setTitle("Start nap", for: UIControlState())
        }
    }
    
    func updateTimerLabel() {
        timerLabel.text = myTimer.timeAsString()
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        if myTimer.isOn {
            myTimer.stopTimer()
            cancelLocalNotification()
        } else {
            myTimer.startTimer(5)
            scheduleLocalNotification()
        }
        setView()
    }
    
    //MARK: - UIAlertController
    
    func setupAlertController() {
        let alert = UIAlertController(title: "Wake Up", message: "Get up ya lazy bum!", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Sleep a few more minutes..."
            textField.keyboardType = .numberPad
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (_) in
            self.setView()
        }
        
        let snoozeAction = UIAlertAction(title: "Snooze", style: .default) { (_) in
            guard let timeText = alert.textFields?.first?.text,
                let time = TimeInterval(timeText) else { return }
            self.myTimer.startTimer(time)
            self.scheduleLocalNotification()
            self.setView()
        }
        
        
        alert.addAction(dismissAction)
        alert.addAction(snoozeAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UserNotifications
    
    func scheduleLocalNotification() {
        // Step 1: Create the notification you want to display
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Wake up!"
        notificationContent.body = "Time to get up."
        
        // Step 2: Create a trigger of when you want to display the notification
        guard let timeRemaing = myTimer.timeRemaining else { return }
        let fireDate = Date(timeInterval: timeRemaing, since: Date())
        let dateComponents = Calendar.current.dateComponents([.minute, .second], from: fireDate)
        let dateTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Step 3: Create the request to send to NotificationCenter
        let request = UNNotificationRequest(identifier: userNotificationIdentifier, content: notificationContent, trigger: dateTrigger)
        
        // Step 4: Adding our request to NotificationCenterif let error = error {
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Unable to add notification request. \(error.localizedDescription)")
            }
        }
    }
    
    func cancelLocalNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [userNotificationIdentifier])
    }
}

// MARK: - Timer Delegate

extension ViewController: TimerDelegate {
    
    func timerSecondTick() {
        updateTimerLabel()
    }
    
    func timerCompleted() {
        setView()
        // Appear the notification and alertcontroller
        setupAlertController()
    }
    
    func timerStopped() {
        setView()
        // Canel notification
        cancelLocalNotification()
    }
    
}
