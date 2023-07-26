//
//  AdaptiveModalAnimationEventsNotifiable.swift
//  
//
//  Created by Dominic Go on 7/27/23.
//

import UIKit

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
