import UIKit

class SellerHeaderView: UICollectionReusableView {
    static let reuseId = "SellerHeader"
    let label = UILabel(text: nil, font: nil, textColor: .black)
}

extension SellerHeaderView {
    func configureViews() {
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalTo(snp.edges)
        }
    }
}
