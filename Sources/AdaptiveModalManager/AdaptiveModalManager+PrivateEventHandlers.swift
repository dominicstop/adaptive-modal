//
//  AdaptiveModalManager+PrivateEventHandlers.swift
//  
//
//  Created by Dominic Go on 12/1/23.
//

import UIKit
import ComputableLayout


extension AdaptiveModalManager {
  
  @objc func _onDragPanGesture(_ sender: UIPanGestureRecognizer) {
    var shouldClearGestureValues = false;
  
    let gesturePoint = sender.location(in: self.rootView);
    self.gesturePoint = gesturePoint;
    
    let gestureVelocity = sender.velocity(in: self.rootView);
    self.gestureVelocity = gestureVelocity;
    
    #if DEBUG
    self.debugView?.notifyOnDragPanGesture(sender);
    #endif
    
    switch sender.state {
      case .began:
        self.gestureInitialPoint = gesturePoint;
        
        if self._isKeyboardVisible,
           self.shouldDismissKeyboardOnGestureSwipe,
           self.interpolationContext.snapPointIndexCurrent <= 1,
           let modalView = self.modalView {
           
          modalView.endEditing(true);
          self._cancelModalGesture();
        };
    
      case .changed:
        if !self._isKeyboardVisible || self.isAnimating {
          self._stopModalAnimator();
        };
        
        self._applyInterpolationToModal(forGesturePoint: gesturePoint);
        self._notifyOnModalWillSnap(shouldSetState: true);
        
        let shouldSetState =
             self.modalState != .PRESENTING_GESTURE
          && self.modalState != .DISMISSING_GESTURE;
          
        if shouldSetState {
          self.modalStateMachine.setState(.GESTURE_DRAGGING);
        };
        
      case .cancelled, .ended:
        defer {
          shouldClearGestureValues = true;
        };
      
        guard self.shouldEnableSnapping else { break };
        let gestureFinalPointRaw = self.gestureFinalPoint ?? gesturePoint;
        
        let gestureFinalPoint =
          self._applyGestureOffsets(forGesturePoint: gestureFinalPointRaw);
          
        let shouldSetState =
             self.modalState != .PRESENTING_GESTURE
          && self.modalState != .DISMISSING_GESTURE;

        self._snapToClosestSnapPoint(
          forPoint: gestureFinalPoint,
          direction: self.gestureDirection,
          shouldSetStateOnSnap: true,
          stateSnapping: (shouldSetState
            ? .SNAPPING_FROM_GESTURE_DRAGGING
            : nil
          ),
          stateSnapped: nil,
          completion: {
            if self.modalState == .SNAPPING_FROM_GESTURE_DRAGGING {
              self.modalStateMachine.setState(.SNAPPED_FROM_GESTURE_DRAGGING);
            };
          }
        );
        
      default:
        break;
    };
    
    self.gestureEventsDelegate.invoke {
      $0.notifyOnAdaptiveModalDragGesture(
        sender: self,
        gestureRecognizer: sender
      );
    };
    
    if shouldClearGestureValues {
      self._clearGestureValues();
    };
  };
  
  @objc func _onDragScreenEdge(_ sender: UIScreenEdgePanGestureRecognizer){
    switch sender.state {
      case .began:
      
        guard let viewControllerProvider = self.viewControllerProvider
        else { return };
        
        let (modalVC, presentingVC) = viewControllerProvider();
        
        self.modalStateMachine.stateOverride = .PRESENTING_GESTURE;
        self.modalStateMachine.setState(.PRESENTING_GESTURE);

        self.presentModal(
          viewControllerToPresent: modalVC,
          presentingViewController: presentingVC,
          snapPointIndex: 0,
          animated: false,
          shouldSetStateOnSnap: false,
          stateSnapping: .PRESENTING_GESTURE,
          stateSnapped: nil
        );
        
        self._onDragPanGesture(sender);
        
      case .ended:
        self.modalStateMachine.stateOverride = nil;
        self._onDragPanGesture(sender);
        
      default:
        self._onDragPanGesture(sender);
    };
  };
  
  @objc func _onBackgroundTapGesture(_ sender: UITapGestureRecognizer) {
    let interpolationContext = self.interpolationContext!;
    
    let currentInterpolationPoint =
      interpolationContext.interpolationStepCurrent.interpolationPoint

    self.backgroundTapDelegate.invoke {
      $0.notifyOnBackgroundTapGesture(sender: sender);
    };
    
    switch currentInterpolationPoint.backgroundTapInteraction {
      case .dismiss:
        self.dismissModal();
      
      default:
        break;
    };
  };
  
  @objc func _onKeyboardWillShow(notification: NSNotification) {
    let interpolationContext = self.interpolationContext!;
    
    guard let keyboardValues = ComputableLayoutKeyboardValues(fromNotification: notification),
          !self.isAnimating
    else { return };
    
    self._isKeyboardVisible = true;
    self._layoutKeyboardValues = keyboardValues;
    
    self._updateCurrentModalConfig();
    self._computeSnapPoints();

    self._animateModal(
      to: interpolationContext.interpolationPointCurrent,
      animationConfigOverride: .animator(keyboardValues.keyboardAnimator)
    );
  };
  
  @objc func _onKeyboardDidShow(notification: NSNotification) {
    guard let keyboardValues = ComputableLayoutKeyboardValues(fromNotification: notification)
    else { return };
    
    self._isKeyboardVisible = true;
    self._layoutKeyboardValues = keyboardValues;
    
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
  };

  @objc func _onKeyboardWillHide(notification: NSNotification) {
    let interpolationContext = self.interpolationContext!;
    
    guard let keyboardValues = ComputableLayoutKeyboardValues(fromNotification: notification),
          !self.isAnimating
    else { return };
    
    self._clearLayoutKeyboardValues();
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
    
    self._animateModal(
      to: interpolationContext.interpolationPointCurrent,
      animationConfigOverride: .animator(keyboardValues.keyboardAnimator),
      extraAnimation: nil
    ) { _ in
    
      self._isKeyboardVisible = false;
    };
  };
  
  @objc func _onKeyboardDidHide(notification: NSNotification) {
    self._isKeyboardVisible = false;
  };
  
  @objc func _onKeyboardWillChange(notification: NSNotification) {
    let interpolationContext = self.interpolationContext!;
    
    guard let keyboardValues = ComputableLayoutKeyboardValues(fromNotification: notification),
          !self.isAnimating
    else { return };
    
    self._layoutKeyboardValues = keyboardValues;
    
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
    
    self._animateModal(
      to: interpolationContext.interpolationPointCurrent,
      animationConfigOverride: .animator(keyboardValues.keyboardAnimator)
    );
  };
  
  @objc func _onKeyboardDidChange(notification: NSNotification) {
    guard let keyboardValues = ComputableLayoutKeyboardValues(fromNotification: notification),
          self.presentationState == .none
    else { return };
    
    self._layoutKeyboardValues = keyboardValues;
    
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
  };
};

