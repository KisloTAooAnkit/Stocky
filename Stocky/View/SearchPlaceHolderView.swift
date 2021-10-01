//
//  SearchPlaceHolderView.swift
//  Stocky
//
//  Created by Ankit Singh on 01/10/21.
//

import UIKit

class SearchPlaceHolderView : UIView {
    private let imageView : UIImageView = {
        let image = UIImage(named: "imDca")
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLable : UILabel = {
        let lable = UILabel()
        lable.text = "Search for companies to calculate potential returns via dollar cost averaging"
        lable.font = UIFont(name: "AvenirNext-Medium", size: 14)
        lable.numberOfLines = 0
        lable.textAlignment = .center
        return lable
    }()
    
    
    private lazy var stackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView,titleLable])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    private func setupViews() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
        
            stackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.8),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 88)
        
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
