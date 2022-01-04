//
//  ViewController.swift
//  WeatherApp
//
//  Created by HyeonSoo Kim on 2022/01/04.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var weatherStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func tapFetchWeatherButton(_ sender: UIButton) {
        guard let cityName = self.cityNameTextField.text else { return }
        self.getCurrentWether(cityName: cityName)
        self.view.endEditing(true)
    }
    
    func configureView(weatherInformation: WeatherInformation) {
        self.cityNameLabel.text = weatherInformation.name
        if let weather = weatherInformation.weather.first {
            self.weatherDescriptionLabel.text = weather.description
        }
        self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.25))°C"
        self.minTempLabel.text = "최저: \(Int(weatherInformation.temp.minTemp - 273.25))°C"
        self.maxTempLabel.text = "최고: \(Int(weatherInformation.temp.maxTemp - 273.25))°C"
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getCurrentWether(cityName: String) {
        //Optional 타입으로 반환되기에 가드문으로 binding
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=a457fa32b6446acec5aec7534bab49bc") else { return }
        //Session Configuraion을 결정하고 Session을 생성(여기선 기본세션으로 결정함.)
        let session = URLSession(configuration: .default)
        //URLSession에서 사용할 Task결정 후 API를 호출할 해당 url넘기고, completion handler 정의.
        //data <- 서버에서 응답받은 데이터가 전달
        //response <- http헤더 및 상태코드와 같은 응답메타데이터가 전달
        //error <- 요청실패 시 에러객체 전달되고, 성공 시 nil을 반환
        session.dataTask(with: url) { [weak self] data, response, error in
            let successRange = (200..<300)
            //data가 Optional 타입이라 binding(요청 성공했을 시에만 가드문 통과)
            guard let data = data, error == nil else { return }
            //JSONDecoder() - json객체에서 데이터유형의 인스턴스로 디코딩하는 객체.
            let decoder = JSONDecoder() //클래스 인스턴스 생성
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return }
                DispatchQueue.main.async {
                    self?.weatherStackView.isHidden = false
                    self?.configureView(weatherInformation: weatherInformation)
                }
            } else {
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                DispatchQueue.main.async {
                    self?.showAlert(message: errorMessage.message)
                }
            }
        }.resume() //새로 초기화된 Task는 일시중단상태이기에 resume()메서드로 활성화
    }
    
}

