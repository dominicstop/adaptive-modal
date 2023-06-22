//
//  RNIAnimatorSize.swift
//  react-native-ios-modal
//
//  Created by Dominic Go on 4/19/23.
//

import UIKit

fileprivate extension CGSize {
  init(array: [CGFloat]) {
    self = CGSize(width: array[0], height: array[1]);
  };
  
  var array: [CGFloat] {
    return [
      self.width,
      self.height
    ];
  };
};

class RNIAnimatorSize: RNIAnimator {
  
  init?(
    durationSeconds: CFTimeInterval,
    sizeStart: CGSize,
    sizeEnd: CGSize,
    onSizeDidChange: ((_ newSize: CGSize) -> Void)? = nil,
    onAnimationCompletion: (() -> Void)? = nil
  ) {
    super.init(
      durationSeconds: durationSeconds,
      animatedValuesStart: sizeStart.array,
      animatedValuesEnd: sizeEnd.array
    ) {
      onSizeDidChange?(
        CGSize(array: $0)
      );
    } onAnimationCompletion: {
      onAnimationCompletion?();
    };
  };
  
  func update(
    sizeEnd: CGSize,
    duration: CGFloat? = nil
  ){
    super.update(
      animatedValuesEnd: sizeEnd.array,
      duration: duration
    );
  };
};
