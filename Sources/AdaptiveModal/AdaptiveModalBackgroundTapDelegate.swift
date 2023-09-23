//
//  AdaptiveModalBackgroundTapDelegate.swift
//  
//
//  Created by Dominic Go on 7/27/23.
//

import UIKit

/// Allows the type that conforms to this protocol to get notified when the
/// modal's background view is tapped.
///
public protocol AdaptiveModalBackgroundTapDelegate: AnyObject {
  
  func notifyOnBackgroundTapGesture(sender: UIGestureRecognizer);
};
