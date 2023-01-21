import Foundation

struct Parameter: Hashable {
    let id: String = UUID().uuidString
    let option: String
    let type: ParameterType
    let isSelected: Bool
    
    enum ParameterType {
        case color
        case size
    }
}
