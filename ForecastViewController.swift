
import UIKit
import Alamofire
import CoreLocation

class ForecastViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationLabel: UILabel!
    
    var latitude: Double = 0.0
      var longitude: Double = 0.0
      var currentLocation: String = ""
      
      let locationManager = CLLocationManager()
      var forecastData: [Forecast] = []


      override func viewDidLoad() {
          super.viewDidLoad()
          
          setupLocationManager()
          tableView.showsVerticalScrollIndicator = false
          tableView.showsHorizontalScrollIndicator = false
          navigationController?.navigationBar.tintColor = UIColor.white
          tableView.delegate = self
          tableView.dataSource = self
          fetch7DayForecastData()
//          locationLabel.text = currentLocation
          fetchCityName()
          
          print("from 367 -- > ", locationLabel.text )
      }
    
      
      func setupLocationManager() {
          locationManager.delegate = self
          locationManager.requestWhenInUseAuthorization()
          locationManager.startUpdatingLocation()
      }
      
      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          guard let location = locations.last else { return }
          
          latitude = location.coordinate.latitude
          longitude = location.coordinate.longitude
          
          print("Fetched Location: Latitude: \(latitude), Longitude: \(longitude)")
          
          locationManager.stopUpdatingLocation()
          
          fetch7DayForecastData()
          fetchCityName()
      }
      
      func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
          print("Failed to get location: \(error.localizedDescription)")
      }
    
    
    func fetchCityName() {
            let apiKey = "4cd569ffb3ecc3bffe9c0587ff02109f"
            let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"

            print("Fetching city name from: ---- > \(url)")

        AF.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    self.parseWeatherData123(json: json)
                }
            case .failure(let error):
                print("Error fetching weather: \(error.localizedDescription)")
            }
        }
    }
    
    
    func parseWeatherData123(json: [String: Any]) {
        
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
        


            let location = "\(name), \(country)"
            print("Location: --- >  \(name)")
            print("Temperature: \(Int(temperature))°C")
            print("Feels Like: \(Int(feelsLike))°C")
            print("Pressure: \(pressure) mbar")
            print("Wind Speed: \(windSpeed) km/h")
            print("Weather Condition: \(weatherCondition)")

            DispatchQueue.main.async {
                
                let location = "\(name), \(country)"
                let attributedString = NSMutableAttributedString(string: location)

                let cityRange = (location as NSString).range(of: name)
                attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: cityRange)
                attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: cityRange)

                let countryRange = (location as NSString).range(of: country)
                attributedString.addAttribute(.foregroundColor, value: UIColor.systemGray5, range: countryRange)

                DispatchQueue.main.async {
                    self.locationLabel.attributedText = attributedString
                }
                                
            }
        }
    }
    
      
      func fetch7DayForecastData() {
          guard latitude != 0.0, longitude != 0.0 else {
              print("Error: Latitude and Longitude are not set properly.")
              return
          }
          
          let apiKey = "986beefda1d241f5b8d94455252203"
          let url = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(latitude),\(longitude)&days=7&aqi=no&alerts=no"
          
          print("Fetching data from URL: \(url)")
          
          AF.request(url).responseJSON { response in
              switch response.result {
              case .success(let value):
                  print("API Response: \(value)")
                  if let json = value as? [String: Any] {
                      self.parse7DayForecastData(json: json)
                  }
              case .failure(let error):
                  print("Error fetching forecast data: \(error.localizedDescription)")
              }
          }
      }
      
  
    func parse7DayForecastData(json: [String: Any]) {
        if let forecast = json["forecast"] as? [String: Any],
           let forecastday = forecast["forecastday"] as? [[String: Any]] {
            
            forecastData.removeAll()
            
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "EEEE, dd MMM"
            outputFormatter.locale = Locale(identifier: "en_US")
                        
            for day in forecastday {
                if let dateString = day["date"] as? String,
                   let date = inputFormatter.date(from: dateString),
                   let dayData = day["day"] as? [String: Any] {
                    
                    let formattedDate = outputFormatter.string(from: date)
                    let maxTemp = dayData["maxtemp_c"] as? Double ?? 0.0
                    let minTemp = dayData["mintemp_c"] as? Double ?? 0.0
                    let weatherCondition = dayData["condition"] as? [String: Any]
                    let iconCode = weatherCondition?["icon"] as? String ?? ""

                    let temperature = (maxTemp + minTemp) / 2
                    let forecast = Forecast(date: formattedDate, temperature: temperature, maxTemp: maxTemp, minTemp: minTemp, iconCode: iconCode)

                    forecastData.append(forecast)
                }
            }

            print("Final Forecast Data: \(forecastData)")

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          print("Number of rows: \(forecastData.count)")
          return forecastData.count
      }

      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastCell
          
          let forecast = forecastData[indexPath.row]
          
          
          let dateParts = forecast.date.split(separator: ",")
             
             if dateParts.count == 2 {
                 let dayOfWeek = String(dateParts[0])
                 let formattedDate = String(dateParts[1]).trimmingCharacters(in: .whitespaces)
                 
                 print("Day of Week: \(dayOfWeek), Date: \(formattedDate)")
                 
                 let attributedString = NSMutableAttributedString(string: "\(dayOfWeek), \(formattedDate)")
                 
                 let dayRange = (attributedString.string as NSString).range(of: dayOfWeek)
                 attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: dayRange)
                 
                 let dateRange = (attributedString.string as NSString).range(of: formattedDate)
                 attributedString.addAttribute(.foregroundColor, value: UIColor.systemGray3, range: dateRange)
                 
                 cell.dateLabel.attributedText = attributedString
             } else {
                 print("Unexpected date format: \(forecast.date)")
             }
             
          
          let maxTempText = "\(Int(forecast.maxTemp))°"
          let minTempText = "\(Int(forecast.minTemp))°"
          
          let temperatureString = NSMutableAttributedString(string: "\(maxTempText) / \(minTempText)")
          
          let maxTempRange = (temperatureString.string as NSString).range(of: maxTempText)
          temperatureString.addAttribute(.foregroundColor, value: UIColor.white, range: maxTempRange)
          
          let minTempRange = (temperatureString.string as NSString).range(of: minTempText)
          temperatureString.addAttribute(.foregroundColor, value: UIColor.systemGray3, range: minTempRange)
          
          cell.temperatureLabel.attributedText = temperatureString

          
          let iconURL = "https:\(forecast.iconCode)"
          downloadImage(from: iconURL, imageView: cell.iconImageView)
          
          if forecast.iconCode.isEmpty {
              cell.iconImageView.image = UIImage(named: "defaultIcon")
          } else {
              let iconURL = "https://cdn.weatherapi.com/weather/64x64/day/\(forecast.iconCode).png"
              downloadImage(from: iconURL, imageView: cell.iconImageView)
          }

          
          return cell
      }

    
    func downloadImage(from urlString: String, imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }

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
  }
