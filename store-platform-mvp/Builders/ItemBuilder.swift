import Foundation

// MARK: - ItemBuilder Protocol
protocol ItemBuilderProtocol {
    var brandName: String? { get set }
    var clothingName: String? { get set }
    var description: String? { get set }
    var category: String? { get set }
    var color: String? { get set }
    var sizes: [Size] { get set }
    
    func setBrandName(_ name: String)
    func setClothingName(_ name: String)
    func setDescription(_ description: String)
    func setCategory(_ category: String)
    func setColor(_ color: String)
    func addSize(_ size: Size) -> Size?
    func addSize(size: String, price: Int, amount: Int) -> Size?
    func editSize(item: Size) -> Size?
    func build() -> Item
}

// MARK: - ItemBuilder Implementation
class ItemBuilder: ItemBuilderProtocol {
    var brandName: String?
    var clothingName: String?
    var description: String?
    var category: String?
    var color: String?
    var sizes: [Size] = []

    deinit {
        debugPrint("[Log] ItemBuilder deinit")
    }
    
    func setBrandName(_ name: String) {
        self.brandName = name
    }
    
    func setClothingName(_ name: String) {
        self.clothingName = name
    }
    
    func setDescription(_ description: String) {
        self.description = description
    }
    
    func setCategory(_ category: String) {
        self.category = category
    }
    
    func setColor(_ color: String) {
        self.color = color
    }
    
    func addSize(_ size: Size) -> Size? {
        return addSize(size: size.size, price: size.price, amount: size.amount)
    }
    
    func addSize(size: String, price: Int, amount: Int) -> Size? {
        guard !sizes.contains(where: { $0.size == size }) else {
            return nil
        }
        
        guard let encodedSizeIndex = Size.AvailableSizes.allCases.firstIndex(where: { $0.rawValue == size }) else {
            return nil
        }
    
        let encodedSize = Size.AvailableSizes.allCases[encodedSizeIndex]
        let item = Size(size: encodedSize, price: price, amount: amount)
        
        sizes.append(item)
        return item
    }
    
    // TODO: Fix
    func editSize(item: Size) -> Size? {
        guard let index = sizes.firstIndex(where: { $0.size == item.size }) else {
            return nil
        }
        
        sizes.remove(at: index)
        sizes.insert(item, at: index)
        return item
    }
}

// MARK: - Extension
extension ItemBuilder {
    func build() -> Item {
        guard let brandName = brandName,
              let clothingName = clothingName,
              let description = description,
              let category = category,
              let color = color else {
                  fatalError("\(ItemBuilderError.emptyFieldsError)")
        }

        let item = Item(photos: nil,
                        brandName: brandName,
                        clothingName: clothingName,
                        description: description,
                        category: category,
                        color: color,
                        sizes: sizes)
        
        return item
    }
}

// MARK: - ItemBuilderError
extension ItemBuilder {
    enum ItemBuilderError: Error {
        case sizeExistError
        case indexNotFoundError
        case emptyFieldsError
        case emptyArraysError
    }
}
