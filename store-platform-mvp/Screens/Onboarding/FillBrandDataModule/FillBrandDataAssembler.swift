import UIKit

// MARK: - FillBrandDataAssembler
class FillBrandDataAssembler {
    static func buildFillBrandDataModule(coordinator: OnboardingCoordinator) -> UIViewController {
        let service = BrandService()
        let builder = BrandBuilderImpl()
        let view = FillBrandDataViewController()
        let presenter = FillBrandDataPresenter(view: view, coordinator: coordinator, service: service, builder: builder)
        view.presenter = presenter
        return view
    }
}
