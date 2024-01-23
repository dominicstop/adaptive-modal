//
//  AdaptiveModalSnapPointConfig.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/23/23.
//

import UIKit
import ComputableLayout


public struct AdaptiveModalSnapPointConfig: Equatable {
  
  public var mode: AdaptiveModalSnapPointMode;
  public var layoutConfig: ComputableLayout;
  public var keyframeConfig: AdaptiveModalKeyframeConfig?;
  
  public var key: String?;
  
  // MARK: Init
  // ----------
  
  public init(
    key: String? = nil,
    mode: AdaptiveModalSnapPointMode = .standard,
    layoutConfig: ComputableLayout,
    keyframeConfig: AdaptiveModalKeyframeConfig? = nil
  ) {
  
    self.key = key;
    self.mode = mode;
    self.layoutConfig = layoutConfig;
    self.keyframeConfig = keyframeConfig;
  };
  
  public init(
    key: String? = nil,
    mode: AdaptiveModalSnapPointMode = .standard,
    fromSnapPointPreset snapPointPreset: AdaptiveModalSnapPointPreset,
    fromBaseLayoutConfig baseLayoutConfig: ComputableLayout
  ) {
  
    let snapPointLayoutPreset = snapPointPreset.layoutPreset;
    
    let snapPointLayout = snapPointLayoutPreset.getLayoutConfig(
      fromBaseLayoutConfig: baseLayoutConfig
    );
    
    self.init(
      key: key,
      mode: mode,
      layoutConfig: snapPointLayout,
      keyframeConfig: snapPointPreset.keyframeConfig
    );
  };
  
  public init(
    fromBase base: Self,
    newSnapPoint: ComputableLayout? = nil,
    newAnimationKeyframe: AdaptiveModalKeyframeConfig? = nil
  ) {
  
    let layoutConfig = newSnapPoint ?? base.layoutConfig;
    let keyframeConfig = newAnimationKeyframe ?? base.keyframeConfig;
    
    self.init(
      key: base.key,
      mode: base.mode,
      layoutConfig: layoutConfig,
      keyframeConfig: keyframeConfig
    );
  };
};
