import Foundation
import Combine

/// Test implementation
/// Controller class which operates with model

public class Controller<M: Model, R: Renderer> where M.ItemType == R.ItemType {
    private let model: M
    private let renderer: R
    private var modelObserving: Cancellable? = nil
    
    public init(model: M, renderer: R) {
        self.model = model
        self.renderer = renderer
    }
    
    public func willDisplay() {
        model.begin()
        
        modelObserving = model.state.sink(receiveValue: update(with:))
    }
    
    public func didEndDisplay() {
        modelObserving?.cancel()
    }
    
    public func refresh() {
        model.reset()
    }
    
    public func loadNextPage() {
        model.next()
    }
    
    private func update(with state: ModelState<M.ItemType>) {
        switch state {
        case .empty:
            displayEmpty()
        case .ready(let items):
            displayItems(items: items)
        case .loading:
            displayLoading()
        case .error(let error):
            displayError(error )
        }
    }

    private func displayItems(items: [M.ItemType]) {
        /// Displaying views here
        items.forEach {
            renderer.render(item: $0)
        }
    }
    
    private func displayError(_ error: Error) {
        /// Displaying error here
        print(error.localizedDescription)
    }
    
    private func displayLoading() {
        /// Displaying loading
    }
    
    private func displayEmpty() {
        /// Displaying empty state
    }
}
