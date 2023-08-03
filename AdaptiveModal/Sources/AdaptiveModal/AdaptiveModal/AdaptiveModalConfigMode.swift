//
//  AdaptiveModalConfigMode.swift
//  
//
//  Created by Dominic Go on 8/2/23.
//

import Foundation


public enum AdaptiveModalConfigMode {
  case staticConfig(AdaptiveModalConfig);
  
  case adaptiveConfig(
    defaultConfig: AdaptiveModalConfig,
    constrainedConfigs: [AdaptiveModalConstrainedConfig]
  );
};
