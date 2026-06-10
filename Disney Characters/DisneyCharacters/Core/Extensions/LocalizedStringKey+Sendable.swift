import SwiftUI

/// `LocalizedStringKey` stores an immutable lookup key (the literal string and
/// any interpolation arguments). Apple has not exposed a public `Sendable`
/// conformance for it in the SwiftUI SDK shipping with Xcode 26, so static-let
/// constants of this type are flagged under strict concurrency checking.
///
/// The underlying storage is effectively immutable, so this retroactive
/// conformance is safe in practice. Remove this file when Apple ships the
/// conformance upstream.
extension LocalizedStringKey: @retroactive @unchecked Sendable {}
