//
//  AdaptiveModalDragHandleView.swift
//  adaptive-modal-example
//
//  Created by Dominic Go on 7/9/23.
//

import UIKit

public class AdaptiveModalDragHandleView: UIView {

  // extra size for hit test
  public var pointInsideHitSlop: CGPoint = .zero;
  
  public var boundsWithHitSlop: CGRect {
    self.bounds.insetBy(
      dx: -self.pointInsideHitSlop.x,
      dy: -self.pointInsideHitSlop.y
    );
  };
  
  public var frameWithHitSlop: CGRect {
    self.frame.insetBy(
      dx: -self.pointInsideHitSlop.x,
      dy: -self.pointInsideHitSlop.y
    );
  };

  public override func point(
    inside point: CGPoint,
    with event: UIEvent?
  ) -> Bool {
  
    return self.boundsWithHitSlop.contains(point);
  };
};
