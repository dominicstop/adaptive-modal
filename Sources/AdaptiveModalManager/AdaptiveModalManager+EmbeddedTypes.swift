//
//  AdaptiveModalManager+EmbeddedTypes.swift
//  
//
//  Created by Dominic Go on 12/1/23.
//

import Foundation


extension AdaptiveModalManager {

  // MARK: - Public Embedded Types
  // --------==-------------------
  
  public enum PresentationState: String {
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
  
  enum ModalRangePropertyAnimatorMode: String {
    case modalPosition;
    case animatorFractionComplete;
  };
};
