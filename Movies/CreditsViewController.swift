//
//  CreditsViewController.swift
//  Movies
//
//  Created by Ronnie Voss on 9/5/15.
//  Copyright (c) 2015 Ronnie Voss. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let creditsText = "Credits\n\n Thank you for downloading this app!\n API Source: TMDb\n © 2016 Ronnie Voss. All rights reserved."
        
        self.textField.text = creditsText
        self.textField.textColor = UIColor.white
        self.textField.backgroundColor = UIColor.clear
    }

    @IBAction func doneButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
