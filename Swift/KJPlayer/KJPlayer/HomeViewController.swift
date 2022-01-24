//
//  HomeViewController.swift
//  KJPlayer
//
//  Created by abas on 2021/12/14.
//

import UIKit

class HomeViewController: UIViewController {

    lazy var pushButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("online", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()
    
    lazy var localButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("local", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(localAction(_:)), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pushButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        self.pushButton.center = self.view.center
        self.localButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        self.localButton.center = CGPoint(x: self.pushButton.center.x, y: self.pushButton.center.y + 88)
    }
}

//MARK: - actions
extension HomeViewController {
    
    @objc func buttonAction(_ button: UIButton) {
        let vc = DetailViewController.init()
        vc.title = "https://mp4.vjshi.com/2017-11-21/7c2b143eeb27d9f2bf98c4ab03360cfe.mp4"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func localAction(_ button: UIButton) {
        let vc = DetailViewController.init()
        vc.title = "rock.mp4"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

