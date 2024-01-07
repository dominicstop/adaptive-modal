//
//  AdaptiveModalManager+PrivateEvents.swift
//  
//
//  Created by Dominic Go on 12/1/23.
//

import UIKit

extension AdaptiveModalManager {

  func _notifyOnCurrentModalConfigDidChange(){
    self.presentationEventsDelegate.invoke {
      $0.notifyOnCurrentModalConfigDidChange(
        sender: self,
        currentModalConfig: self.currentModalConfig,
        prevModalConfig: self.prevModalConfig
      );
    };
  };
  
  func _notifyOnModalWillSnap(shouldSetState: Bool) {
    let prevIndex = self.onModalWillSnapPrevIndex
      ?? self.currentInterpolationIndex;
      
    let nextIndexRaw: Int = {
      if let nextIndex = self.nextInterpolationIndex {
        return nextIndex;
      };
    
      let closestSnapPoint = self._getClosestSnapPoint();
      
      return closestSnapPoint?.interpolationPoint.snapPointIndex
        ?? self.currentInterpolationIndex;
    }();
    
    let nextIndex = self._adjustInterpolationIndex(for: nextIndexRaw);
    let nextInterpolationPoint = self.interpolationSteps[nextIndex];
    let nextSnapPointConfig = self.currentSnapPoints[nextIndex];
    
    guard prevIndex != nextIndex else { return };
    self.onModalWillSnapPrevIndex = nextIndex;
    
    let isDismissingToUnderShootSnapPoint =
         self.shouldDismissModalOnSnapToUnderShootSnapPoint
      && nextIndex == 0;
      
    let isDismissingToOverShootSnapPoint =
         self.shouldDismissModalOnSnapToOverShootSnapPoint
      && nextIndex == self.currentModalConfig.overshootSnapPointIndex;
    
    let isPresenting =
         self.currentInterpolationIndex == 0
      && nextIndex == 1;
      
    let isDismissing =
         isDismissingToUnderShootSnapPoint
      || isDismissingToOverShootSnapPoint;
      
    let nextState: AdaptiveModalState? = {
      if isDismissing {
        return self.modalState.isProgrammatic
          ? .DISMISSING_PROGRAMMATIC
          : .DISMISSING_GESTURE
      };
      
      if isPresenting {
        return self.modalState.isProgrammatic
          ? .PRESENTING_PROGRAMMATIC
          : .PRESENTING_GESTURE;
      };
      
      if self.isSwiping {
        return .GESTURE_DRAGGING;
      };
      
      if !self.isSwiping {
        return self.modalState.isProgrammatic
          ? .SNAPPING_PROGRAMMATIC
          : .SNAPPING_FROM_GESTURE_DRAGGING;
      };
      
      return nil;
    }();
    
    if shouldSetState,
       let nextState = nextState {
       
      self.modalStateMachine.setState(nextState);
    };
    
    /// Note:2023-09-23-23-01-02
    /// * `maskedCorners` cannot be animated, so we apply the next corner mask
    ///    immediately to make it less noticeable
    block:
    if let modalContentWrapperView = self.modalContentWrapperView {
      let maskCountCurrent = modalContentWrapperView.layer.maskedCorners.count;
      let maskCountNext = nextInterpolationPoint.modalMaskedCorners.count;
      
      // corner mask precedence
      // apply the next corner mask only if has more masked corners
      guard maskCountNext > maskCountCurrent else { break block };
      modalContentWrapperView.layer.maskedCorners = nextInterpolationPoint.modalMaskedCorners;
     
      if let modalBgEffectView = self.modalBackgroundVisualEffectView {
        modalBgEffectView.layer.maskedCorners = nextInterpolationPoint.modalMaskedCorners;
      };
    };
    
    self.presentationEventsDelegate.invoke {
      $0.notifyOnModalWillSnap(
        sender: self,
        prevSnapPointIndex: prevIndex,
        nextSnapPointIndex: nextIndex,
        prevSnapPointConfig: self.prevSnapPointConfig,
        nextSnapPointConfig: nextSnapPointConfig,
        prevInterpolationPoint: self.prevInterpolationStep,
        nextInterpolationPoint: nextInterpolationPoint
      );
    };
  };
  
