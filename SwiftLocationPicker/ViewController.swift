//
//  ViewController.swift
//  SwiftLocationPicker
//
//  Created by xiaohei-C on 2017/9/7.
//  Copyright © 2017年 com. All rights reserved.
//

import UIKit

    class ViewController: UIViewController {
        
        @IBOutlet weak var locationLabel: UILabel!
        
        
        @IBAction func level1BtnClick(_ sender: UIButton) {
            
            let locationPicker = SwiftLocationPicker("广东省") { address in
                self.locationLabel.text = address
            }
            locationPicker.show()
        }
        
        @IBAction func level2BtnClick(_ sender: UIButton) {
            
            let locationPicker = SwiftLocationPicker("广东省","广州市",title:"城市选择") { address in
                self.locationLabel.text = address
            }
            locationPicker.isAppearLociton = true
            locationPicker.show()
            
        }
        
        @IBAction func level3BtnClick(_ sender: UIButton) {
            
            let locationPicker = SwiftLocationPicker("广东省","广州市","天河区") { address in
                self.locationLabel.text = address
            }
            locationPicker.show()
            
            
    //        let locationPicker2 = SwiftLocationPicker(.level3(province: "广东省", city: "广州市", town: "天河区")) { address in
    //            self.locationLabel.text = address
    //        }
    //        locationPicker2.show()
        }
    }






