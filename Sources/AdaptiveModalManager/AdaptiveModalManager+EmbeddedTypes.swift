//
//  AdaptiveModalManager+EmbeddedTypes.swift
//  
//
//  Created by Dominic Go on 12/1/23.
//

import Foundation


extension AdaptiveModalManager {

  // MARK: - Public Embedded Types
  // -----------------------------
  
  public enum PresentationState {
    case presenting, dismissing, none;
  };
  
  // MARK: - Internal-Only Embedded Types
  // ------------------------------------
  
  /// `self.hideModal` param
  enum HideModalMode: Equatable {
    case direct, inBetween;
    
    case snapPointPreset(AdaptiveModalSnapPointPreset);
    case keyframe(AdaptiveModalKeyframeConfig);
  };
  
  enum ModalRangePropertyAnimatorMode: Equatable {
    case modalPosition;
    case animatorFractionComplete;
  };
  
  typealias InterpolationContext = AdaptiveModalInterpolationContext;
  
  typealias InterpolationMode = AdaptiveModalInterpolationMode;
  
  typealias InterpolationStep = AdaptiveModalInterpolationStep;
  
  typealias InterpolationStepItem = AdaptiveModalInterpolationStepItem;
};
