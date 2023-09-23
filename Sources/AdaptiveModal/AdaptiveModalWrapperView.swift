//
//  AdaptiveModalWrapperView.swift
//  adaptive-modal-example
//  
//
//  Created by Dominic Go on 7/12/23.
//

import UIKit

public class AdaptiveModalWrapperView: UIView {

  weak var modalManager: AdaptiveModalManager?;
  
  public override func hitTest(
    _ point: CGPoint,
    with event: UIEvent?
  ) -> UIView? {
    let hitView = super.hitTest(point, with: event);
  
    guard let dragHandle = self.modalManager?.modalDragHandleView else {
      return hitView;
    };
    
    if dragHandle.frameWithHitSlop.contains(point) {
      return dragHandle;
    };
    
    return hitView;
  };
};
