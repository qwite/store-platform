import Foundation

protocol PickSizeCoordinatorProtocol: AnyObject {
    var completionHandler: ((CartItem) -> Void)? { get set }
    
    func showSizePicker(for item: Item)
    func hideSizePicker(with item: CartItem)
}
