import Foundation

// MARK: - ImageCoordinatorProtocol
protocol ImageCoordinatorProtocol {
    var imageDelegate: ImagePickerDelegate? { get set }
    
    func showDetailedImage(data: Data)
    func showImagePicker()
}
