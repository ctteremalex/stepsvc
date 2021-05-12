//
//  CCGridSectionView.swift
//  stepsapp
//
//  Created by Herman on 5/12/21.
//

import UIKit

public enum CCGridSectionViewStyle {
    case standart
    case special
}

public class CCGridSectionView: UIView {
    
    let innerViewCornerRadius: CGFloat = 10
    let innerViewInset: CGFloat = 26
    let headerTextInset: CGFloat = 16
    let headerViewHeight: CGFloat = 40
    let shadowRadius: CGFloat = 15
    
    lazy var innerView: UIView = {
        let innerView = UIView()
        innerView.layer.cornerRadius = innerViewCornerRadius
        innerView.clipsToBounds = true
        innerView.addSubview(headerView)
        innerView.addSubview(contentView)
        return innerView
    }()
    
    lazy var headerView: UIView = {
        let header = UIView()
        header.addSubview(headerLabel)
        return header
    }()
    
    lazy var headerLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.font = .boldSystemFont(ofSize: 15)
        headerLabel.textColor = .white
        return headerLabel
    }()
    
    lazy var contentView : UIView = {
        let contentView = UIView()
        return contentView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(innerView)
        createConstraints()
        createShadow()
    }
    
    public convenience init(style: CCGridSectionViewStyle,
                            title: String = "",
                            headerColor: UIColor = .black,
                            contentColor: UIColor = .white) {
        self.init(frame: .zero)
        // TODO: разобраться с поведением плиток у которых нет заголовка
        guard style == .standart else { return }
        headerLabel.text = title
        headerView.backgroundColor = headerColor
        contentView.backgroundColor = contentColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createShadow() {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = shadowRadius
    }
    
    private func createConstraints() {
        innerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(innerViewInset)
        }
        headerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(headerViewHeight)
        }
        headerLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(headerTextInset)
            make.centerY.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
}
