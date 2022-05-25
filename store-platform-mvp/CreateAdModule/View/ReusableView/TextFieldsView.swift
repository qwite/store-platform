import UIKit

protocol TextFieldsViewProtocol: AnyObject {
    func getClothingName() -> String
    func getDescription() -> String
}

class TextFieldsView: UICollectionReusableView {
    static let reuseId = "TextFields"
    
    private let spacing: CGFloat = 5
    
    lazy var nameLabel = UILabel(text: "Название",
                                 font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                 textColor: .lightGray)

    lazy var descriptionLabel = UILabel(text: "Описание",
                                        font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                        textColor: .lightGray)

    lazy var nameTextField = UITextField(placeholder: "Толстовка с принтом",
                                          withUnderline: true,
                                          keyboardType: .default,
                                          isSecureTextEntry: false)
        
    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.textAlignment = .left
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        textView.textContainer.maximumNumberOfLines = 8
        textView.text = "Бац бац и крутое описание!"
        return textView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextFieldsView {
    func configureViews () {
        let nameStack = UIStackView(arrangedSubviews: [nameLabel, nameTextField], spacing: 5, axis: .vertical, alignment: .fill)
        let descriptionStack = UIStackView(arrangedSubviews: [descriptionLabel, descriptionTextView], spacing: 5, axis: .vertical, alignment: .fill)
        let stack = UIStackView(arrangedSubviews: [nameStack, descriptionStack], spacing: 10, axis: .vertical, alignment: .fill)
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.size.equalTo(snp.size)
        }
    }
}

extension TextFieldsView: TextFieldsViewProtocol {

    
    func getClothingName() -> String {
        return nameTextField.text!
    }
    
    func getDescription() -> String {
        return descriptionTextView.text!
    }
}

//
//extension TextFieldsView: UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.textColor == .systemGray {
//            textView.text = ""
//            textView.textColor = .black
//        }
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = "Объемная худи с капюшоном из коллекции, посвященной городу Москва, с дизайном в тематике World Tour."
//            textView.textColor = .systemGray
//        }
//    }
//}
