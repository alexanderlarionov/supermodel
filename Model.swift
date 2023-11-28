import Foundation
import Combine
import UIKit
import Dispatch

public enum ModelState<ItemType: Identifiable>{
    case empty
    case loading
    case ready(items: [ItemType])
    case error(_: Error)
}

public protocol Model {
    associatedtype ItemType: Identifiable
    
    var state: any Publisher<ModelState<ItemType>, Never> { get }
    
    func next()
    func reset()
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
    typealias DataProviderResult = Result<[OutputType], Error>
    
    func retrieve(count: Int, offset: Int, completion: @escaping (DataProviderResult) -> ())
    func retrieve(count: Int, offset: Int) async -> DataProviderResult
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

    public func reset() {
        page = 0
        next()
    }

    public func next() {
        pub.send(.loading)
        dataProvider.retrieve(count: 10, offset: page * loadCount) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                self.page += 1
                self.pub.send(.ready(items: data))
            case .failure(let error):
                self.pub.send(.error(error))
            }
        }
    }
    
    public func handle(action: ModelAction<T>, completion:@escaping (ModelActionResult) -> ()) {
    }
}

