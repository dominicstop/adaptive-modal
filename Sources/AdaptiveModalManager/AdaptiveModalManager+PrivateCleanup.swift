//
//  AdaptiveModalManager+PrivateCleanup.swift
//  
//
//  Created by Dominic Go on 12/1/23.
//

import UIKit

extension AdaptiveModalManager {

 func _clearGestureValues() {
    self._modalSecondaryAxisValue = nil;
    
    self.gestureOffset = nil;
    self.gestureVelocity = nil;
    
    self.gesturePointPrev = nil;
    self.gesturePoint = nil;
    self.gestureInitialPoint = nil;
  };
  
  func _clearAnimators() {
    self.backgroundVisualEffectAnimator?.clear();
    self.backgroundVisualEffectAnimator = nil;
    
    self.modalBackgroundVisualEffectAnimator?.clear();
    self.modalBackgroundVisualEffectAnimator = nil;
    
    self._stopModalAnimator();
    self._modalAnimator = nil;
  };
  
  func _clearLayoutKeyboardValues(){
    self._layoutKeyboardValues = nil;
    self._isKeyboardVisible = false;
  };
  
  func _removeObservers(){
    let notificationNames = [
      UIResponder.keyboardWillShowNotification,
      UIResponder.keyboardDidShowNotification,
      UIResponder.keyboardWillHideNotification,
      UIResponder.keyboardDidHideNotification,
      UIResponder.keyboardWillChangeFrameNotification,
      UIResponder.keyboardDidChangeFrameNotification,
    ];
    
    notificationNames.forEach {
      NotificationCenter.default.removeObserver(self, name: $0, object: nil);
    };
    
    NotificationCenter.default.removeObserver(self);
  };
  
  func _cleanupViewControllers(){
    defer {
      self.modalWrapperViewController = nil;
      self.modalViewController = nil;
      self.presentingViewController = nil;
    };
  
    guard self.modalWrapperViewController != nil,
          let modalVC = self.modalViewController
    else { return };
  
    modalVC.willMove(toParent: nil);
    modalVC.removeFromParent();
    modalVC.view.removeFromSuperview();
  };
  
  func _cleanupViews() {
    let viewsToCleanup: [UIView?] = [
      self.dummyModalView,
      self.modalWrapperLayoutView,
      // self.modalWrapperTransformView,
      self.modalDragHandleView,
      self.modalWrapperShadowView,
      // self.modalContentWrapperView,
      // self.modalView,
      self.modalBackgroundView,
      self.modalBackgroundVisualEffectView,
      self.backgroundDimmingView,
      self.backgroundVisualEffectView
    ];
    
    viewsToCleanup.forEach {
      guard let view = $0 else { return };
      
      view.removeAllAncestorConstraints();
      view.removeFromSuperview();
    };
    
    self.rootView = nil;
    self.dummyModalView = nil;
    
    self.modalWrapperLayoutView = nil;
    self.modalWrapperTransformView = nil;
    self.modalWrapperShadowView = nil;
    self.modalContentWrapperView = nil;
    
    self.modalDragHandleView = nil;
    self.modalBackgroundView = nil;
    self.modalBackgroundVisualEffectView = nil;
    self.backgroundDimmingView = nil;
    self.backgroundVisualEffectView = nil;
    
    self.modalConstraintLeft = nil;
    self.modalConstraintRight = nil;
    self.modalConstraintTop = nil;
    self.modalConstraintBottom = nil;
    
    self.modalDragHandleConstraintOffset = nil;
    self.modalDragHandleConstraintCenter = nil;
    self.modalDragHandleConstraintHeight = nil;
    self.modalDragHandleConstraintWidth = nil;
    
    
    self._didTriggerSetup = false;
  };
  
  func _cleanupSnapPointOverride(){
    self.isOverridingSnapPoints = false;

    self.overrideSnapPoints = nil;
    self.overrideInterpolationPoints = nil;
    
    self.currentOverrideInterpolationIndex = 0;
    self.prevOverrideInterpolationIndex = 0;
    self.nextOverrideInterpolationIndex = nil;
  };
 
  func _cleanup() {
    self.modalFrame = .zero;
    self.prevModalFrame = .zero;
    self.prevTargetFrame = .zero;
    
    self._clearAnimators();
    self._clearLayoutKeyboardValues();
    
    self._cleanupViews();
    
    self._cleanupSnapPointOverride();
    self._removeObservers();
    self._endDisplayLink();
    
    self.currentInterpolationIndex = 0;
    self._modalSecondaryAxisValue = nil;
    
    self._shouldResetRangePropertyAnimators = false;
    self._pendingCurrentModalConfigUpdate = false;
    
    self.rangeAnimatorMode = .modalPosition;
    self._currentModalConfig = nil;
    
    #if DEBUG
    self.debugView?.notifyDidCleanup();
    #endif
  };
};
