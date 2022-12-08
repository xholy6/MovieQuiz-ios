import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        updateStatusButton(isActive: false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        updateStatusButton(isActive: false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer )
    }
    
    // MARK: - Private Functions
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage() ,
                          question: model.text ,
                          questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        
        correctAnswers += isCorrect ?  1 : 0
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        updateStatusButton(isActive: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        currentQuestionIndex += 1
        if currentQuestionIndex == questionsAmount {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let alertText = "Ваш результат: \(correctAnswers)/\(questionsAmount) \n" +
            "Количество сыгранных квизов: \(statisticService.gamesCount)" +
            "\n Рекорд: \(statisticService.bestGame.toString())" +
            "\n Средняя точность:  \(String(format: "%.2f", statisticService.totalAccuracy))%"
            show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!" , text: alertText, buttonText: "Сыграть еще раз"))
            questionFactory?.requestNextQuestion()
        } else {
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func updateStatusButton(isActive: Bool) {
        yesButton.isEnabled = isActive
        noButton.isEnabled = isActive
    }
    
    private func drawLoader() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func didLoadDataFromServer() {
        drawLoader()
        questionFactory?.requestNextQuestion()
        activityIndicator.stopAnimating()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        let alert = AlertModel(title: "Ошибка",
                               message: "",
                               buttonText: "Попробовать еще раз") { [weak self ] _ in
            guard let self = self else  { return }
            self.drawLoader()
            self.showNextQuestionOrResults()
        }
        alertPresenter?.showAlert(alertModel: alert)
    }
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        statisticService = StatisticServiceImplementation()
        activityIndicator.hidesWhenStopped = true
        drawLoader()
        questionFactory?.loadData()
        alertPresenter = AlertPresenter()
        alertPresenter?.vcDelegate = self
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            self?.updateStatusButton(isActive: true)
        }
    }
    
    // MARK: - AlertPresenterDelegate
    
    func didPresentAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
}
