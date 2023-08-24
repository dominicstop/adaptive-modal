//
//  AdaptiveModalConstrainedConfig.swift
//  
//
//  Created by Dominic Go on 7/27/23.
//

import UIKit
import ComputableLayout;


public struct AdaptiveModalConstrainedConfig {
  public var constraints: [EvaluableCondition];
  public var config: AdaptiveModalConfig;
  
  public var identifier: String?;
  
  public init(
    constraints: [EvaluableCondition],
    config: AdaptiveModalConfig,
    identifier: String? = nil
  ) {
    self.constraints = constraints;
    self.config = config;
    self.identifier = identifier;
  }
  
  public func evaluateConstraints(
    usingContext context: EvaluableConditionContext
  ) -> Bool {
  
    return self.constraints.allSatisfy {
      $0.evaluate(usingContext: context);
    };
  };
};

