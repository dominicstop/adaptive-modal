//
//  RNILayoutValue+StaticInit.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 6/19/23.
//

import UIKit

public extension RNILayoutValue {
 
  static let stretch: Self = .init(mode: .stretch);
  
  static func stretch(
    offsetValue: RNILayoutValueMode? = nil,
    offsetOperation: RNILayoutComputableOffset.OffsetOperation? = nil,
    minValue: RNILayoutValueMode? = nil,
    maxValue: RNILayoutValueMode? = nil
  ) -> Self {
  
    return .init(
      mode:. stretch,
      offsetValue: offsetValue,
      offsetOperation: offsetOperation,
      minValue: minValue,
      maxValue: maxValue
    );
  };
  
  static func constant(_ constantValue: CGFloat) -> Self {
    return .init(mode: .constant(constantValue))
  };
  
  static func percent(
    relativeTo: RNILayoutValuePercentTarget = .targetSize,
    percentValue: Double,
    offsetValue: RNILayoutValueMode? = nil,
    offsetOperation: RNILayoutComputableOffset.OffsetOperation? = nil,
    minValue: RNILayoutValueMode? = nil,
    maxValue: RNILayoutValueMode? = nil
  ) -> Self {
  
    return .init(
      mode: .percent(
        relativeTo: relativeTo,
        percentValue: percentValue
      ),
      offsetValue: offsetValue,
      offsetOperation: offsetOperation,
      minValue: minValue,
      maxValue: maxValue
    );
  };
  
  static func safeAreaInsets(
    insetKey: KeyPath<UIEdgeInsets, CGFloat>,
    offsetValue: RNILayoutValueMode? = nil,
    offsetOperation: RNILayoutComputableOffset.OffsetOperation? = nil,
    minValue: RNILayoutValueMode? = nil,
    maxValue: RNILayoutValueMode? = nil
  ) -> Self {
  
    return .init(
      mode: .safeAreaInsets(insetKey: insetKey),
      offsetValue: offsetValue,
      offsetOperation: offsetOperation,
      minValue: minValue,
      maxValue: maxValue
    );
  };
  
  static func keyboardScreenRect(
    rectKey: KeyPath<CGRect, CGFloat>,
    offsetValue: RNILayoutValueMode? = nil,
    offsetOperation: RNILayoutComputableOffset.OffsetOperation? = nil,
    minValue: RNILayoutValueMode? = nil,
    maxValue: RNILayoutValueMode? = nil
  ) -> Self {
  
    return .init(
      mode: .keyboardScreenRect(rectKey: rectKey),
      offsetValue: offsetValue,
      offsetOperation: offsetOperation,
      minValue: minValue,
      maxValue: maxValue
    );
  };
  
  static func keyboardRelativeSize(
    sizeKey: KeyPath<CGSize, CGFloat>,
    offsetValue: RNILayoutValueMode? = nil,
    offsetOperation: RNILayoutComputableOffset.OffsetOperation? = nil,
    minValue: RNILayoutValueMode? = nil,
    maxValue: RNILayoutValueMode? = nil
  ) -> Self {
  
    return .init(
      mode: .keyboardRelativeSize(sizeKey: sizeKey),
      offsetValue: offsetValue,
      offsetOperation: offsetOperation,
      minValue: minValue,
      maxValue: maxValue
    );
  };
  
  static func multipleValues(
    _ values: [RNILayoutValueMode],
    offsetValue: RNILayoutValueMode? = nil,
    offsetOperation: RNILayoutComputableOffset.OffsetOperation? = nil,
    minValue: RNILayoutValueMode? = nil,
    maxValue: RNILayoutValueMode? = nil
  ) -> Self {
  
    return .init(
      mode: .multipleValues(values),
      offsetValue: offsetValue,
      offsetOperation: offsetOperation,
      minValue: minValue,
      maxValue: maxValue
    );
  };
  
  static func conditionalValue(
    condition: RNILayoutConditionalValueMode,
    trueValue: RNILayoutValueMode?,
    falseValue: RNILayoutValueMode? = nil,
    offsetValue: RNILayoutValueMode? = nil,
    offsetOperation: RNILayoutComputableOffset.OffsetOperation? = nil,
    minValue: RNILayoutValueMode? = nil,
    maxValue: RNILayoutValueMode? = nil
  ) -> Self {
  
    return .init(
      mode: .conditionalValue(
        condition: condition,
        trueValue: trueValue,
        falseValue: falseValue
      ),
      offsetValue: offsetValue,
      offsetOperation: offsetOperation,
      minValue: minValue,
      maxValue: maxValue
    );
  };
};
