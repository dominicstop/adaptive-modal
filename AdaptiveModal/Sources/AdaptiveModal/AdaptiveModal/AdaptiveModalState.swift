//
//  AdaptiveModalState.swift
//  
//
//  Created by Dominic Go on 8/14/23.
//

import Foundation


// DISMISSING_GESTURE -> isSnapped = DISMISS_VIA_GESTURE_CANCELLED

public enum AdaptiveModalState {

  case INITIAL;

  case PRESENTING_PROGRAMMATIC;
  case PRESENTING_GESTURE;

  case PRESENTED_PROGRAMMATIC;
  case PRESENTED_GESTURE;
  
  case DISMISSING_PROGRAMMATIC;
  case DISMISSING_GESTURE;
  
  case DISMISSED_PROGRAMMATIC;
  case DISMISSED_GESTURE;
  
  case SNAPPING_FROM_GESTURE_DRAGGING;
  case SNAPPING_PROGRAMMATIC;
  
  case SNAPPED_FROM_GESTURE_DRAGGING;
  case SNAPPED_PROGRAMMATIC;
  
  case GESTURE_DRAGGING;
  
  case DISMISS_VIA_GESTURE_CANCELLED;
  
  // MARK: Computed Properties - Alias
  // ---------------------------------
  
  public var isGestureDragging: Bool {
    self == .GESTURE_DRAGGING;
  };
  
  public var isPresentedProgrammaticOrGesture: Bool {
       self == .PRESENTED_PROGRAMMATIC
    || self == .PRESENTED_GESTURE
  };
  
  public var isSnappingProgrammaticOrGesture: Bool {
       self == .SNAPPING_FROM_GESTURE_DRAGGING
    || self == .SNAPPING_PROGRAMMATIC;
  };
  
  public var isSnappedProgrammaticOrGesture: Bool {
       self == .SNAPPED_FROM_GESTURE_DRAGGING
    || self == .SNAPPED_PROGRAMMATIC;
  };
  
  public var isDismissedProgrammaticOrGesture: Bool {
       self == .DISMISSED_PROGRAMMATIC
    || self == .DISMISSED_GESTURE;
  };
  
  public var isPresenting: Bool {
       self == .PRESENTING_PROGRAMMATIC
    || self == .PRESENTING_GESTURE;
  };
  
  public var isDismissing: Bool {
       self == .DISMISSING_PROGRAMMATIC
    || self == .DISMISSING_GESTURE;
  };
  
  // MARK: Computed Properties
  // -------------------------
  
  public var isDismissed: Bool {
       self.isDismissedProgrammaticOrGesture
    || self == .INITIAL;
  };
  
  public var isPresented: Bool {
       self.isPresentedProgrammaticOrGesture
    || self.isSnappingProgrammaticOrGesture
    || self.isSnappedProgrammaticOrGesture
    || self == .GESTURE_DRAGGING
    || self == .DISMISS_VIA_GESTURE_CANCELLED;
  };
  
  public var isSnapping: Bool {
       self.isSnappingProgrammaticOrGesture
    || self.isPresenting
    || self.isDismissing;
  };
  
  public var isSnapped: Bool {
       self.isSnappedProgrammaticOrGesture
    || self.isDismissed
    || self.isPresented;
  };
  
  public var isIdle: Bool {
       self.isPresented
    || self.isDismissed
    || self.isSnapped;
  };
  
  public var isProgrammatic: Bool {
    switch self {
      case .PRESENTING_PROGRAMMATIC,
           .PRESENTED_PROGRAMMATIC,
           .DISMISSING_PROGRAMMATIC,
           .DISMISSED_PROGRAMMATIC,
           .SNAPPING_PROGRAMMATIC,
           .SNAPPED_PROGRAMMATIC:
        return true;
        
      case .GESTURE_DRAGGING:
        return false;
        
      default:
        return false;
    };
  };
};

struct AdaptiveModalStateMachine {

  var onStateWillChangeBlock: (
    _ prevState   : AdaptiveModalState,
    _ currentState: AdaptiveModalState,
    _ nextState   : AdaptiveModalState
  ) -> Void;
  
  private(set)var prevState: AdaptiveModalState = .INITIAL;
  private(set) var currentState: AdaptiveModalState = .INITIAL;
  
  var stateOverride: AdaptiveModalState?;
  
  mutating func setState(_ nextState: AdaptiveModalState){
    
    let nextStateAdj: AdaptiveModalState? = {
       if let stateOverride = self.stateOverride {
        return stateOverride;
      };
      
      switch (self.prevState, self.currentState, nextState){
        case (
          .DISMISSING_GESTURE,
          .GESTURE_DRAGGING,
          .SNAPPING_FROM_GESTURE_DRAGGING
        ):
          return .DISMISS_VIA_GESTURE_CANCELLED;
          
        case (
          .DISMISSING_PROGRAMMATIC,
          .DISMISSED_PROGRAMMATIC,
          .SNAPPED_PROGRAMMATIC
        ):
          return .DISMISSED_PROGRAMMATIC;
      
        default:
          break;
      };
      
      // Calling `snapTo` while modal is dismissed
      // DISMISSED  -> SNAPPING = PRESENTING
      if self.prevState.isDismissing,
         self.currentState.isDismissed,
         nextState.isSnapping {
        
        return nextState.isProgrammatic
          ? .PRESENTING_PROGRAMMATIC
          : .PRESENTING_GESTURE;
      };
  
      return nextState;
    }();
    
    guard let nextStateAdj = nextStateAdj,
          nextStateAdj != self.currentState
    else { return };
    
    self.onStateWillChangeBlock(prevState, currentState, nextStateAdj);
    
    self.prevState = currentState;
    self.currentState = nextStateAdj;
  };
};
