//
//  AdaptiveModalBackgroundTapDelegate.swift
//  
//
//  Created by Dominic Go on 7/27/23.
//

import UIKit

public protocol AdaptiveModalBackgroundTapDelegate: AnyObject {
  
  func notifyOnBackgroundTapGesture(sender: UIGestureRecognizer);
};
