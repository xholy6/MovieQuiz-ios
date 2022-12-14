import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate?){
        self.delegate = delegate
    }
    
    func showAlert(alertModel: AlertModel) {
        
        let alert = UIAlertController(title: alertModel.title,
                                      message: alertModel.message,
                                      preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = "Game Results"
        
        let action = UIAlertAction(title: alertModel.buttonText,
                                   style: .default,
                                   handler: alertModel.completion)
        alert.addAction(action)
        delegate?.didPresentAlert(alert: alert)
        
    }
}


