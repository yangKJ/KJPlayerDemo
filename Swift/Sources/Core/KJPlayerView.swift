//
//  KJPlayerView.swift
//  KJPlayer
//
//  Created by abas on 2021/12/14.
//

import Foundation
import UIKit

@IBDesignable
@objc public class KJPlayerView: UIImageView {
    
    @IBOutlet weak var delegate: KJPlayerBaseViewDelegate?
    
    /// Placeholder image
    public var placeholder: UIImage? = nil
    /// background color
    public var background: CGColor = UIColor.black.cgColor
    /// Video display mode
    public var videoGravity: KJPlayerVideoGravity = .resizeAspect
}
