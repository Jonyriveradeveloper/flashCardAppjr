//
//  wordCell.swift
//  flashCards
//
//  Created by misael rivera on 29/07/18.
//  Copyright © 2018 misael rivera. All rights reserved.
//

import UIKit

class wordCell: UITableViewCell {
    @IBOutlet weak var wordDescriptionLbl: UILabel!
    @IBOutlet weak var wordTranslateLbl: UILabel!
    @IBOutlet weak var wordProgressLbl: UILabel!
    
    func configureCell(word:Words) {
        self.wordDescriptionLbl.text = word.word
        self.wordTranslateLbl.text = word.translate
        self.wordProgressLbl.text = String(word.goal)
    }
    
    
    
    
    
    
    
}