import Foundation

/// Test implementation
/// Assembly drafts for test purposes

extension String: Identifiable {
    public typealias ID = Int
    public var id: Self.ID {
        hash
    }
}

fileprivate class StringRangesDataProvider: DataProvider {
    func retrieve(count: Int, offset: Int, completion: @escaping ([String]) -> ()) {
        DispatchQueue.main.async {
            completion(self.result(count: count, offset: offset))
        }
    }
    
    func retrieve(count: Int, offset: Int) async -> [String] {
        await Task {
            result(count: count, offset: offset)
        }.value
    }
    
    private func result(count: Int, offset: Int) -> [String] {
        [offset...offset + count].map { "\($0)" }
    }
}

fileprivate class StringRenderer: Renderer {
    func render(item: String) {
        print("💬 string: \(item)")
    }
}

public class EntryPoint {
    public static func start() {
        let stringModel = ModelImpl<String, StringRangesDataProvider>(dataProvider: StringRangesDataProvider())
        let renderer = StringRenderer()
        let controller = Controller(model: stringModel, renderer: renderer)
        
        controller.willDisplay()
        sleep(1)
        controller.loadNextPage()
        sleep(1)
        controller.loadNextPage()
        sleep(1)
        controller.refresh()
        sleep(1)
        controller.didEndDisplay()
    }
}
