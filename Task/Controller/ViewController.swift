//
//  ViewController.swift
//  Task
//
//  Created by Hemaraju MacMini on 25/03/19.
//  Copyright © 2019 incipio. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet var Selected_Country: UILabel!
    
    @IBOutlet var multipleirTextField: UITextField!
    var myData : [String: Any] = [:]
    var currencyList = [Currency]()
    var CurrencyChangedArray = [Float]()
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //check data in Core Data
        entityIsEmpty()
        
        //Textfield dismiss
        tableView.keyboardDismissMode = .interactive
}
    
    // Check initially core data has data or not, based on that we are requesting api
    func entityIsEmpty()
    {
        
         let moc = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
        
        let request:NSFetchRequest<Currency> = Currency.fetchRequest()
       
        do {
            let results:NSArray? =  try moc.fetch(request) as NSArray
            
            if let res = results
            {
                if res.count == 0
                {
                    parsedataFromJSON(Country_String: nil) // Requesting api call
                }
                else
                {
                  loadDataToTable() //if already data exists loading that data to tableiew
                }
            }
            else
            {
               loadDataToTable()
            }
        }
        catch {
            print("Could not load data")
        }
       
        
    }
    
    func parsedataFromJSON(Country_String:String?) {
        CurrencyChangedArray.removeAll()
        var url = URL(string: "https://api.exchangeratesapi.io/latest")!
        
        if let base = Country_String // Initially Displaying currency for EUR
        {
          url  = URL(string: "https://api.exchangeratesapi.io/latest?base=\(base)")!
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: url) { data, response, error in
            
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                return
            }
            
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }
            
            // serialise the data / NSData object into Dictionary [String : Any]
        let json = try? JSONDecoder().decode(CurrencyModel.self,from: content)
            
            guard let arr = json?.rates else {
                print("Empty array")
                return
            }
            
            self.myData = arr as [String : Any]
            DispatchQueue.main.async {
                self.savedataToCoreData()
            }
            
            
            
        }
        
        // execute the HTTP request
        task.resume()
    }

    func savedataToCoreData()
    {
        // ADD data to Core Data
        
        let moc = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Currency")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try moc.persistentStoreCoordinator?.execute(deleteRequest, with: moc)
        } catch let error as NSError {
            // TODO: handle the error
            print(error.localizedDescription)
        }
       

        for (key, value) in self.myData {
            let entity = NSEntityDescription.insertNewObject(forEntityName: "Currency",
                                                             into: moc)
            
            entity.setValue(key, forKey:"name")
            
            entity.setValue(value, forKey: "price")
            do
            {
                try moc.save()
                
                loadDataToTable()
                
            }
            catch
            {
                
            }
    }
       
        
    
    }
    
 
    func loadDataToTable(){
        
        let request:NSFetchRequest<Currency> = Currency.fetchRequest()
        
         let moc = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
        
        do {
            try currencyList = moc.fetch(request)
        }
        catch {
            print("Could not load data")
        }
        
        self.tableView.reloadData()
    }
    
    
    
    // MARK: - UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return currencyList.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        let countryCurrency = currencyList[indexPath.row]
        cell.countryLbl.text = "\(countryCurrency.name!) "
        
        
        //Currecny format using NumberFormatter
        /*let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        let number : NSNumber = NSNumber(value: countryCurrency.price)
        // We'll force unwrap with the !, if you've got defined data you may need more error checking
        let priceString = currencyFormatter.string(from: number)!*/
        
        if CurrencyChangedArray.isEmpty
        {
            cell.priceLbl.text = "\(countryCurrency.price)\(Selected_Country.text!)"

        }else{
        cell.priceLbl.text = "\(CurrencyChangedArray[indexPath.row])\(Selected_Country.text!)"
        
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let countryCurrency = currencyList[indexPath.row]
        parsedataFromJSON(Country_String: countryCurrency.name)
        Selected_Country.text = countryCurrency.name
       // print(countryCurrency.name)
        
        //PENDING : Need update the core data values with selected new country
        
        
        
        
        
    }
    

    
}

extension ViewController :UITextFieldDelegate
{
    
    func  textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
            if newString.isEmpty
            {}else{
            CurrencyChangedArray = currencyList.map {$0.price * Float(newString)!}
            tableView.reloadData()
            }
        

        return true
    }
}
