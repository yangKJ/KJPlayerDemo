//
//  BaseViewController.swift
//  KJPlayerDemo_Example
//
//  Created by 77。 on 2021/12/23.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    lazy var backBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(image: UIImage.init(named: "base_black_back"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(BaseViewController.backAction))
        barButton.imageInsets.left = 5
        return barButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = self.backBarButton
    }
    
    @objc dynamic open func backAction() {
        if (self.navigationController?.childViewControllers[0] == self) {
            self.dismiss(animated: true, completion:nil)
            return;
        }
        self.navigationController?.popViewController(animated: true)
    }
}
