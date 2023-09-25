//
//  AdaptiveModalManager+UIGestureRecognizerDelegate.swift
//  
//
//  Created by Dominic Go on 8/14/23.
//

import UIKit


extension AdaptiveModalManager: UIGestureRecognizerDelegate {

  public func gestureRecognizerShouldBegin(
    _ gestureRecognizer: UIGestureRecognizer
  ) -> Bool {
  
    guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer
    else { return true };
  
    let currentInterpolationStep = self.currentInterpolationStep;
    
    let secondaryGestureAxisDampingPercent =
      currentInterpolationStep.secondaryGestureAxisDampingPercent;
      
    let isLockedToPrimaryAxis = secondaryGestureAxisDampingPercent >= 1;
    let velocity = panGesture.velocity(in: self.modalView);
    
    let primaryAxisVelocity =
      velocity[keyPath: self.currentModalConfig.inputValueKeyForPoint];
    
    return isLockedToPrimaryAxis
      ? abs(primaryAxisVelocity) > 0
      : true;
  };
  
  public func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
  
    guard let modalView = self.modalView,
          let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
          let modalContentScrollView = self.modalContentScrollView
    else { return false };
    
    let modalContentScrollViewGestures =
      modalContentScrollView.gestureRecognizers ?? [];
      
    guard modalContentScrollViewGestures.contains(otherGestureRecognizer)
    else { return false };
    
    func cancelOtherGesture() {
      otherGestureRecognizer.isEnabled.toggle();
      otherGestureRecognizer.isEnabled.toggle();
    };
    
    let gesturePoint = panGesture.location(in: self.targetView);
    
    let gestureVelocity = panGesture.velocity(in: modalView);
    
    let gestureVelocityCoord = gestureVelocity[
      keyPath: self.currentModalConfig.inputValueKeyForPoint
    ];
      
    let modalContentScrollViewOffset = modalContentScrollView.contentOffset[
      keyPath: self.currentModalConfig.inputValueKeyForPoint
    ];
    
    let modalContentMinScrollViewOffset = modalContentScrollView.minContentOffset[
      keyPath: self.currentModalConfig.inputValueKeyForPoint
    ];
    
    let modalContentMaxScrollViewOffset = modalContentScrollView.maxContentOffset[
      keyPath: self.currentModalConfig.inputValueKeyForPoint
    ];
    
    if !modalContentScrollView.isScrollEnabled {
      return true;
    };
    
    if let modalSwipeGestureEdgeRect = self.modalSwipeGestureEdgeRect,
       modalSwipeGestureEdgeRect.contains(gesturePoint) {
      
      cancelOtherGesture();
      return true;
    };
    
    if modalContentScrollView.isDecelerating {
      return false;
    };
    
    if abs(gestureVelocityCoord) > 500 {
      return false;
    };
    
    if self.allowModalToDragWhenAtMinScrollViewOffset,
       modalContentScrollViewOffset <= modalContentMinScrollViewOffset,
       gestureVelocityCoord > 0 {
      
      cancelOtherGesture();
      return true;
    };
    
    if self.allowModalToDragWhenAtMaxScrollViewOffset,
       modalContentScrollViewOffset >= modalContentMaxScrollViewOffset,
       gestureVelocityCoord < 0 {
    
      return true;
    };
  
    return false;
  };
};
