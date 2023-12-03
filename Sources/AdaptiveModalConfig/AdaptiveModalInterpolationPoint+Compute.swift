//
//  AdaptiveModalInterpolationPoint+Compute.swift
//  
//
//  Created by Dominic Go on 8/9/23.
//

import UIKit
import ComputableLayout
import DGSwiftUtilities

extension AdaptiveModalInterpolationPoint {
  
  static func compute(
    usingConfig modalConfig: AdaptiveModalConfig,
    usingContext context: ComputableLayoutValueContext,
    snapPoints: [AdaptiveModalSnapPointConfig]? = nil,
    shouldCheckForPercentCollision: Bool = true
  ) -> [Self] {
    
    // TODO: WIP/Temp - To be removed
    // * Only for testing
    
    let items = AdaptiveModalResolvedInterpolationPoint.compute(
      usingConfig: modalConfig,
      usingContext: context
    );
    
    return items.map {
      $0.interpolationPoint;
    };
  };
};
