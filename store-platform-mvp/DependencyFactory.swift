import UIKit

protocol Factory: AnyObject {
    func buildTabBarModule(coordinator: TabCoordinator) -> UITabBarController
    func buildAvailableParametersModule(delegate: AvailableParameterPresenterDelegate, type: Parameter.ParameterType) -> UIViewController
    func buildCreateAdModule(coordinator: CreateAdCoordinator) -> UIViewController
    func buildUserOrdersModule(coordinator: ProfileCoordinator) -> UIViewController
    func buildDetailedOrderModule(coordinator: ProfileCoordinator, order: Order) -> UIViewController
    func buildDetailedProfileModule(coordinator: ProfileCoordinator) -> UIViewController
    func buildSellerOrdersModule(coordinator: SellerCoordinator) -> UIViewController
    func buildChangeOrderStatusModule(coordinator: SellerCoordinator, order: Order) -> UIViewController
    func buildSettingsModule(coordinator: ProfileCoordinator) -> UIViewController
    func buildCreateSizeModule(coordinator: CreateAdCoordinator, with item: Size?) -> UIViewController
    func buildImagePickerModule(coordinator: ImagePickerCoordinator, delegate: ImagePickerPresenterDelegate) -> UIImagePickerController
    func buildDetailedImageModule(image: Data) -> UIViewController
    func buildLoginModule(coordinator: GuestCoordinator) -> UIViewController
    func buildRegisterModule(coordinator: GuestCoordinator) -> UIViewController
    func buildGuestModule(coordinator: GuestCoordinator) -> UIViewController
    func buildSizePickerModule(coordinator: SizePickerCoordinatorProtocol, item: Item) -> UIViewController
    func buildProfileModule(coordinator: ProfileCoordinator) -> UIViewController
    func buildOnboardingModule(coordinator: OnboardingCoordinator) -> UIViewController
    func buildFillBrandDataModule(coordinator: OnboardingCoordinator) -> UIViewController
    func buildSellerModule(coordinator: SellerCoordinator) -> UIViewController
    func buildMessengerModule(conversationId: String?, brandId: String?, coordinator: MessagesCoordinatorProtocol) -> UIViewController
    func buildListMessagesModule(role: RealTimeService.ChatRole, coordinator: MessagesCoordinatorProtocol) -> UIViewController
}

class DependencyFactory: Factory {
    func buildTabBarModule(coordinator: TabCoordinator) -> UITabBarController {
        let view = TabBarController()
        let presenter = TabBarPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildAvailableParametersModule(delegate: AvailableParameterPresenterDelegate, type: Parameter.ParameterType) -> UIViewController {
        let view = AvailableParametersViewController()
        let presenter = AvailableParametersPresenter(view: view, delegate: delegate, type: type)
        view.presenter = presenter
        return view
    }
        
    func buildCreateAdModule(coordinator: CreateAdCoordinator) -> UIViewController {
        let view = CreateAdViewController()
        view.tabBarItem.image = UIImage(systemName: "plus.app")
        view.navigationItem.title = "Создание объявления"
        let userService = TOUserService()
        let presenter = CreateAdPresenter(view: view,
                                          itemBuilder: ItemBuilder(),
                                          coordinator: coordinator, service: userService)
        view.presenter = presenter
        return view
    }
    
    func buildCreateSizeModule(coordinator: CreateAdCoordinator, with item: Size?) -> UIViewController {
        let view = CreateSizeViewController()
        let presenter = CreateSizePresenter(view: view, coordinator: coordinator, model: item)
        view.presenter = presenter
        return view
    }
    
    func buildChangeOrderStatusModule(coordinator: SellerCoordinator, order: Order) -> UIViewController {
        let view = ChangeOrderStatusViewController()
        let presenter = ChangeOrderStatusPresenter(view: view, coordinator: coordinator, order: order)
        view.presenter = presenter
        return view
    }
    
    func buildImagePickerModule(coordinator: ImagePickerCoordinator, delegate: ImagePickerPresenterDelegate) -> UIImagePickerController {
        let view = ImagePickerController()
        let presenter = ImagePickerPresenter(coordinator: coordinator, view: view)
        presenter.delegate = delegate
        view.presenter = presenter
        return view
    }
    
    func buildDetailedImageModule(image: Data) -> UIViewController {
        let view = DetailedImageViewController()
        let presenter = DetailedImagePresenter(view: view, with: image)
        view.presenter = presenter
        return view
    }
    
    func buildSellerOrdersModule(coordinator: SellerCoordinator) -> UIViewController {
        let view = SellerOrdersViewController()
        let presenter = SellerOrdersPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildDetailedProfileModule(coordinator: ProfileCoordinator) -> UIViewController {
        let view = DetailedProfileViewController()
        let presenter = DetailedProfilePresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildUserOrdersModule(coordinator: ProfileCoordinator) -> UIViewController {
        let view = UserOrdersViewController()
        let presenter = UserOrdersPresenter(view: view, coordinator: coordinator)
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
    
    func buildProfileModule(coordinator: ProfileCoordinator) -> UIViewController {
        let view = ProfileViewController()
        let service = TOUserService()
        let presenter = ProfilePresenter(view: view, service: service, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildSettingsModule(coordinator: ProfileCoordinator) -> UIViewController {
        let view = SettingsViewController()
        let presenter = SettingsPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildDetailedOrderModule(coordinator: ProfileCoordinator, order: Order) -> UIViewController {
        let view = DetailedOrderViewController()
        let presenter = DetailedOrderPresenter(view: view, order: order, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildSizePickerModule(coordinator: SizePickerCoordinatorProtocol, item: Item) -> UIViewController {
        let view = SizePickerViewController()
        let presenter = PickSizePresenter(view: view, item: item, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
        
    func buildOnboardingModule(coordinator: OnboardingCoordinator) -> UIViewController {
        let view = OnboardingViewController()
        let presenter = OnboardingPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildFillBrandDataModule(coordinator: OnboardingCoordinator) -> UIViewController {
        let view = FillBrandDataViewController()
        let service = TOUserService()
        let presenter = FillBrandDataPresenter(view: view, coordinator: coordinator, service: service)
        view.presenter = presenter
        return view
    }
    
    func buildSellerModule(coordinator: SellerCoordinator) -> UIViewController {
        let view = SellerViewController()
        let service = TOUserService()
        let presenter = SellerPresenter(view: view, coordinator: coordinator, service: service)
        view.presenter = presenter
        return view
    }
    
    func buildMessengerModule(conversationId: String?, brandId: String?, coordinator: MessagesCoordinatorProtocol) -> UIViewController {
        let view = MessengerViewController()
        let service = TOUserService()
        let presenter = MessengerPresenter(view: view, service: service, conversationId: conversationId, brandId: brandId, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    func buildListMessagesModule(role: RealTimeService.ChatRole, coordinator: MessagesCoordinatorProtocol) -> UIViewController {
        let view = MessagesListViewController()
        let service = TOUserService()
        let presenter = MessagesListPresenter(view: view, role: role, service: service, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    deinit {
        debugPrint("factory deinit")
    }
}
