//
//  Question2Screen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 08/10/21.
//

import UIKit
import TCProgressBar

class Question2Screen: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var progressBarView: TCProgressBar!
    @IBOutlet weak var progressLabel: UILabel!
    
    var stateArray: [StateResponse] = []
    var selectedstateidArray = [Int]()
    
    var selectedAnswer1String: String = ""
    var selectedAnswer2String: String = ""
    
    var isFromMenuScreen: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupinitialView()
    }
    
    func setupinitialView(){
        self.view.addGradientWithColor()
        
        progressBarView.value = 0.3
        progressLabel.text = "33% completed"
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.backgroundColor = UIColor.clear
        mainTableView.tableFooterView = UIView()
        mainTableView.separatorStyle = .none
        mainTableView.isHidden = true
        
        //        getStatesAPI()
        
        if let path = Bundle.main.path(forResource: "States", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["data"] as? NSArray {
                    
                    for item in 0...person.count - 1 {
                        let data = person[item] as? NSDictionary ?? [:]
                        stateArray.append(StateResponse(state_id: data["state_id"] as? Int, state_name: data["state_name"] as? String))
                    }
                    
                    self.mainTableView.reloadData()
                    self.mainTableView.isHidden = false
                }
            } catch {
                print("Something wrong")
            }
        }
        
        if let surveyArray = UserDefaults.standard.value(forKey: SURVEYARRAY) as? [[String : Any]] {
            print("surveyArray : ", surveyArray)
            
            if surveyArray.count >= 2{
                selectedAnswer2String = surveyArray[1]["answer"] as? String ?? ""
                print("selectedAnswer2String : ", selectedAnswer2String)
                
                //                selectedstateidArray = selectedAnswer2String.compactMap{Int(String($0))}
                selectedstateidArray = self.get_numbers(stringtext: selectedAnswer2String)
                
                mainTableView.reloadData()
            }
        }
    }
    
    func get_numbers(stringtext:String) -> [Int] {
        let StringRecordedArr = stringtext.components(separatedBy: ",")
        return StringRecordedArr.map { Int($0)!}
    }
    
    //MARK: - button clicked event
    @IBAction func onNext(_ sender: UIButton) {
        
        selectedAnswer2String = (selectedstateidArray.map{String($0)}).joined(separator: ",")
        
        if selectedAnswer2String == ""{
            self.view.makeToast("Please select state")
        }
        else{
            
            progressBarView.value = 0.6
            progressLabel.text = "66% completed"
            
            let vc =  STORYBOARD.Survey.instantiateViewController(withIdentifier: "Question3Screen") as! Question3Screen
            vc.selectedAnswer1String = selectedAnswer1String
            vc.selectedAnswer2String = selectedAnswer2String
            vc.isFromMenuScreen = isFromMenuScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - TableView methords
extension Question2Screen: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numOfSections: Int = 0
        
        if stateArray.count > 0 {
            numOfSections = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No data found"
            noDataLabel.textColor = UIColor.white
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 1
            tableView.backgroundView = noDataLabel
        }
        
        return numOfSections
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableViewCell") as? QuestionTableViewCell ?? Bundle.main.loadNibNamed("QuestionTableViewCell", owner: self, options: nil)![0] as! QuestionTableViewCell
        cell.selectionStyle = .none
        
        //        cell.itemState = stateArray[indexPath.row]
        
        cell.answerLabel.text = stateArray[indexPath.row].state_name
        
        print(selectedstateidArray)
        print(stateArray[indexPath.row].state_id ?? 0)
        
        if selectedstateidArray.contains(stateArray[indexPath.row].state_id ?? 0)
        {
            cell.selectedImageView.isHidden = false
        }
        else{
            cell.selectedImageView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        stateArray[indexPath.row].isSelected = !stateArray[indexPath.row].isSelected
        
        if selectedstateidArray.contains(stateArray[indexPath.row].state_id ?? 0)
        {
            selectedstateidArray.removeObject(stateArray[indexPath.row].state_id ?? 0)
        }
        else{
            selectedstateidArray.append(stateArray[indexPath.row].state_id ?? 0)
        }
        
        let indexPath = IndexPath(item: indexPath.row, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
        
    }
}
