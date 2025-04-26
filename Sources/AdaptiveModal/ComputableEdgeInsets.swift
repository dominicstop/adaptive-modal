//
//  ComputableEdgeInsets.swift
//  AdaptiveModal
//
//  Created by Dominic Go on 4/26/25.
//

import ComputableLayout
import UIKit


public enum ComputableEdgeInsets: Equatable {
  case edgeInsets(UIEdgeInsets);
  
  case layoutValue(
    top   : ComputableLayoutValue,
    left  : ComputableLayoutValue,
    bottom: ComputableLayoutValue,
    right : ComputableLayoutValue
  );
  
  func compute(
    usingLayoutValueContext context: ComputableLayoutValueContext
  ) -> UIEdgeInsets {
    
    switch self {
      case let .edgeInsets(edgeInsets):
        return edgeInsets;
        
      case let .layoutValue(top, left, bottom, right):
      
        let computedValueTop = top.computeValue(
          usingLayoutValueContext: context,
          preferredSizeKey: nil
        );
        
        let computedValueLeft = left.computeValue(
          usingLayoutValueContext: context,
          preferredSizeKey: nil
        );
        
        let computedValueBottom = bottom.computeValue(
          usingLayoutValueContext: context,
          preferredSizeKey: nil
        );
        
        let computedValueRight = right.computeValue(
          usingLayoutValueContext: context,
          preferredSizeKey: nil
        );
        
        return .init(
          top   : computedValueTop    ?? 0,
          left  : computedValueLeft   ?? 0,
          bottom: computedValueBottom ?? 0,
          right : computedValueRight  ?? 0
        );
    };
  };
};
