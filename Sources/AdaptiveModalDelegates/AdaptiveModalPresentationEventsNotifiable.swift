//
//  AdaptiveModalEventNotifiable.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 6/4/23.
//

import UIKit


/// Allows the type that conforms to this protocol to get notified of modal
/// presentation-related events.
/// 
public protocol AdaptiveModalPresentationEventsNotifiable: AnyObject {

  func notifyOnModalWillSnap(
    sender: AdaptiveModalManager,
    prevInterpolationStep: AdaptiveModalInterpolationStep?,
    nextInterpolationStep: AdaptiveModalInterpolationStep
  );
  
  func notifyOnModalDidSnap(
    sender: AdaptiveModalManager,
    prevInterpolationStep: AdaptiveModalInterpolationStep?,
    currentInterpolationStep: AdaptiveModalInterpolationStep
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
  
  func notifyOnModalPresentCancelled(
    sender: AdaptiveModalManager
  );
  
  func notifyOnModalDismissCancelled(
    sender: AdaptiveModalManager
  );
  
  func notifyOnCurrentModalConfigDidChange(
    sender: AdaptiveModalManager,
    currentModalConfig: AdaptiveModalConfig?,
    prevModalConfig: AdaptiveModalConfig?
  );
};
