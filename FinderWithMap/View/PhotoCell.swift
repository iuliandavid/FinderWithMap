//
//  PhotoCell.swift
//  FinderWithMap
//
//  Created by iulian david on 8/19/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    var model: MyModel? {
        didSet {
            updateCell()
        }
    }
    
    var mapVC: MapVC?
    
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTapped)))
        return imageView
    }()
    
    let nameLabel : UILabel = {
        let textView = UILabel()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .blue
        textView.backgroundColor = .clear
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(photoImageView)
        self.addSubview(nameLabel)
        
        // need x, y, width and height constraints
        photoImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        photoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30).isActive = true
        photoImageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        photoImageView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -30).isActive = true
        
        // need x, y, width and height constraints
        nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        nameLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateCell() {
        guard let name = model?.name, let photoId = model?.photoId  else {
            return
        }
        self.nameLabel.text = name
        let image =  UIImage(named: "\(photoId)")
        self.photoImageView.image = image
        
    }
    
    @objc private func handleImageTapped() {
        print("image tapped")
        guard let photoId = model?.photoId else { return }
        mapVC?.photoSelected(with: photoId)
    }
}
