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
  
    return self.currentModalConfig.snapAnimationConfig.duration;
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
        
        let args = self.showModalCommandArgs;
        
        self.showModal(
          isAnimated: transitionContext.isAnimated,
          animationConfig: args?.animationConfig,
          extraAnimation: args?.extraAnimationBlock
        ) {
          transitionContext.completeTransition(true);
          self.showModalCommandArgs = nil;
          self.presentationState = .none;
        };
      
      case .dismissing:
        let args = self.hideModalCommandArgs;
      
        self.hideModal(
          useInBetweenSnapPoints: args?.useInBetweenSnapPoints ?? false,
          isAnimated: transitionContext.isAnimated,
          animationConfig: args?.animationConfig,
          extraAnimation: args?.extraAnimationBlock
        ){
          transitionContext.completeTransition(true);
          self.hideModalCommandArgs = nil;
          self.presentationState = .none;
        };
        
      case .none:
        break;
    };
  };
};
