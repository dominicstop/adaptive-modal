//
//  AdaptiveModalConstrainedConfig.swift
//  
//
//  Created by Dominic Go on 7/27/23.
//

import UIKit


public struct AdaptiveModalConstrainedConfig {
  public var constraints: [RNILayoutEvaluableCondition];
  public var config: AdaptiveModalConfig;
  
  public var identifier: String?;
  
  public init(
    constraints: [RNILayoutEvaluableCondition],
    config: AdaptiveModalConfig,
    identifier: String? = nil
  ) {
    self.constraints = constraints;
    self.config = config;
    self.identifier = identifier;
  }
  
  public func evaluateConstraints(
    usingContext context: RNILayoutEvaluableConditionContext
  ) -> Bool {
  
    return self.constraints.allSatisfy {
      $0.evaluate(usingContext: context);
    };
  };
};

