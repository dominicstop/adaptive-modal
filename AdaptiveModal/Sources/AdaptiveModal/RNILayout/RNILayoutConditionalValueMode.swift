//
//  RNILayoutConditionalValueMode.swift
//
//  Created by Dominic Go on 6/24/23.
//

import Foundation

public enum RNILayoutValueEvaluableCondition: Equatable {

  case isNilOrZero(_ value: RNILayoutValueMode);
  
  case keyboardPresent;
  
  func evaluate(usingContext context: RNILayoutValueContext) -> Bool {
    switch self {
      case let .isNilOrZero(layoutValueMode):
        let layoutValue = layoutValueMode.compute(
          usingLayoutValueContext: context
        );
      
        return (layoutValue == nil || layoutValue == 0);
    
      case .keyboardPresent:
        return context.keyboardScreenRect != nil;
    };
  };
};
