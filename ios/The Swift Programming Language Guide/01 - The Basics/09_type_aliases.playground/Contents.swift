import UIKit

/*
 Type Aliases:
 
 Type aliases define an alternative name for an existing type.
 Type aliases are useful when you want to refer to an existing type by a name that is contextually more appropriate, such as when working with data of a specific size from an external source.
 */

typealias AudioSample = UInt16

/// Once you define a type alias, you can use the alias anywhere
/// you might use the original name:
var maxAmplitudeFound = AudioSample.min

