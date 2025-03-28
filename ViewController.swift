
// UI proper design are created for Apple iphone SE model only


import UIKit
import CoreLocation
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate {
    
    @IBOutlet weak var locationLabel: UILabel!
       @IBOutlet weak var temperatureLabel: UILabel!
       @IBOutlet weak var weatherIcon: UIImageView!
       @IBOutlet weak var conditionLabel: UILabel!
       @IBOutlet weak var dateLabel: UILabel!
       @IBOutlet weak var windSpeedLabel: UILabel!
       @IBOutlet weak var feelsLikeLabel: UILabel!
       @IBOutlet weak var uvIndexLabel: UILabel!
       @IBOutlet weak var pressureLabel: UILabel!
       @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var today: UILabel!
    @IBOutlet weak var myView: UIView!
    
    @IBOutlet weak var simpleView: UIView!
    @IBOutlet weak var myView1: UIView!
    
    @IBOutlet weak var myView2: UIView!
    @IBOutlet weak var myView3: UIView!
    let locationManager = CLLocationManager()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var hourlyForecastData: [HourlyWeather] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
       locationManager.delegate = self
       locationManager.requestWhenInUseAuthorization()
       locationManager.startUpdatingLocation()
        
        collectionView.delegate = self
        collectionView.dataSource = self
            
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.itemSize = CGSize(width: 55, height: 100)
                layout.minimumLineSpacing = 10
                layout.minimumInteritemSpacing = 10
            layout.scrollDirection = .horizontal
            }
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        self.today.font = UIFont.boldSystemFont(ofSize: 16.0)

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        print("Fetched Location: Latitude: \(latitude), Longitude: \(longitude)")

        locationManager.stopUpdatingLocation()
        fetchWeatherData()
        fetchWeatherDataWithforecast()

    }
    
    @IBAction func nextScreen(_ sender: Any) {
        
    }
    
    func fetchWeatherData() {
        let apiKey = "4cd569ffb3ecc3bffe9c0587ff02109f"
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        AF.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    self.parseWeatherData(json: json)
                }
            case .failure(let error):
                print("Error fetching weather: \(error.localizedDescription)")
            }
        }
    }
    
    
    func fetchWeatherDataWithforecast() {
        let apiKey = "986beefda1d241f5b8d94455252203"
        let url = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(latitude),\(longitude)&days=1&aqi=no&alerts=no"
        
        print("Fetching weather data for forecast with URL: \(url)")
        
        AF.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                print("API Response data: \(value)")
                if let json = value as? [String: Any] {
                    self.parseWeatherData(json: json)
                    self.parseHourlyData(json: json)
                    print("from 105", self.parseHourlyData(json: json) )
                }
            case .failure(let error):
                print("Error fetching forecast data: \(error.localizedDescription)")
            }
        }
    }

    
    func parseHourlyData(json: [String: Any]) {
        if let forecast = json["forecast"] as? [String: Any],
           let forecastday = forecast["forecastday"] as? [[String: Any]],
           let hours = forecastday.first?["hour"] as? [[String: Any]] {

            hourlyForecastData.removeAll()

            for hour in hours {
                let time = hour["time"] as? String ?? ""
                let temperature = hour["temp_c"] as? Double ?? 0.0
                let iconCode = (hour["condition"] as? [String: Any])?["icon"] as? String ?? ""
                
                let weather = HourlyWeather(time: time, temperature: temperature, iconCode: iconCode)
                hourlyForecastData.append(weather)
            }

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }


    
    func parseWeatherData(json: [String: Any]) {
        if let main = json["main"] as? [String: Any],
           let weatherArray = json["weather"] as? [[String: Any]],
           let wind = json["wind"] as? [String: Any],
           let sys = json["sys"] as? [String: Any],
           let name = json["name"] as? String,
           let country = sys["country"] as? String {
            
            let temperature = main["temp"] as? Double ?? 0.0
            let feelsLike = main["feels_like"] as? Double ?? 0.0
            let pressure = main["pressure"] as? Int ?? 0
            let windSpeed = wind["speed"] as? Double ?? 0.0
            let weatherCondition = weatherArray.first?["main"] as? String ?? "Clear"
            let iconCode = weatherArray.first?["icon"] as? String ?? "01d"
            
            let sunriseTimestamp = sys["sunrise"] as? Double ?? 0.0
            let sunriseDate = Date(timeIntervalSince1970: sunriseTimestamp)
            let uvIndex = main["uvi"] as? Double ?? 0.0
            let dateFormatter = DateFormatter()
                  dateFormatter.dateFormat = "EEEE, dd MMM"
                  let formattedDate = dateFormatter.string(from: Date())

            let iconURL = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
           if let url = URL(string: iconURL) {
               DispatchQueue.global().async {
                   if let data = try? Data(contentsOf: url) {
                       DispatchQueue.main.async {
                           self.weatherIcon.image = UIImage(data: data)
                       }
                   }
               }
           }

            print("Icon URL: \(iconURL)")

            let location = "\(name), \(country)"

            print("Location: \(name)")
            print("Temperature: \(Int(temperature))°C")
            print("Feels Like: \(Int(feelsLike))°C")
            print("Pressure: \(pressure) mbar")
            print("Wind Speed: \(windSpeed) km/h")
            print("Weather Condition: \(weatherCondition)")

            DispatchQueue.main.async {
                let location = "\(name), \(country)"
                let attributedString = NSMutableAttributedString(string: location)

                let cityRange = (location as NSString).range(of: name)
                attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: cityRange)
                attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: cityRange)
                
                let countryRange = (location as NSString).range(of: country)
                attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: countryRange)

                DispatchQueue.main.async {
                    self.locationLabel.attributedText = attributedString
                }
                
                self.temperatureLabel.text = "\(Int(temperature))°"
                self.feelsLikeLabel.text = "\(Int(feelsLike))°"
                self.pressureLabel.text = "\(pressure) mbar"
                self.windSpeedLabel.text = "\(windSpeed) km/h"
                self.conditionLabel.text = weatherCondition
                self.uvIndexLabel.text =  "\(Int(uvIndex))"
                self.dateLabel.text = "\(formattedDate)"
                
                
            }
        }
    }
    
}

    func downloadImage(from urlString: String, imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to download image: \(error.localizedDescription)")
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to convert data to image")
                return
            }

            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width: CGFloat = 55
            let height: CGFloat = 75
            return CGSize(width: width, height: height)
        }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyForecastData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCell", for: indexPath) as! HourlyWeatherCell
        
        let weather = hourlyForecastData[indexPath.row]
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:00"
            
            if indexPath.row == 0 {
                let roundedTime = roundToNearestHour(Date())
                let formattedTime = dateFormatter.string(from: roundedTime)
                cell.timeLabel.text = formattedTime
            } else {
                let timeComponents = Calendar.current.date(byAdding: .hour, value: indexPath.row, to: Date())
                let roundedTime = roundToNearestHour(timeComponents!)
                let formattedTime = dateFormatter.string(from: roundedTime)
                cell.timeLabel.text = formattedTime
            }
            
            if indexPath.row == 0 {
                cell.temperatureLabel.text = "Now"
            } else {
                cell.temperatureLabel.text = "\(Int(weather.temperature))°"
            }

            if indexPath.row == 0 {
                cell.backgroundColor = UIColor.systemBlue
                cell.timeLabel.textColor = UIColor.white
                cell.temperatureLabel.textColor = UIColor.white
            } else {
                cell.backgroundColor = UIColor.white
                cell.timeLabel.textColor = UIColor.gray
                cell.temperatureLabel.textColor = UIColor.gray
            }
            
               let iconURL = "https:\(weather.iconCode)"
               downloadImage(from: iconURL, imageView: cell.iconImageView)
               
               
        return cell
    }
    func formatTime(_ time: String) -> String {
        let timeComponents = time.split(separator: " ")
        
        if timeComponents.count > 1 {
            return String(timeComponents[1])
        } else {
            return time
        }
    }
    
    
    func roundToNearestHour(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        let minute = components.minute ?? 0
        let hour = components.hour ?? 0
        
        if minute >= 30 {
            return calendar.date(byAdding: .hour, value: 1, to: calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date)!)!
        } else {
            return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date)!
        }
    }


}
