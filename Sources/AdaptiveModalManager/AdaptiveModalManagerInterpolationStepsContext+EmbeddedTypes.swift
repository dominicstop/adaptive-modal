//
//  AdaptiveModalManagerInterpolationStepsContext+EmbeddedTypes.swift
//  
//
//  Created by Dominic Go on 12/3/23.
//

import Foundation
import ComputableLayout

extension AdaptiveModalManagerInterpolationStepsContext {

  // MARK: - InterpolationMode
  // -------------------------

  enum InterpolationMode<T: Equatable>: Equatable, CustomStringConvertible {
  
    // MARK: Enum Members
    // ------------------
    
    case config(T);
    case overrideSnapPoint(T);
    
    // MARK: Computed Properties - Alias
    // ---------------------------------
    
    var isConfig: Bool {
      if case .overrideSnapPoint = self {
        return true;
      };
      
      return false;
    };
    
    var isOverrideSnapPoint: Bool {
      if case .overrideSnapPoint = self {
        return true;
      };
      
      return false;
    };
    
    // MARK: Computed Properties
    // -------------------------
    
    var associatedValue: T {
      get {
        switch self {
          case let .config(value):
            return value;
            
          case let .overrideSnapPoint(value):
            return value;
        };
      }
      set {
        switch self {
          case .config:
            self = .config(newValue);
            
          case .overrideSnapPoint:
            self = .overrideSnapPoint(newValue);
        };
      }
    };
    
    var description: String {
      switch self {
        case .config(_):
          return "config";
          
        case .overrideSnapPoint(_):
          return "overrideSnapPoint";
      };
    };
  };
  
  // MARK: - CurrentModeMetadata
  // ---------------------------
  
  struct CurrentModeMetadata: Equatable {
  
    // MARK: Properties
    // ----------------
  
    var snapPoints: [AdaptiveModalSnapPointConfig];
    var interpolationSteps: [AdaptiveModalInterpolationPoint];
    
    var hasOvershootSnapPoint: Bool {
      self.snapPoints.contains {
        $0.key == .overshootPoint;
      };
    };
    
    // MARK: Init
    // ----------
    
    init(
      snapPoints: [AdaptiveModalSnapPointConfig],
      interpolationSteps: [AdaptiveModalInterpolationPoint]
    ) {
    
      self.snapPoints = snapPoints
      self.interpolationSteps = interpolationSteps
    };
    
    init(
      usingModalConfig modalConfig: AdaptiveModalConfig,
      usingContext context: ComputableLayoutValueContext
    ) {
    
      self.snapPoints = modalConfig.snapPoints;
      
      self.interpolationSteps = .Element.compute(
        usingConfig: modalConfig,
        usingContext: context
      );
    };
  };
  
  // MARK: - InterpolationPointMetadata
  // ----------------------------------
  
  struct InterpolationPointMetadata: Equatable {
  
    // MARK: Properties
    // ----------------
    
    var snapPoint: AdaptiveModalSnapPointConfig;
    var interpolationPoint: AdaptiveModalInterpolationPoint;
    
    // MARK: Init
    // ----------
    
    init(
      snapPoint: AdaptiveModalSnapPointConfig,
      interpolationPoint: AdaptiveModalInterpolationPoint
    ) {
      self.snapPoint = snapPoint
      self.interpolationPoint = interpolationPoint
    };
    
    init?(
      modeMetadata: CurrentModeMetadata,
      snapPointKey: AdaptiveModalSnapPointConfig.SnapPointKey
    ) {
      
      let snapPointMatch =
        modeMetadata.snapPoints.first(forSnapPointKey: snapPointKey);
      
      guard let snapPointMatch = snapPointMatch else { return nil };
      self.snapPoint = snapPointMatch;
      
      let interpolationPointMatch =
        modeMetadata.interpolationSteps.first(forSnapPointKey: snapPointKey);
    
      guard let interpolationPointMatch = interpolationPointMatch else { return nil };
      self.interpolationPoint = interpolationPointMatch;
    };
  };
};
