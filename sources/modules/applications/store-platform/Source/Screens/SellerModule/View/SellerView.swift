import UIKit

class SellerView: UIView {
    enum Section: String, CaseIterable {
        case items = "Товары"
        case stats = "Статистика"
        case finance = "Финансы"
    }
    
    // TODO: - Fix string value
    enum SupplementaryKinds: String {
        case addItemButton = "section-header-button-kind"
        case header = "section-header-label-kind"
    }
}

extension SellerView {
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = Section.allCases[sectionIndex]
            switch section {
            case .items:
                return self.itemsSection()
            case .stats:
                return self.statsSection()
            case .finance:
                return self.financeSection()
            }
        }
        return layout
    }
    
    func itemsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                               heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 20.0
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        
        let boundarySize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2),
                                                  heightDimension: .absolute(50))
        
        let boundary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundarySize,
                                                                   elementKind: SupplementaryKinds.addItemButton.rawValue,
                                                                   alignment: .topLeading)
        
        section.boundarySupplementaryItems = [boundary]
        return section
    }
    
    func statsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/1.5),
                                               heightDimension: .fractionalWidth(1/1.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 20.0
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        
        let boundarySize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .absolute(50))
        let boundary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundarySize,
                                                                   elementKind: SupplementaryKinds.header.rawValue,
                                                                   alignment: .topLeading)
        
        section.boundarySupplementaryItems = [boundary]
        return section
    }
    
    func financeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 20.0
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        
        let boundarySize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .absolute(50))
        let boundary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundarySize,
                                                                   elementKind: SupplementaryKinds.header.rawValue,
                                                                   alignment: .topLeading)
        section.boundarySupplementaryItems = [boundary]
        return section
    }
}
