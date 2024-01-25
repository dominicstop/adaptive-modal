//
//  AdaptiveModalSnapPointConfig.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/23/23.
//

import UIKit
import ComputableLayout


public struct AdaptiveModalSnapPointConfig: Equatable {
  
  // MARK: - Properties
  // ------------------
  
  public var key: String?;
  public var mode: AdaptiveModalSnapPointMode;
  public var keyframeConfig: AdaptiveModalKeyframeConfig?;
  
  // MARK: Computed Properties
  // -------------------------
  
  public var layoutConfig: ComputableLayout {
    self.mode.layoutConfig ?? .zero;
  };
  
  // MARK: Init
  // ----------
  
  public init(
    key: String?,
    type: AdaptiveModalSnapPointMode,
    keyframeConfig: AdaptiveModalKeyframeConfig?
  ) {
    
    self.key = key;
    self.mode = type;
    self.keyframeConfig = keyframeConfig;
  };
  
  public init(
    key: String? = nil,
    layoutConfig: ComputableLayout,
    keyframeConfig: AdaptiveModalKeyframeConfig? = nil
  ) {
  
    self.init(
      key: key,
      type: .standard(layoutConfig: layoutConfig),
      keyframeConfig: keyframeConfig
    );
  };
  
  public init(
    key: String? = nil,
    fromSnapPointPreset snapPointPreset: AdaptiveModalSnapPointPreset,
    fromBaseLayoutConfig baseLayoutConfig: ComputableLayout
  ) {
    let snapPointLayoutPreset = snapPointPreset.layoutPreset;
    
    let snapPointLayout = snapPointLayoutPreset.getLayoutConfig(
      fromBaseLayoutConfig: baseLayoutConfig
    );
    
    self.init(
      key: key,
      layoutConfig: snapPointLayout,
      keyframeConfig: snapPointPreset.keyframeConfig
    );
  };
};
