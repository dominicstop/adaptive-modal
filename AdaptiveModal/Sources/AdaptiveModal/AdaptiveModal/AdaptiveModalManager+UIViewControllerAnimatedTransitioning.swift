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
        
        if !self.modalState.isPresenting {
          self.modalStateMachine.setState(.PRESENTING_PROGRAMMATIC);
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
          
          if !self.modalState.isPresented {
            self.modalStateMachine.setState(.PRESENTED_PROGRAMMATIC);
          };
        };
      
      case .dismissing:
        let args = self.hideModalCommandArgs;
        
        if !self.modalState.isDismissing {
          self.modalStateMachine.setState(.DISMISSING_PROGRAMMATIC);
        };
      
        self.hideModal(
          useInBetweenSnapPoints: args?.useInBetweenSnapPoints ?? false,
          isAnimated: transitionContext.isAnimated,
          animationConfig: args?.animationConfig,
          extraAnimation: args?.extraAnimationBlock
        ){
          transitionContext.completeTransition(true);
          self.hideModalCommandArgs = nil;
          self.presentationState = .none;
          
          if !self.modalStateMachine.currentState.isDismissed {
            self.modalStateMachine.setState(.DISMISSED_PROGRAMMATIC);
          };
        };
        
      case .none:
        break;
    };
  };
};
