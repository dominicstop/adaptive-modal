//
//  AdaptiveModalEventNotifiable+Default.swift
//  
//
//  Created by Dominic Go on 8/26/23.
//

import UIKit


extension AdaptiveModalEventNotifiable {
  
  func notifyOnModalWillSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    nextSnapPointIndex: Int,
    snapPointConfig: AdaptiveModalSnapPointConfig,
    interpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    // no-op
  };
  
  func notifyOnModalDidSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    currentSnapPointIndex: Int,
    snapPointConfig: AdaptiveModalSnapPointConfig,
    interpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    // no-op
  };
  
  func notifyOnAdaptiveModalWillShow(
    sender: AdaptiveModalManager
  ) {
    // no-op
  };
  
  func notifyOnAdaptiveModalDidShow(
    sender: AdaptiveModalManager
  ) {
    // no-op
  };
  
  func notifyOnAdaptiveModalWillHide(
    sender: AdaptiveModalManager
  ) {
    // no-op
  };
  
  func notifyOnAdaptiveModalDidHide(
    sender: AdaptiveModalManager
  ) {
    // no-op
  };
  
  func notifyOnModalPresentCancelled(
    sender: AdaptiveModalManager
  ) {
    // no-op
  };
  
  func notifyOnModalDismissCancelled(
    sender: AdaptiveModalManager
  ) {
    // no-op
  };
  
  func notifyOnAdaptiveModalDragGesture(
    sender: AdaptiveModalManager,
    gestureRecognizer: UIGestureRecognizer
  ) {
    // no-op
  };
  
  func notifyOnCurrentModalConfigDidChange(
    sender: AdaptiveModalManager,
    currentModalConfig: AdaptiveModalConfig?,
    prevModalConfig: AdaptiveModalConfig?
  ) {
    // no-op
  };
  
  func notifyOnModalStateWillChange(
    sender: AdaptiveModalManager,
    prevState: AdaptiveModalState,
    currentState: AdaptiveModalState,
    nextState: AdaptiveModalState
  ) {
    // no-op
  };
};
