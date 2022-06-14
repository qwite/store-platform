import UIKit

class StatTitleView: UICollectionReusableView {
    static let reuseId = "StatTitle"
    let title = UILabel(text: "Something", font: nil, textColor: .black)
}

extension StatTitleView {
    func configureViews() {
        title.font = Constants.Fonts.itemTitleFont
        addSubview(title)
        title.snp.makeConstraints { make in
            make.edges.equalTo(snp.edges)
        }
    }
}
