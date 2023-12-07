//
//  AdaptiveModalManagerInterpolationMode.swift
//  
//
//  Created by Dominic Go on 12/3/23.
//

import Foundation
import ComputableLayout

enum AdaptiveModalInterpolationMode<T: Equatable>: Equatable {
  
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
  
  func copy<U>(
    newAssociatedValue: U
  ) -> AdaptiveModalInterpolationMode<U> {
  
    switch self {
      case .config:
        return .config(newAssociatedValue);
        
      case .overrideSnapPoint:
        return .overrideSnapPoint(newAssociatedValue);
    };
  };
};
