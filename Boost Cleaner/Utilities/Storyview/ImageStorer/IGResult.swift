

import Foundation

public enum IGResult<V, E> {
    case success(V)
    case failure(E)
}
