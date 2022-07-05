import UIKit

protocol AvailableParametersView: AnyObject {
    func configureTableView()
    func configureDataSource()
    func configureViews()
    
    func updateDataSource(items: [Parameter])
    func getSelectedItems()
}

class AvailableParametersViewController: UIViewController {
    var tableView: UITableView! = nil
    var presenter: AvailableParametersPresenter!
    var dataSource: UITableViewDiffableDataSource<Sections, Parameter>?
    typealias DataSource = UITableViewDiffableDataSource<Sections, Parameter>
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.getSelectedItems()
    }
}

extension AvailableParametersViewController: AvailableParametersView {
    func configureTableView() {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(AvailableParametersCell.self, forCellReuseIdentifier: AvailableParametersCell.reuseId)
        tableView.delegate = self
        self.tableView = tableView
    }
    
    func configureDataSource() {
        dataSource = DataSource(tableView: self.tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let sections = Sections.allCases[indexPath.section]
            switch sections {
            case .parameters:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: AvailableParametersCell.reuseId, for: indexPath) as? AvailableParametersCell else { fatalError("dequeue error")}
                
                cell.tintColor = .black
                itemIdentifier.isSelected ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
                cell.textLabel?.text = itemIdentifier.option
                return cell
            }
        })
    }
    
    func configureViews() {
        self.view.backgroundColor = .white
        self.tableView.backgroundColor = .clear
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        let clearButton = UIButton(text: "Очистить", preset: .clearButton)
        view.addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.right.equalTo(view.snp.right).offset(-20)
            make.width.equalTo(80)
            make.height.equalTo(20)
        }
    }
    
    func clearSelectedItems() {
        guard let snapshot = dataSource?.snapshot() else { return }
        let items = snapshot.itemIdentifiers
        dataSource?.apply(snapshot)
    }
    
    func updateDataSource(items: [Parameter]) {
        var snapshot = dataSource?.snapshot()
        snapshot?.appendSections([.parameters])
        snapshot?.appendItems(items)
        dataSource?.apply(snapshot!)
    }
    
    func getSelectedItems() {
        guard let snapshot = dataSource?.snapshot() else { return }
        let items = snapshot.itemIdentifiers
        let selectedItems = items.filter({ $0.isSelected == true })
        presenter.shareSelectedItems(selectedItems: selectedItems)
    }
}

extension AvailableParametersViewController {
    enum Sections: Int, CaseIterable {
        case parameters
    }
}

extension AvailableParametersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let item = dataSource?.itemIdentifier(for: indexPath),
              var snapshot = dataSource?.snapshot(),
              let cell = dataSource?.tableView(tableView, cellForRowAt: indexPath) else { return }
        let newItem = Parameter(option: item.option, type: item.type, isSelected: !item.isSelected)
        
        snapshot.insertItems([newItem], beforeItem: item)
        snapshot.deleteItems([item])
            
        switch newItem.isSelected {
        case true:
            cell.accessoryType = .checkmark
        case false:
            cell.accessoryType = .none
        }
        
        dataSource?.apply(snapshot, animatingDifferences: false)
        
    }
}
