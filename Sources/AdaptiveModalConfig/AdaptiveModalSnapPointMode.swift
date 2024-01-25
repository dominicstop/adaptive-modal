//
//  AdaptiveModalSnapPointMode.swift
//  
//
//  Created by Dominic Go on 1/21/24.
//

import Foundation
import ComputableLayout

public enum AdaptiveModalSnapPointMode: Equatable {

  case standard(layoutConfig: ComputableLayout);
  case inBetween(layoutConfig: ComputableLayout?);
  
  // MARK: - Computed Properties
  // ---------------------------
  
  public var layoutConfig: ComputableLayout? {
    switch self {
      case let .standard(layoutConfig):
        return layoutConfig;
        
      case let .inBetween(layoutConfig):
        return layoutConfig;
    };
  };
  
  public var isStandard: Bool {
    switch self {
      case .standard:
        return true;
        
      default:
        return false;
    };
  };
  
  public var isInBetween: Bool {
    switch self {
      case .inBetween:
        return true;
        
      default:
        return false;
    };
  };
};
