import UIKit
import SPAlert
import SwiftUI

// MARK: - CreateAd View Protocol
protocol CreateAdViewProtocol: AnyObject {
    func configureCollectionView()
    func configureDataSource()
    func insertPlaceholders()
    func insertSizeSection(item: Size)
    func updateSizeSection(item: Size)
    func didSelectItem(item: Size)
    func didSelectCategory(_ category: String)
    func didSelectColor(_ color: String)
    func insertImage(_ data: Data)
    func didSelectImage(with data: Data)
    func showSuccessAlert()
    func showErrorAlert(_ description: String)
}

// MARK: - CreateAdViewController
class CreateAdViewController: UIViewController {
    var createAdView = CreateAdView()
    var collectionView: UICollectionView! = nil
    
    weak var textFieldsDelegate: TextFieldsViewDelegate?
    var presenter: CreateAdPresenter!
    
    var dataSource: UICollectionViewDiffableDataSource<CreateAdView.Section, AnyHashable>?
    typealias DataSource = UICollectionViewDiffableDataSource<CreateAdView.Section, AnyHashable>
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    deinit {
        presenter.finish()
    }
}

// MARK: - CreateAdViewProtocol Implementation
extension CreateAdViewController: CreateAdViewProtocol {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createAdView.generateLayout())
        
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseId)
        collectionView.register(HeaderView.self,
                                forSupplementaryViewOfKind: CreateAdView.SupplementaryKinds.header.rawValue,
                                withReuseIdentifier: HeaderView.reuseId)
        collectionView.register(TextFieldsView.self,
                                forSupplementaryViewOfKind: CreateAdView.SupplementaryKinds.fields.rawValue,
                                withReuseIdentifier: TextFieldsView.reuseId)
        collectionView.register(ExtraSettingsCell.self, forCellWithReuseIdentifier: ExtraSettingsCell.reuseId)
        collectionView.register(SizeCell.self, forCellWithReuseIdentifier: SizeCell.reuseId)
        collectionView.register(BottomViewWithButton.self,
                                forSupplementaryViewOfKind: CreateAdView.SupplementaryKinds.bottomButton.rawValue,
                                withReuseIdentifier: BottomViewWithButton.reuseId)
        
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        
        self.collectionView = collectionView
        
        view.addSubview(collectionView)
        collectionView.frame = view.frame
    }
    
    func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            let section = CreateAdView.Section.allCases[indexPath.section]
            switch section {
            case .photos:
                guard let self = self else { fatalError() }
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseId, for: indexPath) as? PhotoCell else { fatalError() }
                cell.delegate = self
                
                if indexPath.row == 0 { cell.addPlaceholder() } else {
                    guard let itemIdentifier = itemIdentifier as? UIImage else { fatalError() }
                    cell.configureViews(with: itemIdentifier)
                }
                
                return cell
            case .category, .color:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExtraSettingsCell.reuseId, for: indexPath) as? ExtraSettingsCell else { fatalError() }
                cell.configure(category: itemIdentifier.description)
                
                return cell
            case .sizeCreating:
                guard let self = self else { fatalError() }
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SizeCell.reuseId, for: indexPath) as? SizeCell else {
                    fatalError() }
                
                cell.delegate = self
                
                if indexPath.row == 0 { cell.makePlaceholder() } else {
                    guard let size = itemIdentifier as? Size else { fatalError() }
                    cell.configure(size: size)
                }
                
                return cell
            }
        })
        
        dataSource?.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let self = self else { fatalError() }
            
            switch kind {
            case "section-header-element-kind":
                guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseId, for: indexPath) as? HeaderView else { fatalError() }
                supplementaryView.label.text = CreateAdView.Section.allCases[indexPath.section].rawValue
                return supplementaryView
            case "section-bottom-fields-kind":
                guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TextFieldsView.reuseId, for: indexPath) as? TextFieldsView else { fatalError() }
                self.textFieldsDelegate = supplementaryView
                return supplementaryView
            case "section-bottom-button-kind":
                guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BottomViewWithButton.reuseId, for: indexPath) as? BottomViewWithButton else { fatalError() }
                supplementaryView.delegate = self
                return supplementaryView
            default:
                return nil
            }
        }
        
    }
    
    func insertPlaceholders() {
        var snapshot = NSDiffableDataSourceSnapshot<CreateAdView.Section, AnyHashable>()
        let placeholder = AnyHashable(1)
        snapshot.appendSections([.photos])
        snapshot.appendItems([placeholder])
        
        let categories = ["Футболка", "Толстовка", "Брюки", "Кофта", "Джинсы", "Куртка", "Рубашка", "Джерси"]
        snapshot.appendSections([.category])
        snapshot.appendItems(categories)
        
        let colors = ["Черный", "Белый", "Красный", "Синий", "Зеленый", "Желтый", "Оранжевый", "Фиолетовый", "Бежевый", "Хаки", "Разноцветный"]
        snapshot.appendSections([.color])
        snapshot.appendItems(colors)
        
        snapshot.appendSections([.sizeCreating])
        snapshot.appendItems([AnyHashable(3)]) // Placeholder for adding sizes
        
        dataSource?.apply(snapshot)
    }
        
    func insertSizeSection(item: Size) {
        var newSnapshot = dataSource?.snapshot()
        newSnapshot?.appendItems([item], toSection: .sizeCreating)
        dataSource?.apply(newSnapshot!)
    }
    
    // TODO: Bad solution -> fix
    func updateSizeSection(item: Size) {
        var newSnapshot = dataSource?.snapshot()
        guard let old = newSnapshot?.itemIdentifiers.first(where: {($0 as? Size)?.size == item.size}) else {
            return
        }
        
        newSnapshot?.insertItems([item], beforeItem: old)
        newSnapshot?.deleteItems([old])
        dataSource?.apply(newSnapshot!)
    }
    
    func didSelectItem(item: Size) {
        presenter.editSizeView(item)
    }
    
    func didSelectCategory(_ category: String) {
        presenter.setCategory(category)
    }
    
    func didSelectColor(_ color: String) {
        presenter.setColor(color)
    }
    
    func insertImage(_ data: Data) {
        var newSnapshot = dataSource?.snapshot()
        let image = UIImage(data: data)
        newSnapshot?.appendItems([image], toSection: .photos)
        dataSource?.apply(newSnapshot!)
    }
    
    func didSelectImage(with data: Data) {
        presenter.showImage(data: data)
    }
    
    func showSuccessAlert() {
        SPAlert.present(title: "Успех", message: "Позиция успешно добавлена!", preset: .done)
    }
    
    func showErrorAlert(_ description: String) {
        SPAlert.present(title: "Ошибка", message: "\(description)", preset: .error)
    }
}
// MARK: - Bottom View Delegate
extension CreateAdViewController: BottomViewDelegate {
    func didTappedAddProductButton() {
        let clothingName = textFieldsDelegate?.getClothingName()
        let description = textFieldsDelegate?.getDescription()
        presenter.setClothingName(clothingName!)
        presenter.setDescription(description!)
        presenter.buildProduct()
    }
}
// MARK: - Size Cell Delegate
extension CreateAdViewController: SizeCellDelegate {
    func didTappedAddSizeButton() {
        presenter.openSizeView()
    }
}

