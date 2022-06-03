import UIKit

protocol Factory: AnyObject {
    func buildTabBarModule(coordinator: TabCoordinator) -> UITabBarController
    func buildFeedModule(coordinator: FeedCoordinator) -> UIViewController
    func buildCreateAdModule(coordinator: CreateAdCoordinator) -> UIViewController
    func buildCreateSizeModule(coordinator: CreateAdCoordinator, with item: Size?) -> UIViewController
    func buildImagePickerModule(coordinator: ImagePickerCoordinator) -> UIImagePickerController
    func buildDetailedImageModule(image: Data) -> UIViewController
    func buildLoginModule(coordinator: GuestCoordinator) -> UIViewController
    func buildRegisterModule(coordinator: GuestCoordinator) -> UIViewController
    func buildGuestModule(coordinator: GuestCoordinator) -> UIViewController
    func buildFavoritesModule(coordinator: FavoritesCoordinator) -> UIViewController
    func buildCartModule() -> UIViewController
    func buildSizePickerModule(coordinator: PickSizeCoordinatorProtocol, sizes: [Size]) -> UIViewController
    func buildProfileModule() -> UIViewController
    func buildDetailedAdModule(coordinator: PickSizeCoordinatorProtocol, with item: Item) -> UIViewController
}

class DependencyFactory: Factory {
    func buildTabBarModule(coordinator: TabCoordinator) -> UITabBarController {
        let view = TabBarController()
        let presenter = TabBarPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }

    func buildFeedModule(coordinator: FeedCoordinator) -> UIViewController {
        let view = FeedViewController()
        let presenter = FeedPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildCreateAdModule(coordinator: CreateAdCoordinator) -> UIViewController {
        let view = CreateAdViewController()
        view.tabBarItem.image = UIImage(systemName: "plus.app")
        view.navigationItem.title = "Создание объявления"
        let presenter = CreateAdPresenter(view: view,
                                          itemBuilder: ItemBuilder(),
                                          coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildCreateSizeModule(coordinator: CreateAdCoordinator, with item: Size?) -> UIViewController {
        let view = CreateSizeViewController()
        let presenter = CreateSizePresenter(view: view, coordinator: coordinator, model: item)
        view.presenter = presenter
        return view
    }
    
    func buildImagePickerModule(coordinator: ImagePickerCoordinator) -> UIImagePickerController {
        let view = ImagePickerController()
        let presenter = ImagePickerPresenter(coordinator: coordinator, view: view)
        view.presenter = presenter
        return view
    }
    
    func buildDetailedImageModule(image: Data) -> UIViewController {
        let view = DetailedImageViewController()
        let presenter = DetailedImagePresenter(view: view, with: image)
        view.presenter = presenter
        return view
    }
    
    func buildLoginModule(coordinator: GuestCoordinator) -> UIViewController {
        let view = LoginViewController()
        let presenter = LoginPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildRegisterModule(coordinator: GuestCoordinator) -> UIViewController {
        let view = RegisterViewController()
        let presenter = RegisterPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildGuestModule(coordinator: GuestCoordinator) -> UIViewController {
        let view = GuestViewController()
        let presenter = GuestPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildFavoritesModule(coordinator: FavoritesCoordinator) -> UIViewController {
        let view = FavoritesViewController()
        let presenter = FavoritesPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildProfileModule() -> UIViewController {
        let view = ProfileViewController()
        let presenter = ProfilePresenter(view: view)
        view.presenter = presenter
        return view
    }
    
    func buildCartModule() -> UIViewController {
        let view = CartViewController()
        let presenter = CartPresenter(view: view)
        view.presenter = presenter
        return view
    }
    
    func buildSizePickerModule(coordinator: PickSizeCoordinatorProtocol, sizes: [Size]) -> UIViewController {
        let view = PickSizeViewController()
        let presenter = PickSizePresenter(view: view, sizes: sizes, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildDetailedAdModule(coordinator: PickSizeCoordinatorProtocol, with item: Item) -> UIViewController {
        let view = DetailedAdViewController()
        let presenter = DetailedAdPresenter(view: view, coordinator: coordinator, item: item)
        view.presenter = presenter
        return view
    }
    
    deinit {
        debugPrint("factory deinit")
    }
}
