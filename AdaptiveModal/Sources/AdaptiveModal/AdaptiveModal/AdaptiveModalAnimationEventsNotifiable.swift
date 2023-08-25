//
//  AdaptiveModalAnimationEventsNotifiable.swift
//  
//
//  Created by Dominic Go on 7/27/23.
//

import UIKit

/// Allows the type that conforms to this protocol to get notified of
/// animation-related modal events.
///
public protocol AdaptiveModalAnimationEventsNotifiable: AnyObject {

  func notifyOnModalAnimatorStart(
    sender: AdaptiveModalManager,
    animator: UIViewPropertyAnimator?,
    interpolationPoint: AdaptiveModalInterpolationPoint,
    isAnimated: Bool
  );
  
  func notifyOnModalAnimatorPercentChanged(
    sender: AdaptiveModalManager,
    percent: CGFloat
  );
  
  func notifyOnModalAnimatorStop(
    sender: AdaptiveModalManager
  );
  
  func notifyOnModalAnimatorCompletion(
    sender: AdaptiveModalManager,
    position: UIViewAnimatingPosition
  );
};
