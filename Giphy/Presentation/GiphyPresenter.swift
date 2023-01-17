import Foundation
import UIKit
import Photos

// Presenter (бизнес слой для получения слудеющей гифки)
final class GiphyPresenter: GiphyPresenterProtocol {
    private var showedGifCounter: Int = 0 //Счетчик показанных гифок
    private var likedGifCounter: Int = 0 //Счетчик лайкнутых гифок
    private var gifAmount: Int = 10 //кол-во гифок
    private var giphyFactory: GiphyFactoryProtocol
    // Слой View для общения и отображения случайной гифки
    weak var viewController: GiphyViewController?
    
    // MARK: - GiphyPresenterProtocol
    
    init(giphyFactory: GiphyFactoryProtocol = GiphyFactory()) {
        self.giphyFactory = giphyFactory
        self.giphyFactory.delegate = self
    }
    
    // Загрузка следующей гифки
    func fetchNextGiphy() {
        // Необходимо показать лоадер
        viewController?.showLoader()
        // Обратиться к фабрике и начать грузить новую гифку
        giphyFactory.requestNextGiphy()
    }
    
    // Сохранение гифки
    func saveGif(_ image: UIImage?) {
        guard let data = image?.pngData() else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: data, options: nil)
        })
    }
    
    private func didAnswer(isTrue: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isTrue)
        viewController?.interactionDisable()
        saveGif(viewController?.giphyImageView.image)
        // Проверка на то просмотрели или нет 10 гифок
        if showedGifCounter == gifAmount {
            viewController?.showEndOfGiphy()
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else {return}
                self.viewController?.interactionEnable()
                self.fetchNextGiphy()
            }
        }
    }
    
    func yesButtonAction() {
        likedGifCounter += 1
        didAnswer(isTrue: true)
    }
    
    func noButtonAction() {
        didAnswer(isTrue: false)
    }
    
    func switchToNextIndex() {
        showedGifCounter += 1
    }
    
    func restart() {
        showedGifCounter = 0 //перезапускаем счетчики
        likedGifCounter = 0
    }
    
    func returnCurrentIndex() ->Int {
        return showedGifCounter
    }
    
    func returnGifAmount() -> Int {
        return gifAmount
    }
    
    func returnLikedGifAmount() -> Int {
        return likedGifCounter
    }
}

// MARK: - GiphyFactoryDelegate

extension GiphyPresenter: GiphyFactoryDelegate {
    // Успешная загрузка гифки
    func didReceiveNextGiphy(_ giphy: GiphyModel) {
        // Преобразуем набор картинок в гифку
        let image = UIImage.gif(url: giphy.url)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideHoaler() // Останавливаем индикатор загрузки
            self?.viewController?.showGiphy(image)// Показать гифку
        }
    }

    // При загрузке гифки произошла ошибка
    func didReceiveError(_ error: GiphyError) {
        // !Обратите внимание в каком потоке это вызывается и нужно ли вызывать дополнительно!
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideHoaler()// Останавливаем индикатор загрузки
            self?.viewController?.showError()// Показать ошибку
        }
    }
}

