import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol{
    @IBOutlet private weak var questionCountLabel: UILabel!
    @IBOutlet private weak var movieImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        activityIndicator.hidesWhenStopped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        movieImage.layer.cornerRadius = 20
    }
    
    
    @IBAction private func onTapNo() {
        presenter.onTapNo()
    }
    
    @IBAction private func onTapYes() {
        presenter.onTapYes()
    }
    
    func showQuestion(quiz step: QuizStepViewModel) {
        movieImage.image = step.image
        questionLabel.text = step.question
        questionCountLabel.text = step.questionNumber
    }
    
    
    private func triggerHapticFeedback(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(notificationType)
    }
    
    
    func paintBorder(_ isCorrect: Bool) {
        let layer = movieImage.layer
        layer.masksToBounds = true
        layer.borderWidth = 8
        layer.borderColor = (isCorrect ? UIColor.greenBorder : UIColor.redBorder)?.cgColor
        layer.cornerRadius = 20
    }
    

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator(){
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Попробовать ещё раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
    }
    
    
    
    func show(quiz step: QuizStepViewModel) {
        movieImage.layer.borderColor = UIColor.clear.cgColor
        movieImage.image = step.image
        questionLabel.text = step.question
        questionCountLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showFailedToLoadPosterAlert(){

        let alert = UIAlertController(
            title: "Ошибка",
            message: "Ошибка загрузки постера",
            preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
}


