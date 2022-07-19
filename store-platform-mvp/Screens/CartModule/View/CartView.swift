import UIKit

// MARK: - CartView
class CartView: UIView {
    enum Section: Int, CaseIterable {
        case cart
    }
    
    enum SupplementaryKinds: String {
        case totalCart = "section-bottom-total-cart"
    }
}

// MARK: - Public methods
extension CartView {
    func configureLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20.0
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20)
        
        let supplementaryItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .absolute(150))
        let supplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: supplementaryItemSize, elementKind: SupplementaryKinds.totalCart.rawValue, alignment: .bottom)
        section.boundarySupplementaryItems = [supplementaryItem]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
