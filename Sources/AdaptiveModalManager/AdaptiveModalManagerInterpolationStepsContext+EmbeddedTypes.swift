//
//  AdaptiveModalManagerInterpolationStepsContext+EmbeddedTypes.swift
//  
//
//  Created by Dominic Go on 12/3/23.
//

import Foundation
import ComputableLayout

enum AdaptiveModalManagerInterpolationMode<T> {
  
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
  
  init?(
    usingModalConfig modalConfig: AdaptiveModalConfig,
    usingContext context: ComputableLayoutValueContext
  ) where T == [AdaptiveModalResolvedInterpolationPoint] {
    
    self = .config(
      .Element.compute(
        usingConfig: modalConfig,
        usingContext: context
      )
    );
  };
};

extension AdaptiveModalManagerInterpolationMode
  where T == [AdaptiveModalResolvedInterpolationPoint]  {

  mutating func computeInterpolationPoints(
    usingModalConfig modalConfig: AdaptiveModalConfig,
    usingContext context: ComputableLayoutValueContext,
    snapPoints: [AdaptiveModalSnapPointConfig]
  ) where T == [AdaptiveModalResolvedInterpolationPoint] {
    
    let oldCopy = self;
    
    self.associatedValue = .Element.compute(
      usingConfig: modalConfig,
      usingContext: context,
      snapPoints: oldCopy.associatedValue.snapPoints
    );
  };
};