// MARK: - Photo Cell Delegate
extension CreateAdViewController: PhotoCellDelegate {
    func didTappedAddPhotoButton() {
        presenter.showImagePicker()
    }
}

// MARK: - Collection View Delegate
extension CreateAdViewController: UICollectionViewDelegate {
    // TODO: Make unselected item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedSection = CreateAdView.Section.allCases[indexPath.section]
        switch selectedSection {
        case .photos:
            let photo = dataSource?.itemIdentifier(for: indexPath)
            guard let photo = photo as? UIImage else {
                fatalError("Casting error")
            }
            didSelectImage(with: photo.pngData()!)
        case .category:
            let category = dataSource?.itemIdentifier(for: indexPath)
            guard let category = category as? String,
                  let cell = collectionView.cellForItem(at: indexPath) as? ExtraSettingsCell else {
                fatalError("Unwrap error")
            }
            
            cell.selectEllipse()
            didSelectCategory(category)
        case .color:
            let color = dataSource?.itemIdentifier(for: indexPath)
            guard let color = color as? String,
                  let cell = collectionView.cellForItem(at: indexPath) as? ExtraSettingsCell else {
                fatalError("Unwrap error")
                
            }
            
            cell.selectEllipse()
            didSelectColor(color)
        case .sizeCreating:
            let size = dataSource?.itemIdentifier(for: indexPath) as? Size
            guard let size = size else {
                fatalError("Unwrap error")
            }
            didSelectItem(item: size)
        }
    }
}
