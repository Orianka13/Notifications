//
//  AppDelegate.swift
//  Notifications
//
//  Created by Alexey Efimov on 21.06.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        requestAuthorization()
        
        notificationCenter.delegate = self
        
        return true
    }


    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0 //при каждом запуске приложения это свойство будет обнуляться
    }
    
    func requestAuthorization(){
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() { //этот метод возвращает параметр который определил пользователь
        notificationCenter.getNotificationSettings { settings in //settings можно использовать для проверки состояния авторизации или отдельных параметров уведомлений
            print("Notification settings: \(settings)")
        }
    }
    
    func scheduleNotification(notificationType: String){ //расписание уведомлений
        
        let userAction = "User Action" //id по которому будет определяться категория
        let content = UNMutableNotificationContent()
        
        content.title = notificationType
        content.body = "This is example how to create" + notificationType
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = userAction
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        //имея контент и риггер создаем запрос на уведомления. Для каждого запроса требуется свой идентификатор.
        
        let identifier = "Local notification"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        //вызываем запрос:
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: []) //отложить выполнение действия
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: userAction,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        notificationCenter.setNotificationCategories([category])
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, // метод вызывается в момент получения уведомления при открытом приложении
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "Local notification" {
            print("Handling notification with the Local Notification with identifier")
        }
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default Action")
        case "Snooze":
            print("Snooze")
            scheduleNotification(notificationType: "Reminder")
        case "Delete":
            print("Delete")
        default:
            print("Unknown action")
        }
        
        completionHandler()
    }
}
