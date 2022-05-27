//
//  ViewController.swift
//  BirdthdayTracker
//
//  Created by Julia Romanenko on 07.02.2022.
//

import UIKit
import CoreData
import UserNotifications


class AddBirthdayViewController: UIViewController {


    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthdatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        birthdatePicker.maximumDate = Date()
        
    }


    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let birthdate = birthdatePicker.date
        
        //CoreData - создаем и сохраняем
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newBirthday = Birthday(context: context)
        newBirthday.firstName = firstName
        newBirthday.lastName = lastName
        newBirthday.birthdate = birthdate as NSDate? as Date?
        newBirthday.birthdayId = UUID().uuidString
        
        if let uniqueId = newBirthday.birthdayId {
            print("birthdayId: \(uniqueId)")
        }
        
        //сохраняем значения в newBirthday и проверем на ошибки
        do {
            try context.save()
            
            //создаем сообщение для напоминания
            let message = "Сегодня \(firstName) \(lastName) празднует День рождения!"
            let content = UNMutableNotificationContent()
            content.body = message
            content.sound = UNNotificationSound.default
            
            //создаем напоминание в нужный день и час
            var dateCompinents = Calendar.current.dateComponents([.month, .day], from: birthdate)
            dateCompinents.hour = 8
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompinents, repeats: true)
            
            if let identifier = newBirthday.birthdayId {
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(request, withCompletionHandler: nil)
            }
        } catch let error {
            print("Не удалось сохранить из-за ошибки \(error)")
        }
        
        //закрываем окно добавления ДР
        dismiss(animated: true, completion: nil)
        
        //тестим, что все приходит
        print("Создана запись о дне рождения!")
        print("Имя: \(firstName)")
        print("Фамилия: \(lastName)")
        print("День рождения: \(birthdate)")

    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}

