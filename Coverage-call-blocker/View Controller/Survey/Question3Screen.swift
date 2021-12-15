//
//  Question3Screen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 08/10/21.
//

import UIKit
import ObjectMapper
import TCProgressBar

class QuestionData: Mappable {
    var que: String?
    var answer: String?
    
    required init?(map: Map) {
        
    }
    
    init(que: String, answer: String) {
        self.que = que
        self.answer = answer
    }
    
    func mapping(map: Map) {
        que <- map["que"]
        answer <- map["answer"]
    }
}

class Question3Screen: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var progressBarView: TCProgressBar!
    @IBOutlet weak var progressLabel: UILabel!
    
    var companyArray: [CompaniesResponse] = []
    var selectedCompanyidArray = [Int]()
    
    var selectedAnswer1String: String = ""
    var selectedAnswer2String: String = ""
    var selectedAnswer3String: String = ""
    
    var isFromMenuScreen: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupinitialView()
    }
    
    func setupinitialView(){
        self.view.addGradientWithColor()
        
        progressBarView.value = 0.6
        progressLabel.text = "66% completed"
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.backgroundColor = UIColor.clear
        mainTableView.tableFooterView = UIView()
        mainTableView.separatorStyle = .none
        mainTableView.isHidden = true
        
        if let path = Bundle.main.path(forResource: "IndustryGroups", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["data"] as? NSArray {
                    
                    for item in 0...person.count - 1 {
                        let data = person[item] as? NSDictionary ?? [:]
                        companyArray.append(CompaniesResponse(company_id: data["company_id"] as? Int, company_name: data["company_name"] as? String))
                    }
                    
                    self.mainTableView.reloadData()
                    self.mainTableView.isHidden = false
                }
            } catch {
                print("Something wrong")
            }
        }
        
        if let surveyArray = UserDefaults.standard.value(forKey: SURVEYARRAY) as? [[String : Any]] {
            //            print("surveyArray : ", surveyArray)
            
            if surveyArray.count >= 3{
                selectedAnswer3String = surveyArray[2]["answer"] as? String ?? ""
                print("selectedAnswer3String : ", selectedAnswer3String)
                
                //                selectedCompanyidArray = selectedAnswer3String.compactMap{Int(String($0))}
                selectedCompanyidArray = self.get_numbers(stringtext: selectedAnswer3String)
                
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
        
        selectedAnswer3String = (selectedCompanyidArray.map{String($0)}).joined(separator: ",")
        
        if selectedAnswer3String == ""{
            self.view.makeToast("Please select company")
        }
        else{
            
            //            print("selectedAnswer1String : ", selectedAnswer1String)
            //            print("selectedAnswer2String : ", selectedAnswer2String)
            //            print("selectedAnswer3String : ", selectedAnswer3String)
            
            var ansArray: [QuestionData] = []
            
            ansArray.append(QuestionData.init(que: "1", answer: selectedAnswer1String))
            ansArray.append(QuestionData.init(que: "2", answer: selectedAnswer2String))
            ansArray.append(QuestionData.init(que: "3", answer: selectedAnswer3String))
            
            let array : [[String : Any]] = ansArray.toJSON()
            UserDefaults.standard.setValue(array, forKey: SURVEYARRAY)
            UserDefaults.standard.synchronize()
            
            if isFromMenuScreen == true{
                self.navigationController?.popToRootViewController(animated: true)
            }
            else{
                SurveyPostAPI(questions: ansArray)
            }
        }
    }
}

//MARK: - TableView methords
extension Question3Screen: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numOfSections: Int = 0
        
        if companyArray.count > 0 {
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
        return companyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableViewCell") as? QuestionTableViewCell ?? Bundle.main.loadNibNamed("QuestionTableViewCell", owner: self, options: nil)![0] as! QuestionTableViewCell
        cell.selectionStyle = .none
        
        //        cell.item = companyArray[indexPath.row]
        
        cell.answerLabel.text = companyArray[indexPath.row].company_name
        
        if selectedCompanyidArray.contains(companyArray[indexPath.row].company_id ?? 0)
        {
            cell.selectedImageView.isHidden = false
        }
        else{
            cell.selectedImageView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        companyArray[indexPath.row].isSelected = !companyArray[indexPath.row].isSelected
        
        if selectedCompanyidArray.contains(companyArray[indexPath.row].company_id ?? 0)
        {
            selectedCompanyidArray.removeObject(companyArray[indexPath.row].company_id ?? 0)
        }
        else{
            selectedCompanyidArray.append(companyArray[indexPath.row].company_id ?? 0)
        }
        
        let indexPath = IndexPath(item: indexPath.row, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

//MARK: - API
extension Question3Screen{
    
    //MARK: - Servey Post API
    func SurveyPostAPI(questions: [QuestionData]){
        self.view.endEditing(true)
        Utility.showIndecator()
        
        let param : [String:Any] = ["questions" : questions.toJSON()]
        
        ServeyServices.shared.SurveyPost(parameters: param) { [weak self] (statusCode, response) in
            
            self?.goFurther()
            
            Utility.hideIndicator()
            
        } failure: { [weak self] (error) in
            Utility.hideIndicator()
            guard let stronSelf = self else { return }
            Utility.showAlert(vc: stronSelf, message: error)
        }
    }
    
    func goFurther(){
        
        progressBarView.value = 1
        progressLabel.text = "100% completed"
        
        let vc =  STORYBOARD.inAppPurchase.instantiateViewController(withIdentifier: "InAppPurchaseScreen") as! InAppPurchaseScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

