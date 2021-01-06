//
//  ViewController.swift
//  QRSacnner
//
//  Created by Rahul on 21/12/20.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var codeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func scanButtonActiom(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "ScannerViewController") as! ScannerViewController
        
        vc.delegate = self
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ViewController : ScannerDelegate {
    func didCompleteScanning(_ code: String, _ sender: UIViewController) {
        codeLabel.text = code
        sender.navigationController?.popViewController(animated: true)
    }
}




