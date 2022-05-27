//
//  BirthdayTableViewController.swift
//  BirdthdayTracker
//
//  Created by Julia Romanenko on 07.02.2022.
//

import UIKit
import CoreData
import UserNotifications

class BirthdayTableViewController: UITableViewController {

    var birthdays = [Birthday]()
    let dateFormatter = DateFormatter()
    
    let identifierCell = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        updateBirthdays()
        
       
      
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = Birthday.fetchRequest() as NSFetchRequest<Birthday>
        
        //сортировка списка по фамилиям
        let sortDescriptor1 = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "firstName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
    
       
        do {
            birthdays = try context.fetch(fetchRequest)
        } catch let error {
            print("Не удалось сохранить из-за ошибки \(error)")
        }
    }
    
    func updateBirthdays() {
        
        birthdays.removeAll() //обновляем массив
        tableView.reloadData() //обновляем отображение таблицы
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return birthdays.count
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath)
        
        let birthday = birthdays[indexPath.row]
    
        let firstName = birthday.firstName ?? ""
        let lastName = birthday.lastName ?? ""
        cell.textLabel?.text = firstName + " " + lastName
        
        if let date = birthday.birthdate as Date? {
            cell.detailTextLabel?.text = dateFormatter.string(from: date)
        } else {
            cell.detailTextLabel?.text = " "
        }

        return cell
    }

    //разрешаем редактирвоание для строк - удаление
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
  
    //удаляем и строки и перезаписываем данные
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if birthdays.count > indexPath.row {
            let birthday = birthdays[indexPath.row]
            
            //удаляем уведомление
            if let identifier = birthday.birthdayId {
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [identifier])
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.delete(birthday)
            birthdays.remove(at: indexPath.row)
            
            do {
                try context.save()
            } catch let error {
                print("Не удалось сохранить из-за ошибки \(error)")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
}
