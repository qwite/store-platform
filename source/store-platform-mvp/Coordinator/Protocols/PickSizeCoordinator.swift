import Foundation

// MARK: - SizePickerCoordinatorProtocol
protocol SizePickerCoordinatorProtocol: AnyObject {
    var completionHandler: ((Cart) -> Void)? { get set }
    
    func showSizePicker(for item: Item)
    func hideSizePicker(with item: Cart)
}
