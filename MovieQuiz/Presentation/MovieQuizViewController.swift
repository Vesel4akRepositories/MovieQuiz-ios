import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var questionCountLabel: UILabel!
    @IBOutlet private weak var movieImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    
    private var correctCount = 0
    
    private var currentQuestionIndex = 0
    
    private let questionsAmount: Int = 10
    private lazy var questionFactory: QuestionFactoryProtocol = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    private var currentQuestion: QuizQuestion?
    private let statisticService: StatisticService = StatisticServiceImplementation()
    private let alertPresenter = AlertPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter.uiViewController = self
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        movieImage.layer.cornerRadius = 20
    }
    
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.showQuestion(quiz: viewModel)
        }
    }
    
    
    @IBAction private func onTapNo() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
    @IBAction private func onTapYes() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    private func showQuestion(quiz step: QuizStepViewModel) {
        movieImage.image = step.image
        questionLabel.text = step.question
        questionCountLabel.text = step.questionNumber
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func triggerHapticFeedback(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(notificationType)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctCount += 1;
            triggerHapticFeedback(.success)
        } else {
            triggerHapticFeedback(.error)
        }
        paintBorder(isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self]  in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func paintBorder(_ isCorrect: Bool) {
        let layer = movieImage.layer
        layer.masksToBounds = true
        layer.borderWidth = 8
        layer.borderColor = (isCorrect ? UIColor.greenBorder : UIColor.redBorder)?.cgColor
        layer.cornerRadius = 20
    }
    
    private func showNextQuestionOrResults() {
        movieImage.layer.borderWidth = 0 // Убрать border
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctCount, total: questionsAmount)
            
            let gamesPlayed = statisticService.gamesCount
            let bestRecord = statisticService.bestGame
            let totalAccuracy = statisticService.totalAccuracy
            
            let bestGameDateString = bestRecord.date.dateTimeString
            
            let text = """
            Ваш результат: \(correctCount)/\(questionsAmount)
            Количество сыгранных квизов: \(gamesPlayed)
            Рекорд: \(bestRecord.correct)/\(bestRecord.total) (\(bestGameDateString))
            Средняя точность: \(String(format: "%.2f", totalAccuracy * 100))%
            """
            
            // Создаем модель алерта
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    self?.resetQuiz()
                }
            )
            
            // Показываем алерт с результатами
            alertPresenter.showResults(alertModel: alertModel)
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    private func resetQuiz() {
        currentQuestionIndex = 0
        correctCount = 0
        questionFactory.requestNextQuestion()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator(){
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctCount = 0
            
            self.questionFactory.requestNextQuestion()
        }
        
        alertPresenter.showResults(alertModel: model)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    
}


