enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String, isRetryable: Bool)
}

extension ViewState: Equatable where T: Equatable {}
