//
//  AdaptiveModalGestureEventsNotifiable.swift
//  
//
//  Created by Dominic Go on 8/26/23.
//

import UIKit


/// Allows the type that conforms to this protocol to get notified of modal
//  gesture-related events

public protocol AdaptiveModalGestureEventsNotifiable: AnyObject {

  func notifyOnAdaptiveModalDragGesture(
    sender: AdaptiveModalManager,
    gestureRecognizer: UIGestureRecognizer
  );
};
