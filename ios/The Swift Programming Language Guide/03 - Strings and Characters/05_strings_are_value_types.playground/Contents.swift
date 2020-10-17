import UIKit

/*
 Strings are Value Types:
 
 Swift’s String type is a value type. If you create a new String value, that String value is copied when it’s passed to a function or method, or when it’s assigned to a constant or variable.
 In each case, a new copy of the existing String value is created, and the new copy is passed or assigned, not the original version
 */

/// Swift’s copy-by-default String behavior ensures that when a function or method passes you a String value,
/// it’s clear that you own that exact String value, regardless of where it came from.
/// You can be confident that the string you are passed won’t be modified unless you modify it yourself.
