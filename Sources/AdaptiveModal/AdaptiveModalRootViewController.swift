//
//  AdaptiveModalRootViewController.swift
//  
//
//  Created by Dominic Go on 7/5/23.
//

import UIKit

class PassthroughView: UIView {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard let hitView = super.hitTest(point, with: event) else { return nil };

    if hitView === self {
      return nil;
    };
    
    return hitView;
  };
};

public class AdaptiveModalRootViewController: UIViewController {
  weak var modalManager: AdaptiveModalManager?;
  
  public override func loadView() {
    super.loadView();
  
    let view = PassthroughView();
    view.frame = self.view.frame;
    
    self.view = view;
  };
};

