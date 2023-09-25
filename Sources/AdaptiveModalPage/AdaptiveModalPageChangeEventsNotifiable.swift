//
//  AdaptiveModalPageChangeEventsNotifiable.swift
//  
//
//  Created by Dominic Go on 9/7/23.
//

import Foundation


public protocol AdaptiveModalPageChangeEventsNotifiable: AnyObject {

  func notifyOnModalPageWillChange(
    sender: AdaptiveModalPageViewController,
    prevPage: AdaptiveModalResolvedPageItemConfig?,
    nextPage: AdaptiveModalResolvedPageItemConfig
  );
  
  func notifyOnModalPageDidChange(
    sender: AdaptiveModalPageViewController,
    prevPage: AdaptiveModalResolvedPageItemConfig?,
    currentPage: AdaptiveModalResolvedPageItemConfig
  );
};
