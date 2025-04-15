//
//  BasePartialKeyframe.swift
//  AdaptiveModal
//
//  Created by Dominic Go on 4/9/25.
//

import Foundation
import DGSwiftUtilities

public protocol BasePartialKeyframe: SettableNilValues, Equatable {
  
  associatedtype ConcreteKeyframe: BaseConcreteKeyframe<Self>;
  
  static var empty: Self { get };
};

// MARK: - BasePartialKeyframe+SettableNilValues (Default)
// -------------------------------------------------------

extension BasePartialKeyframe {
  
  public mutating func setNilValues(with otherValue: Self) {
    ConcreteKeyframe.partialToConcreteKeyframePropertyMap.forEach {
      let (partialKeyframePath, _) = $0;
      
      let currentValueWrapped =
        partialKeyframePath.asOptionalUnwrappable(target: self)
      
      guard let currentValueWrapped = currentValueWrapped,
            currentValueWrapped.isNil
      else {
        return;
      };
      
      let newValue = otherValue[keyPath: partialKeyframePath.partialKeyPath];
      
      try? partialKeyframePath.setValue(
        target: &self,
        withValue: newValue
      );
    };
  };
};

public extension BasePartialKeyframe {
  
  init(from concreteKeyframe: ConcreteKeyframe) {
    self = concreteKeyframe.asPartialKeyframe;
  };
};


