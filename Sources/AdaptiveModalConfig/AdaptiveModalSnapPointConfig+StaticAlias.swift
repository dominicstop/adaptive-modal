//
//  AdaptiveModalSnapPointConfig+StaticAlias.swift
//
//
//  Created by Dominic Go on 1/25/24.
//

import Foundation
import ComputableLayout


public extension AdaptiveModalSnapPointConfig {
  
  static func snapPoint(
    key: String? = nil,
    layoutConfig: ComputableLayout,
    keyframeConfig: AdaptiveModalKeyframeConfig? = nil
  ) -> Self {
    
    return Self.init(
      key: key,
      type: .standard(
        layoutConfig: layoutConfig
      ),
      keyframeConfig: keyframeConfig
    );
  };
};
