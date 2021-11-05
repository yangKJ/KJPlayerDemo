//
//  HomePagerViewCell.swift
//  KJPlayer_Example
//
//  Created by 77。 on 2021/11/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import KJPlayer
import FSPagerView

@objc open class HomePagerViewCell: FSPagerViewCell {
    
    static let className = "HomePagerViewCell"
    @objc static let reuseIdentifier = className
    
//    typealias PlayButtonBlock = () -> Bool
//    public var playBlock: PlayButtonBlock
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    private func setupUI() {
        self.imageView?.contentMode = .scaleAspectFill
        self.imageView?.layer.masksToBounds = true
        self.textLabel?.font = UIFont.systemFont(ofSize: 14)
        self.textLabel?.textAlignment = .right
        self.contentView.addSubview(self.playButton)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.playButton.center = self.imageView!.center
    }
    
    // MARK: - lazy
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.setTitle("\u{e719}", for: .normal)
        button.setTitle("\u{e71a}", for: .selected)
        button.titleLabel?.font = KJPlayerPod.iconFont(ofSize: 40)
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        return button
    }()
    
    // MARK: - setter
    @objc var dataModel: HomdeModel! {
        didSet {
            guard let model = dataModel else { return }
            self.imageView?.image = (model.image != nil) ? model.image : UIImage.init(named: "8")
            self.textLabel?.text = model.title
            self.playButton.isHidden = !(model.type == .video)
            self.playButton.isSelected = model.isPlay
        }
    }
    
    // MARK: - action
    @objc private func playAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        dataModel.isPlay = button.isSelected
    }
    
}
