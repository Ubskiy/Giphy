import UIKit

// Экран на котором показываются гифки
final class GiphyViewController: UIViewController {
    private var alertPresenter: AlertPresenterProtocol?
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var giphyImageView: UIImageView!
    @IBOutlet weak var giphyActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var likeButtonLabel: UIButton!
    @IBOutlet weak var dislikeButtonLabel: UIButton!
    
    // Нажатие на кнопку лайка
    @IBAction func onYesButtonTapped() {
        presenter.yesButtonAction()
    }
    
    // Нажатие на кнопку дизлайка
    @IBAction func onNoButtonTapped() {
        presenter.noButtonAction()
    }
    
    // Слой Presenter - бизнес логика приложения, к которым должен общаться UIViewController
    private lazy var presenter: GiphyPresenterProtocol = {
        let presenter = GiphyPresenter()
        presenter.viewController = self
        return presenter
    }()
    
    // MARK: - Жизненный цикл экрана
    
    override func viewDidLoad() {
        super.viewDidLoad()
        giphyImageView.layer.masksToBounds = true
        giphyImageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenter(viewController: self)
        restart()
    }
}
    
    // MARK: - Приватные методы
    private extension GiphyViewController {
        
        func updateCounterLabel() {
            presenter.switchToNextIndex() // Учеличиваем счетчик просмотренных гифок на 1
            counterLabel.text = "\(presenter.returnCurrentIndex())/\(presenter.returnGifAmount())"
            // Обновляем UILabel который находится в верхнем UIStackView и отвечает за количество просмотренных гифок
        }
        
        func restart() {
            interactionEnable()
            presenter.restart()
            presenter.fetchNextGiphy()//загружаем гифку
        }
    }
    
    // MARK: - GiphyViewControllerProtocol
    
    extension GiphyViewController: GiphyViewControllerProtocol {
        // Показ ошибки UIAlertController, что не удалось загрузить гифку
        func showError() {
            let title = "Что-то пошло не так("
            let buttonText = "Попробовать еще раз"
            let text = "Невозможно загрузить данные"
            let alertModel = AlertModel(
                title: title,
                message: text,
                buttonText: buttonText,
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.restart()
                })
            alertPresenter?.show(results: alertModel)
        }
        
        func showEndOfGiphy() {
            let title = "Мемы закончились!"
            let buttonText = "Хочу посмотреть еще гифок"
            let text = "Вам понравилось \(presenter.returnLikedGifAmount())/10"
            let alertModel = AlertModel(
                title: title,
                message: text,
                buttonText: buttonText,
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.restart()
                })
            alertPresenter?.show(results: alertModel)
        }
        
        // Показать гифку UIImage
        func showGiphy(_ image: UIImage?) {
            giphyImageView.image = image
            updateCounterLabel()
        }
        
        func showLoader() {
            giphyImageView.image = nil
            giphyActivityIndicatorView.isHidden = false
            giphyActivityIndicatorView.startAnimating()
        }
        
        // Остановить giphyActivityIndicatorView показа индикатора загрузки
        func hideHoaler() {
            giphyActivityIndicatorView.stopAnimating()
            giphyActivityIndicatorView.isHidden = true
        }
        
        func interactionDisable() {
            likeButtonLabel.isEnabled = false
            dislikeButtonLabel.isEnabled = false
        }
        
        func interactionEnable() {
            giphyImageView.layer.borderWidth = 0
            likeButtonLabel.isEnabled = true
            dislikeButtonLabel.isEnabled = true
        }
        
        func highlightImageBorder(isCorrectAnswer: Bool) {
            giphyImageView.layer.borderWidth = 8
            giphyImageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
            interactionDisable()
        }
    }


