//
//  AdaptiveModalManagerInterpolationMode.swift
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
  
  /// The name of the enum case as a string
  var memberName: String {
    switch self {
      case .config(_):
        return "config";
        
      case .overrideSnapPoint(_):
        return "overrideSnapPoint";
    };
  };
  
  var description: String {
    self.memberName;
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
  
  func createNew<U>(
    wrappingItem item: U
  ) -> AdaptiveModalManagerInterpolationMode<U> {
  
    switch self {
      case .config:
        return .config(item);
        
      case .overrideSnapPoint:
        return .overrideSnapPoint(item);
    };
  };
};

extension AdaptiveModalManagerInterpolationMode
  where T == AdaptiveModalManager.InterpolationStepsContext.Items {

  mutating func computeInterpolationPoints(
    usingModalConfig modalConfig: AdaptiveModalConfig,
    usingContext context: ComputableLayoutValueContext,
    snapPoints: [AdaptiveModalSnapPointConfig]? = nil
  ) {
    
    let oldCopy = self;
    let snapPoints = snapPoints ?? oldCopy.associatedValue.snapPoints;
    
    self.associatedValue = .Element.compute(
      usingConfig: modalConfig,
      usingContext: context,
      snapPoints: snapPoints
    );
  };
  
  func getMatchingItem(
    forModeItem modeItem: AdaptiveModalManager.InterpolationStepsContext.ModeItem
  ) -> AdaptiveModalManager.InterpolationStepsContext.ModeItem? {
  
    guard self.memberName != modeItem.memberName else { return nil };
    
    let match = self.associatedValue.first {
      $0.index == modeItem.associatedValue.index;
    };
    
    guard let match = match else { return nil };
    return self.createNew(wrappingItem: match);
  };
  
  func contains(
    modeItem: AdaptiveModalManager.InterpolationStepsContext.ModeItem
  ) -> Bool {
    
    let match = self.getMatchingItem(forModeItem: modeItem);
    return match != nil;
  };
};
