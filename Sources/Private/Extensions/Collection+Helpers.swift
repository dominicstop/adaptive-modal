//
//  Collection+Helpers.swift
//  react-native-ios-modal
//
//  Created by Dominic Go on 4/10/23.
//

import UIKit

extension Collection {
  
  var secondToLast: Element? {
    self[safeIndex: self.index(self.indices.endIndex, offsetBy: -2)];
  };

  func isOutOfBounds(forIndex index: Index) -> Bool {
    return index < self.indices.startIndex || index >= self.indices.endIndex;
  };
  
  /// Returns the element at the specified index if it is within bounds,
  /// otherwise nil.
  subscript(safeIndex index: Index) -> Element? {
    return self.isOutOfBounds(forIndex: index) ? nil : self[index];
  };
  
  func seekForward(
    startIndex: Int,
    where condition: (Element) -> Bool
  ) -> Element? {
    
    for index in startIndex ..< self.count {
      let element = self[
        self.index(self.indices.startIndex, offsetBy: index)
      ];
      
      if condition(element) {
        return element;
      };
    };
    
    return nil;
  };
  
  func seekBackwards(
    startIndex: Int,
    where condition: (Element) -> Bool
  ) -> Element? {
    
    for index in (0...startIndex).reversed() {
      let element = self[
        self.index(self.indices.startIndex, offsetBy: index)
      ];
      
      if condition(element) {
        return element;
      };
    };
    
    return nil;
  };
  
  func seekForwardAndBackwards(
    startIndex: Int,
    where condition: (Element, _ isReversing: Bool) -> Bool
  ) -> Element? {
    
    let matchInitial = self.seekForward(
      startIndex: startIndex,
      where: {
        condition($0, false);
      }
    );
    
    if let matchInitial = matchInitial {
      return matchInitial;
    };
    
    return self.seekBackwards(
      startIndex: startIndex,
      where: {
        condition($0, true);
      }
    );
  };
};

extension MutableCollection {
  subscript(safeIndex index: Index) -> Element? {
    get {
      return self.isOutOfBounds(forIndex: index) ? nil : self[index];
    }
    
    set {
      guard let newValue = newValue,
            !self.isOutOfBounds(forIndex: index)
      else { return };
      
      self[index] = newValue;
    }
  };
};
