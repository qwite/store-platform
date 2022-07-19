import UIKit

// MARK: - MessagesListViewProtocol
protocol MessagesListViewProtocol: AnyObject {
    func configureViews()
    func configureCollectionView()
    func configureDataSource()
    func insertConversations(data: [Conversation])
    func addConversationsPlaceholder()
}

// MARK: - MessagesListViewController
class MessagesListViewController: UIViewController {
    var presenter: MessagesListPresenterProtocol!
    var messagesListView = MessagesListView()
    
    lazy var placeholderLabel = UILabel()
    var collectionView: UICollectionView! = nil
    
    var dataSource: UICollectionViewDiffableDataSource<MessagesListView.Section, Conversation>?
    typealias DataSource = UICollectionViewDiffableDataSource<MessagesListView.Section, Conversation>
    
    // MARK: Lifecycle
    override func loadView() {
        view = messagesListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        title = "Чаты"
    }
}

// MARK: - MessagesListViewProtocol Implementation
extension MessagesListViewController: MessagesListViewProtocol {
    func addConversationsPlaceholder() {
        placeholderLabel.text = "Диалоги не найдены"
        placeholderLabel.font = Constants.Fonts.itemDescriptionFont
        
        view.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
        }
    }
    
    func configureViews() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalTo(view.snp.width)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: messagesListView.configureLayout())
        collectionView.register(MessageListCell.self, forCellWithReuseIdentifier: MessageListCell.reuseId)
        collectionView.delegate = self
        self.collectionView = collectionView
    }
    
    func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let section = MessagesListView.Section.allCases[indexPath.section]
            switch section {
            case .list:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageListCell.reuseId, for: indexPath) as? MessageListCell else { fatalError() }
                
                cell.configure(messageListItem: itemIdentifier)
                return cell
            }
        })
        
        let snapshot = snapshotForCurrentState()
        dataSource?.apply(snapshot)
    }
    
    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<MessagesListView.Section, Conversation> {
        var snapshot = NSDiffableDataSourceSnapshot<MessagesListView.Section, Conversation>()

        snapshot.appendSections([.list])
        return snapshot
    }
    
    func insertConversations(data: [Conversation]) {
        guard var snapshot = dataSource?.snapshot() else {
            fatalError()
        }
        
        snapshot.appendItems(data, toSection: .list)

        dataSource?.apply(snapshot)
    }
}

// MARK: - UICollectionViewDelegate
extension MessagesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) as? Conversation else {
            fatalError()
        }
        
        presenter.showMessenger(with: item.id)
    }
}
