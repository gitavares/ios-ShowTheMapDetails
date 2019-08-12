//
//  MapDetailsViewController.swift
//  ShowTheMapDetails
//
//  Created by Giselle Tavares on 2019-03-25.
//  Copyright © 2019 Giselle Tavares. All rights reserved.
//

import UIKit

class MapDetailsViewController: UIViewController {
    
    var addressA = ""
    var addressB = ""
    var distance = ""

    @IBOutlet weak var details: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        details.text = "Point A: \(addressA)\nPointB: \(addressB)\nDistance: \(distance)"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
