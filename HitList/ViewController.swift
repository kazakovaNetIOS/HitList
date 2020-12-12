//
//  ViewController.swift
//  HitList
//
//  Created by Natalia Kazakova on 12.12.2020.
//

import UIKit
import CoreData

class ViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!

  var people: [NSManagedObject] = []

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "The List"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")

    do {
      people = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }

  // MARK: - IBAction

  @IBAction func addName(_ sender: UIBarButtonItem) {
    let alert = UIAlertController(title: "New Name",
                                  message: "Add a new name", preferredStyle: .alert)

    let saveAction = UIAlertAction(title: "Save",
                                   style: .default) { [weak self] action in
      guard let textField = alert.textFields?.first,
            let nameToSave = textField.text else {
        return
      }

      self?.save(name: nameToSave)
      self?.tableView.reloadData()
    }

    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .cancel)

    alert.addTextField()

    alert.addAction(saveAction)
    alert.addAction(cancelAction)

    present(alert, animated: true)
  }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return people.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let person = people[indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = person.value(forKey: "name") as? String

    return cell
  }
}

// MARK: - Private

private extension ViewController {
  func save(name: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext

    guard let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext) else {
      return
    }

    let person = NSManagedObject(entity: entity, insertInto: managedContext)
    person.setValue(name, forKey: "name")

    do {
      try managedContext.save()
      people.append(person)
    } catch let error as NSError {
      print("Could not save. \(error). \(error.userInfo)")
    }
  }
}
