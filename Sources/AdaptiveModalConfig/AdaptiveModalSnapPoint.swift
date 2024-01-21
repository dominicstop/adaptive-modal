//
//  AdaptiveModalSnapPoint.swift
//  
//
//  Created by Dominic Go on 1/21/24.
//

import Foundation
import ComputableLayout


public struct AdaptiveModalSnapPoint: Equatable {
  
  public var index: Int;
  public var key: String?;
  
  public var mode: AdaptiveModalSnapPointMode;
  public var type: AdaptiveModalSnapPointType;
  
  public var layoutConfig: ComputableLayout;
  public var keyframeConfig: AdaptiveModalKeyframeConfig?;
  
  // MARK: - Init
  // ------------
  
  public init(
    index: Int,
    key: String?,
    mode: AdaptiveModalSnapPointMode,
    type: AdaptiveModalSnapPointType,
    layoutConfig: ComputableLayout,
    keyframeConfig: AdaptiveModalKeyframeConfig?
  ) {
  
    self.index = index;
    self.key = key;
    self.mode = mode;
    self.type = type;
    self.layoutConfig = layoutConfig;
    self.keyframeConfig = keyframeConfig;
  };
  
  public init(
    fromSnapPointConfig snapPointConfig: AdaptiveModalSnapPointConfig,
    index: Int,
    type: AdaptiveModalSnapPointType
  ){
    
    self.index = index;
    self.key = snapPointConfig.key;
    
    self.mode = snapPointConfig.mode;
    self.type = type;
    
    self.layoutConfig = snapPointConfig.layoutConfig;
    self.keyframeConfig = snapPointConfig.keyframeConfig;
  };
};
