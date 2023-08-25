//
//  AdaptiveModalStateEventsNotifiable.swift
//  
//
//  Created by Dominic Go on 8/26/23.
//

import Foundation

/// Allows the type that conforms to this protocol to get notified of modal
/// state related changes
///
public protocol AdaptiveModalStateEventsNotifiable: AnyObject {

  func notifyOnModalStateWillChange(
    sender: AdaptiveModalManager,
    prevState: AdaptiveModalState,
    currentState: AdaptiveModalState,
    nextState: AdaptiveModalState
  );
};
