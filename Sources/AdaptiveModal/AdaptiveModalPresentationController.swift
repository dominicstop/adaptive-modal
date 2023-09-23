//
//  AdaptiveModalPresentationController.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 6/8/23.
//

import UIKit

class AdaptiveModalPresentationController: UIPresentationController {

  weak var modalManager: AdaptiveModalManager!;
  
  var shouldPauseLayoutUpdates = false;

  init(
    presentedViewController: UIViewController,
    presenting presentingViewController: UIViewController?,
    modalManager: AdaptiveModalManager
  ) {
    super.init(
      presentedViewController: presentedViewController,
      presenting: presentingViewController
    );
    
    self.modalManager = modalManager;
  };
  
   override func presentationTransitionWillBegin() {
   };
  
   override func presentationTransitionDidEnd(_ completed: Bool) {
   };
   
  override func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
  
    super.viewWillTransition(to: size, with: coordinator);
    self.modalManager.clearAnimators();
    self.shouldPauseLayoutUpdates = true;
    
    coordinator.animate(
      alongsideTransition: { _ in
        self.modalManager.notifyDidLayoutSubviews();
      },
      completion: { _ in
        self.modalManager.endDisplayLink();
        self.shouldPauseLayoutUpdates = false;
      }
    );
    
    self.modalManager.startDisplayLink(shouldAutoEndDisplayLink: false);
  };
  
  override func containerViewWillLayoutSubviews(){
  };
  
  override func containerViewDidLayoutSubviews(){
    guard !self.shouldPauseLayoutUpdates else { return };
    self.modalManager.notifyDidLayoutSubviews();
  };
};
