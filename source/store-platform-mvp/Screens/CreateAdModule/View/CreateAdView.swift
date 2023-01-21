import UIKit

class CreateAdView: UIView {
    enum Section: String, CaseIterable {
        case photos = "Фотографии"
        case category = "Категория"
        case color = "Цвет"
        case sizeCreating = "Учет товаров"
    }
    
    // TODO: - Fix string value
    enum SupplementaryKinds: String {
        case header = "section-header-element-kind"
        case fields = "section-bottom-fields-kind"
        case bottomButton = "section-bottom-button-kind"
    }
        
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = Section.allCases[sectionIndex]
            switch section {
            case .photos:
                return self.photosSection()
            case .category, .color: // similar layout
                return self.extraSettingsSection()
            case .sizeCreating:
                return self.sizeCreatingSection()
            }
        }
        return layout
    }
    
    // MARK: - Layout for photo section
    func photosSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(81),
                                              heightDimension: .absolute(81))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(81))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
        group.interItemSpacing = .fixed(20)
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: SupplementaryKinds.header.rawValue,
                                                                 alignment: .topLeading)
        let bottomSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(200))

        // In bottom boundary stored textFields
        let bottom = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: bottomSize,
                                                                 elementKind: SupplementaryKinds.fields.rawValue,
                                                                 alignment: .bottom)

        section.boundarySupplementaryItems = [header, bottom]
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 30, trailing: 20)
        section.interGroupSpacing = 20
        return section
    }
    
    // MARK: - Layout for extra settings section (categories, colors, etc..)
    func extraSettingsSection() -> NSCollectionLayoutSection {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: "section-header-element-kind",
                                                                 alignment: .topLeading)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(90),
                                               heightDimension: .absolute(26))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    // MARK: - Layout for size section
    func sizeCreatingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(81),
                                              heightDimension: .absolute(81))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(81))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
        group.interItemSpacing = .fixed(20)
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: SupplementaryKinds.header.rawValue,
                                                                 alignment: .topLeading)

        let bottomSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(34))
        
        // bottom boundary has button for adding items
        let bottom = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: bottomSize,
                                                                 elementKind: SupplementaryKinds.bottomButton.rawValue,
                                                                 alignment: .bottom)
        section.boundarySupplementaryItems = [header, bottom]
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 20
        return section
    }
}
