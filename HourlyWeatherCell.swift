

import UIKit

class HourlyWeatherCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    override func awakeFromNib() {
            super.awakeFromNib()
            
             self.layer.cornerRadius = 15
             self.layer.masksToBounds = true
             self.clipsToBounds = true
             
             self.layer.borderWidth = 1
             self.layer.borderColor = UIColor.lightGray.cgColor
             
             timeLabel.textAlignment = .center
             temperatureLabel.textAlignment = .center
             iconImageView.contentMode = .scaleAspectFit
             
             setupConstraints()
        
        
        }
    
    private func setupConstraints() {
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            temperatureLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 55),
            iconImageView.heightAnchor.constraint(equalToConstant: 55),
            
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            iconImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 2),
            temperatureLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 2),
            temperatureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)  
        ])
        
        iconImageView.contentMode = .scaleAspectFit
    }
}
