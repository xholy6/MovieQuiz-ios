import UIKit

struct AlertPresenter {
    
    weak var vcDelegate: AlertPresenterDelegate?
    
    func showAlert(alertModel: AlertModel) {
        
        let alert = UIAlertController(title: alertModel.title,
                                      message: alertModel.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText,
                                   style: .default,
                                   handler: alertModel.completion)
        alert.addAction(action)
        
        vcDelegate?.didPresentAlert(alert: alert)
        
    }
}


