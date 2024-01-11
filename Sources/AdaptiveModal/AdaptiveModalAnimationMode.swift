//
//  AdaptiveModalAnimationMode.swift
//  
//
//  Created by Dominic Go on 1/11/24.
//

import Foundation


public enum AdaptiveModalAnimationMode {
  
  public static let `default`: Self = .viewPropertyAnimatorContinuous;

  /// Use `UIViewPropertyAnimator` + animation block
  case viewPropertyAnimatorContinuous;
  
  /// Use `UIViewPropertyAnimator` + `CADisplayLink`
  /// Note: Experimental...
  case viewPropertyAnimatorDiscrete;
};
