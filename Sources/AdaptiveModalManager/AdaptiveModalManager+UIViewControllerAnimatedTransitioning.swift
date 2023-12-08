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
  
    let isAnimated: Bool = {
      if let args = self._tempShowModalCommandArgs {
        return args.isAnimated;
      };
      
      if let args = self._tempHideModalCommandArgs {
        return args.isAnimated;
      };
      
      return transitionContext?.isAnimated ?? false;
    }();
    
    return isAnimated
      ? self.currentModalConfig.snapAnimationConfig.duration
      : 0;
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
      
        self.rootView = containerView;
        self.presentingViewController = fromVC;
        
        self._setupPrepareForPresentation();
        
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
            
            let interpolationPointCurrent =
              self.interpolationContext.interpolationPointCurrent;
            
            let bgTapInteraction =
              interpolationPointCurrent.derivedBackgroundTapInteraction;
              
            if bgTapInteraction.isPassThrough {
              return nil;
            };
            
            return hitView;
          };
        };
        
        let shouldSetState = !self.modalState.isPresenting;
        
        if shouldSetState {
          self.modalStateMachine.setState(.PRESENTING_PROGRAMMATIC);
        };
        
        let args = self._tempShowModalCommandArgs;
        
        self.showModal(
          snapPointIndex: args?.snapPointIndex,
          isAnimated: args?.isAnimated ?? true,
          animationConfig: args?.animationConfig,
          shouldSetStateOnSnap: args?.shouldSetStateOnSnap ?? true,
          stateSnapping: args?.stateSnapping,
          stateSnapped: args?.stateSnapped,
          extraAnimation: args?.extraAnimationBlock
        ) {
          transitionContext.completeTransition(true);
          
          self._tempShowModalCommandArgs = nil;
          self.presentationState = .none;
          
          if shouldSetState {
            let nextState: AdaptiveModalState = self.modalState.isProgrammatic
              ? .PRESENTED_PROGRAMMATIC
              : .PRESENTED_GESTURE;
          
            self.modalStateMachine.setState(nextState);
          };
        };
      
      case .dismissing:
        let args = self._tempHideModalCommandArgs;
        
        if !self.modalState.isDismissing {
          self.modalStateMachine.setState(.DISMISSING_PROGRAMMATIC);
        };
      
        self.hideModal(
          mode: args?.mode ?? .direct,
          isAnimated: args?.isAnimated ?? true,
          animationConfig: args?.animationConfig,
          shouldSetStateOnSnap: args?.shouldSetStateOnSnap ?? true,
          stateSnapping: args?.stateSnapping,
          stateSnapped: args?.stateSnapped,
          extraAnimation: args?.extraAnimationBlock
        ){
          transitionContext.completeTransition(true);
          
          self._tempHideModalCommandArgs = nil;
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
