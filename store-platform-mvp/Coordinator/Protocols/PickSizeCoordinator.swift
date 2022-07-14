import Foundation

protocol PickSizeCoordinatorProtocol: AnyObject {
    var completionHandler: ((Cart) -> Void)? { get set }
    
    func showSizePicker(for item: Item)
    func hideSizePicker(with item: Cart)
}
