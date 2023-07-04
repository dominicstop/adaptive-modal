//
//  AdaptiveModalManager+UIViewControllerAnimatedTransitioning.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 6/8/23.
//

import UIKit

extension AdaptiveModalManager: UIViewControllerAnimatedTransitioning {

  public func transitionDuration(
    using transitionContext: UIViewControllerContextTransitioning?
  ) -> TimeInterval {
  
    return self.modalConfig.snapAnimationConfig.springAnimationSettlingTime;
  };
  
  public func animateTransition(
    using transitionContext: UIViewControllerContextTransitioning
  ) {
    guard let fromVC = transitionContext.viewController(forKey: .from)
    else { return };
    
    self.transitionContext = transitionContext;
    
    switch self.presentationState {
      case .presenting:
        let containerView = transitionContext.containerView
      
        self.targetView = containerView;
        self.presentingViewController = fromVC;
        
        self.prepareForPresentation();
        
        AdaptiveModalUtilities.swizzleHitTest(
          forView: containerView
        ) { originalImp, selector in
        
          /// This the new imp that will replace the `hitTest` method in
          /// `containerView`
          return { _self, point, event in
            
            // Call the original implementation.
            let hitView = originalImp(_self, selector, point, event);
            
            guard let _self = _self as? UIView,
                  hitView === _self
            else { return hitView };
            
            let currentInterpolationStep = self.currentInterpolationStep;
            
            let bgTapInteraction =
              currentInterpolationStep.derivedBackgroundTapInteraction;
              
            if bgTapInteraction.isPassThrough {
              return nil;
            };
            
            return hitView;
          };
        };
        
        self.showModal(
          isAnimated: transitionContext.isAnimated,
          extraAnimation: self.extraAnimationBlockPresent
        ) {
          transitionContext.completeTransition(true);
          self.extraAnimationBlockPresent = nil;
        };
      
      case .dismissing:
        self.hideModal(
          isAnimated: transitionContext.isAnimated,
          extraAnimation: self.extraAnimationBlockDismiss
        ){
          transitionContext.completeTransition(true);
          self.extraAnimationBlockDismiss = nil;
        };
        
      case .none:
        break;
    };
  };
};
