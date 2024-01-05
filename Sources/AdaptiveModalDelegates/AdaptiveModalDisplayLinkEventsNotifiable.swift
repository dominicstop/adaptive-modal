//
//  AdaptiveModalDisplayLinkEventsNotifiable.swift
//  
//
//  Created by Dominic Go on 1/6/24.
//

import UIKit

public protocol AdaptiveModalDisplayLinkEventsNotifiable: AnyObject {
  
  func onDisplayLinkTick(
    sender: AdaptiveModalManager,
    displayLink: CADisplayLink,
    modalFrame: CGRect
  );
};
