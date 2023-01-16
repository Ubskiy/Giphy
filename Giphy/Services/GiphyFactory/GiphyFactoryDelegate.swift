// Делегат по которому будет возвращаться гифка
protocol GiphyFactoryDelegate: AnyObject {
    // Успешное получение гифки, необходимо отобразить гифку
    func didReceiveNextGiphy(_ giphy: GiphyModel)

    // Ошибка при загрузке гифки
    func didReceiveError(_ error: GiphyError)
}
