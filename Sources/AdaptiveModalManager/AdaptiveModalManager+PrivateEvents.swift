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
    let interpolationContext = self.interpolationContext!;
  
    let interpolationStepItemPrev =
         interpolationContext.onModalWillSnapPrevItem
      ?? interpolationContext.interpolationStepItemCurrent;
      
    let interpolationStepItemNext: InterpolationStepItem = {
      if let nextItem = interpolationContext.onModalWillSnapNextItem {
        return nextItem;
      };
      
      let closestSnapPoint = self._getClosestSnapPoint();
      
      return closestSnapPoint?.interpolationStepItem
        ?? interpolationContext.interpolationStepItemCurrent;
    }();
    
    let interpolationStepItemNextAdj: InterpolationStepItem = {
      let nextIndex = self._adjustSnapPointIndex(
        for: interpolationStepItemNext.snapPointIndex
      );
      
      let match = interpolationContext.mode.getMatchingItem(
        forSnapPointIndex: nextIndex
      );
      
      return match ?? interpolationStepItemNext;
    }();
    
    guard interpolationStepItemPrev != interpolationStepItemNext
    else { return };
    
    let snapPointNext = interpolationStepItemNextAdj.snapPointIndex;
    interpolationContext.interpolationStepItemPrev = interpolationStepItemNextAdj;
    
    let isDismissingToUnderShootSnapPoint =
         self.shouldDismissModalOnSnapToUnderShootSnapPoint
      && snapPointNext == 0;
      
    let isDismissingToOverShootSnapPoint =
         self.shouldDismissModalOnSnapToOverShootSnapPoint
      && snapPointNext == self.currentModalConfig.overshootSnapPointIndex;
    
    let isPresenting =
         interpolationContext.snapPointIndexCurrent == 0
      && snapPointNext == 1;
      
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
    
    let interpolationPointNext = interpolationStepItemNextAdj.interpolationPoint;
    
    /// Note:2023-09-23-23-01-02
    /// * `maskedCorners` cannot be animated, so we apply the next corner mask
    ///    immediately to make it less noticeable
    block:
    if let modalContentWrapperView = self.modalContentWrapperView {
      let maskCountCurrent = modalContentWrapperView.layer.maskedCorners.count;
      let maskCountNext = interpolationPointNext.modalMaskedCorners.count;
      
      // corner mask precedence
      // apply the next corner mask only if has more masked corners
      guard maskCountNext > maskCountCurrent else { break block };
      
      modalContentWrapperView.layer.maskedCorners =
        interpolationPointNext.modalMaskedCorners;
     
      if let modalBgEffectView = self.modalBackgroundVisualEffectView {
        modalBgEffectView.layer.maskedCorners =
          interpolationPointNext.modalMaskedCorners;
      };
    };
    
    self.presentationEventsDelegate.invoke {
      $0.notifyOnModalWillSnap(
        sender: self,
        prevInterpolationStep: interpolationStepItemPrev.associatedValue,
        nextInterpolationStep: interpolationStepItemNextAdj.associatedValue
      );
    };
  };
  
  func _notifyOnModalDidSnap(shouldSetState: Bool) {
    let interpolationContext = self.interpolationContext!;
    
    #if DEBUG
    self.debugView?.notifyOnModalDidSnap();
    #endif
    
    interpolationContext.interpolationStepItemNext = nil;
    
    let currentInterpolationPoint =
      interpolationContext.interpolationStepItemCurrent.interpolationPoint;
      
    currentInterpolationPoint.applyConfig(toModalManager: self);
    
    let isSnappedToUndershoot =
      interpolationContext.interpolationStepItemCurrent.isUndershootSnapPoint;
      
    let isSnappedToOvershoot =
      interpolationContext.interpolationStepItemCurrent.isOvershootSnapPoint;
    
    let shouldDismissOnSnapToUnderShootSnapPoint =
         isSnappedToUndershoot
      && self.shouldDismissModalOnSnapToUnderShootSnapPoint;
      
    let shouldDismissOnSnapToOverShootSnapPoint =
         isSnappedToOvershoot
      && self.shouldDismissModalOnSnapToOverShootSnapPoint;
    
    let shouldDismiss =
      shouldDismissOnSnapToUnderShootSnapPoint ||
      shouldDismissOnSnapToOverShootSnapPoint;
      
    let isPresenting = {
      if self.modalState.isPresenting {
        return true;
      };
      
      guard let interpolationStepItemPrev =
              interpolationContext.interpolationStepItemPrev
      else {
        return false
      };
      
      let wasPrevUndershoot =
        interpolationStepItemPrev.isUndershootSnapPoint;
        
      let isCurrentlyNotUndershoot =
        !interpolationContext.interpolationStepItemCurrent.isUndershootSnapPoint;
       
      return wasPrevUndershoot && isCurrentlyNotUndershoot;
    }();
    
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
    
    self.presentationEventsDelegate.invoke {
      $0.notifyOnModalDidSnap(
        sender: self,
        prevInterpolationStep: interpolationContext.interpolationStepPrev,
        currentInterpolationStep: interpolationContext.interpolationStepCurrent
      );
    };
    
    let shouldRevertCurrentModeToConfig = {
      if self.presentationState != .none {
        return false;
      };
    
      return interpolationContext.shouldRevertCurrentModeToConfig(
        nextModeItem: interpolationContext.interpolationStepCurrent
      );
    }();
    
    if shouldRevertCurrentModeToConfig {
      self._cleanupSnapPointOverride();
    };
    
    self._clearAnimators();
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
