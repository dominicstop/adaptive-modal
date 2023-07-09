//
//  AdaptiveModalDragHandleView.swift
//  adaptive-modal-example
//
//  Created by Dominic Go on 7/9/23.
//

import UIKit

public class AdaptiveModalDragHandleView: UIView {

  public var pointInsideHitSlop: CGPoint = .zero;

  public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let boundsWithInset = bounds.insetBy(
      dx: -self.pointInsideHitSlop.x,
      dy: -self.pointInsideHitSlop.y
    );
    
    return boundsWithInset.contains(point);
  };
};
