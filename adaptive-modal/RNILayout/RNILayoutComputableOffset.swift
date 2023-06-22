//
//  RNILayoutComputableOffset.swift
//  adaptive-modal
//
//  Created by Dominic Go on 6/22/23.
//

import Foundation

public struct RNILayoutComputableOffset {

  public enum OffsetOperation: String {
    case multiply, divide, add, subtract;
    
    public func compute(a: Double, b: Double) -> Double {
      switch self {
        case .add:
          return a + b;
          
        case .divide:
          return a / b;
          
        case .multiply:
          return a * b;
          
        case .subtract:
          return a - b;
      };
    };
  };
  
  public var offset: Double;
  public var offsetOperation: OffsetOperation;
  
  public func compute(
    withValue value: Double,
    isValueOnRHS: Bool = false
  ) -> Double {
    if isValueOnRHS {
      return self.offsetOperation.compute(a: value, b: self.offset);
    };
    
    return self.offsetOperation.compute(a: self.offset, b: value);
  };
};
