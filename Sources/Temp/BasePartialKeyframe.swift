//
//  BasePartialKeyframe.swift
//  AdaptiveModal
//
//  Created by Dominic Go on 4/9/25.
//

import Foundation

public protocol BasePartialKeyframe {
  
  associatedtype ConcreteKeyframe: BaseConcreteKeyframe<Self>;
  
  static var empty: Self { get };
};

public extension BasePartialKeyframe {
  
  init (from concreteKeyframe: ConcreteKeyframe) {
    self = concreteKeyframe.asPartialKeyframe;
  };
};


