import Foundation
import Combine
import UIKit
import Dispatch

public enum ModelState<ItemType: Identifiable>{
    case empty
    case loading
    case ready(items: [ItemType])
    case error(error: Error)
}

public protocol Model {
    associatedtype ItemType: Identifiable
    
    var state: any Publisher<ModelState<ItemType>, Never> { get }
    func begin()
    func reset()
    func next()
    func handle(action: ModelAction<ItemType>, completion:@escaping (ModelActionResult) -> ())
}

public enum ModelAction<ItemType: Identifiable> {
    case upsert(item: ItemType)
    case delete(item: ItemType)
}

public enum ModelActionResult {
    case complete
    case failed(error: Error)
}

/// --------------------------------------------------

public protocol DataProvider {
    associatedtype OutputType
    
    func retrieve(count: Int, offset: Int, completion: @escaping ([OutputType]) -> ())
    func retrieve(count: Int, offset: Int) async -> [OutputType]
}

/// --------------------------------------------------

public protocol Renderer {
    associatedtype ItemType
    
    func render(item: ItemType)
}

/// --------------------------------------------------

public class ModelImpl<T: Identifiable, DP: DataProvider>: Model where DP.OutputType == T {
    public var state: any Publisher<ModelState<T>, Never> { pub }
    
    private let dataProvider: DP
    private let pub: CurrentValueSubject<ModelState<T>, Never> = CurrentValueSubject(.empty)
    private var page = 0
    private let loadCount = 10
    
    public init(dataProvider: DP) {
        self.dataProvider = dataProvider
    }
    
    public func begin() {
        dataProvider.retrieve(count: loadCount, offset: page * loadCount) { [weak self] data in
            self?.pub.send(ModelState.ready(items: data))
        }
    }

    public func reset() {
        begin()
    }

    public func next() {
        dataProvider.retrieve(count: 10, offset: 0) { [weak self] data in
            self?.pub.send(ModelState.ready(items: data))
        }
    }
    
    public func handle(action: ModelAction<T>, completion:@escaping (ModelActionResult) -> ()) {
    }
}

