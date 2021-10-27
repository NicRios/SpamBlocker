//
//  QuestionTableViewCell.swift
//  Coverage-call-blocker
//
//  Created by iroid on 09/10/21.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    var itemState: StateResponse?{
//        didSet{
//            answerLabel.text = itemState?.state_name
//            if itemState?.isSelected ?? false == false{
//                selectedImageView.isHidden = true
//            }
//            else{
//                selectedImageView.isHidden = false
//            }
//        }
//    }
//    
//    var item: CompaniesResponse?{
//        didSet{
//            answerLabel.text = item?.company_name
//            if item?.isSelected ?? false == false{
//                selectedImageView.isHidden = true
//            }
//            else{
//                selectedImageView.isHidden = false
//            }
//        }
//    }
    
    
    
}