  func _notifyOnModalDidSnap(shouldSetState: Bool) {
    self._clearAnimators();
    
    #if DEBUG
    self.debugView?.notifyOnModalDidSnap();
    #endif
    
    self.nextInterpolationIndex = nil;
      
    self.currentInterpolationStep.applyConfig(toModalManager: self);
    
    let shouldDismissOnSnapToUnderShootSnapPoint =
      self.currentInterpolationIndex == 0 &&
      self.shouldDismissModalOnSnapToUnderShootSnapPoint;
      
    let shouldDismissOnSnapToOverShootSnapPoint =
      self.currentInterpolationIndex == self.currentModalConfig.overshootSnapPointIndex &&
      self.shouldDismissModalOnSnapToOverShootSnapPoint;
    
    let shouldDismiss =
      shouldDismissOnSnapToUnderShootSnapPoint ||
      shouldDismissOnSnapToOverShootSnapPoint;
      
    let isPresenting =
         self.modalState.isPresenting
      || self.currentInterpolationIndex == 1
      && self.prevInterpolationIndex == 0;
      
    let nextState: AdaptiveModalState? = {
      if shouldDismiss {
        return self.modalState.isProgrammatic
          ? .DISMISSED_PROGRAMMATIC
          : .DISMISSED_GESTURE
      };
      
      if isPresenting {
        return self.modalState.isProgrammatic
          ? .PRESENTED_PROGRAMMATIC
          : .PRESENTED_GESTURE
      };
      
      return nil;
    }();
    
    if shouldSetState,
       let nextState = nextState {
       
      self.modalStateMachine.setState(nextState);
    };
    
    if self.shouldClearOverrideSnapPoints {
      self._cleanupSnapPointOverride();
    };
    
    self.presentationEventsDelegate.invoke {
      $0.notifyOnModalDidSnap(
        sender: self,
        prevSnapPointIndex: self.prevInterpolationIndex,
        currentSnapPointIndex: self.currentSnapPointIndex,
        prevSnapPointConfig: self.prevSnapPointConfig,
        currentSnapPointConfig: self.currentSnapPointConfig,
        prevInterpolationPoint: self.prevInterpolationStep,
        currentInterpolationPoint: self.currentInterpolationStep
      );
    };
  };
  
  func _notifyOnModalWillShow(){
    self.presentationEventsDelegate.invoke {
      $0.notifyOnAdaptiveModalWillShow(sender: self);
    };
  };
  
  func _notifyOnModalDidShow(){
    //self.modalState = .presented;
    self.presentationEventsDelegate.invoke {
      $0.notifyOnAdaptiveModalDidShow(sender: self);
    };
  };
  
  func _notifyOnModalWillHide(){
    if self._isKeyboardVisible,
       let modalView = self.modalView {
       
      modalView.endEditing(true);
    };
    
    self.presentationEventsDelegate.invoke {
      $0.notifyOnAdaptiveModalWillHide(sender: self);
    };
  };
  
  func _notifyOnModalDidHide(){
    self._cleanup();
    self._clearGestureValues();
    
    self.modalViewController?.dismiss(animated: false);
    self._cleanupViewControllers();
    
    self.presentationEventsDelegate.invoke {
      $0.notifyOnAdaptiveModalDidHide(sender: self);
    };
  };
  
  func _notifyOnModalStateWillChange(
    _ prevState   : AdaptiveModalState,
    _ currentState: AdaptiveModalState,
    _ nextState   : AdaptiveModalState
  ) {
  
    if nextState.isPresenting {
      self._notifyOnModalWillShow();
      
    } else if nextState.isPresented {
      self._notifyOnModalDidShow();
      
    } else if nextState.isDismissing {
      self._notifyOnModalWillHide();
      
    } else if nextState.isDismissed {
      self._notifyOnModalDidHide();
    };
    
    if prevState.isDismissed && currentState.isPresenting && nextState.isDismissed {
      #if DEBUG
      if self.shouldLogModalStateChanges {
        print("notifyOnModalPresentCancelled");
      };
      #endif
    
      self.presentationEventsDelegate.invoke {
        $0.notifyOnModalPresentCancelled(
          sender: self
        );
      };
      
    } else if currentState.isDismissing && !nextState.isDismissed {
      #if DEBUG
      if self.shouldLogModalStateChanges {
        print("notifyOnModalDismissCancelled");
      };
      #endif
      
      self.presentationEventsDelegate.invoke {
        $0.notifyOnModalDismissCancelled(
          sender: self
        );
      };
    };
    
    self.stateEventsDelegate.invoke {
      $0.notifyOnModalStateWillChange(
        sender: self,
        prevState: prevState,
        currentState: currentState,
        nextState: nextState
      );
    };
    
    #if DEBUG
    if self.shouldLogModalStateChanges {
      print(
        "onStateChangeBlock:",
        prevState, "->", currentState, "->", nextState
      );
    };
    #endif
  };
};
