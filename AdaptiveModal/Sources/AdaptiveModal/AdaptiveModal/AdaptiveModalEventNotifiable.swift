//
//  AdaptiveModalEventNotifiable.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 6/4/23.
//

import UIKit


public protocol AdaptiveModalEventNotifiable: AnyObject {
  
  func notifyOnModalWillSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    nextSnapPointIndex: Int,
    snapPointConfig: AdaptiveModalSnapPointConfig,
    interpolationPoint: AdaptiveModalInterpolationPoint
  );
  
  func notifyOnModalDidSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    currentSnapPointIndex: Int,
    snapPointConfig: AdaptiveModalSnapPointConfig,
    interpolationPoint: AdaptiveModalInterpolationPoint
  );
  
  func notifyOnAdaptiveModalWillShow(
    sender: AdaptiveModalManager
  );
  
  func notifyOnAdaptiveModalDidShow(
    sender: AdaptiveModalManager
  );
  
  func notifyOnAdaptiveModalWillHide(
    sender: AdaptiveModalManager
  );
  
  func notifyOnAdaptiveModalDidHide(
    sender: AdaptiveModalManager
  );
  
  func notifyOnAdaptiveModalDragGesture(
    sender: AdaptiveModalManager,
    gestureRecognizer: UIGestureRecognizer
  );
  
  func notifyOnCurrentModalConfigDidChange(
    sender: AdaptiveModalManager,
    currentModalConfig: AdaptiveModalConfig?,
    prevModalConfig: AdaptiveModalConfig?
  );
};
