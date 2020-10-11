//
//  ARSelectionViewController.swift
//  ARSelectableView
//
//  Created by Rohit Makwana on 03/10/20.
//  Copyright © 2020 Rohit Makwana. All rights reserved.
//

import UIKit

let width = UIScreen.main.bounds.size.width
let height = UIScreen.main.bounds.size.height

class ARSelectionViewController: UIViewController {

    //MARK: - IBOutlets

    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var selectionTypeSegment: UISegmentedControl!
    @IBOutlet weak var alignmentSegment: UISegmentedControl!
    @IBOutlet weak var directionSegment: UISegmentedControl!

    //MARK: - Declared Variables

    let musics = ["Blues Music", "Jazz Music", "Rock and Roll Music", "Soul Music",
                 "Dance Music", "Hip Hop Music", "Rhythm and Blues Music", "Country Music",
                 "Rock Music", "Blues Music", "Jazz Music", "Rhythm and Blues Music",
                 "Rock and Roll Music", "Soul Music", "Rock Music", "Country Music",
                 "Blues Music", "Jazz Music", "Rhythm and Blues Music", "Rock Music",
                 "Rock and Roll Music", "Rock Music", "Country Music", "Soul Music",
                 "Dance Music", "Hip Hop Music", "Dance Music","Hip Hop Music"]

    fileprivate var selectionView: ARSelectionView?
    var alignment: ARSelectionAlignment = ARSelectionAlignment.left {
        willSet {
            if newValue != self.alignment {
                DispatchQueue.main.async {
                    self.selectionView?.alignment = newValue
                }
            }
        }
    }

    var currentSelectionType: ARSelectionType? {
        willSet {
            if newValue != self.currentSelectionType {
                self.navigationItem.leftBarButtonItem?.isEnabled = newValue != .tags
                DispatchQueue.main.async {
                    if newValue == ARSelectionType.tags {
                        var designOption = ARCellDesignOptions()
                        designOption.defaultCellBGColor = UIColor.lightGray.withAlphaComponent(0.3)
                        designOption.selectedTitleColor = .white
                        designOption.selectedCellBGColor = .black
                        designOption.selectedButtonColor = .white
                        designOption.rowHeight = 40
                        designOption.cornerRadius = 5
                        self.selectionView?.cellDesignOptions = designOption
                        self.selectionView?.options = ARCollectionLayoutOptions(sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),lineSpacing: 10, interitemSpacing: 10, scrollDirection: .vertical)
                    }
                    else {
                        self.selectionView?.items.forEach {$0.isSelected = false}
                        self.selectionView?.cellDesignOptions = ARCellDesignOptions()
                        self.selectionView?.options = ARCollectionLayoutOptions(scrollDirection: self.scrollDirection == .vertical ? .vertical: .horizontal)
                    }
                    self.selectionView?.selectionType = newValue
                }
            }
        }
    }

    var scrollDirection = UICollectionView.ScrollDirection.vertical {
        willSet {
            if newValue != self.scrollDirection {
                DispatchQueue.main.async {
                    if self.currentSelectionType == .tags {
                        self.selectionView?.options = ARCollectionLayoutOptions(sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),lineSpacing: 10, interitemSpacing: 10, scrollDirection: .vertical)
                    }
                    else {
                        self.selectionView?.options = ARCollectionLayoutOptions(scrollDirection: newValue)
                    }
                }
            }
        }
    }

    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
        self.title = "Selection"

        self.addSelectionView()
        self.currentSelectionType = .radio
        self.setDummyData()
    }

    //MARK: - Design Layout
    fileprivate func addSelectionView() {

        self.selectionView?.removeFromSuperview()
        self.selectionView = ARSelectionView(frame: CGRect.zero)
        self.view.addSubview(self.selectionView!)

        self.selectionView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.selectionView!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.selectionView!.leftAnchor.constraint(equalTo: view.leftAnchor),
            self.selectionView!.rightAnchor.constraint(equalTo: view.rightAnchor),
            self.buttonsView!.topAnchor.constraint(equalTo: self.selectionView!.bottomAnchor),
        ])
        self.view.layoutIfNeeded()
    }

    //MARK: - Dummy Data
    func setDummyData() {

        var items = [ARSelectModel]()
        for music in musics {
            items.append(ARSelectModel(title: music))
        }

        let chunkeditems = items.chunked(into: Int((self.selectionView?.frame.height)! / (self.selectionView?.cellDesignOptions.rowHeight)!))
        for insa in chunkeditems {
            let maxHeight = (insa.map { $0.width }.max() ?? width/2) + ARSelectableCell.extraSpace
            insa.forEach {$0.width = maxHeight }
        }

        DispatchQueue.main.async {
            self.selectionView?.items = items
        }
    }

    //MARK: - Show Selection Alert
    private func showSelectionAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: "This selection type not supported horizontal scroll direction", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - Segment IBAction
extension ARSelectionViewController {

    @IBAction func selectionTypeValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 2 {
            if self.directionSegment.selectedSegmentIndex == 1 {
                self.showSelectionAlert()
                sender.selectedSegmentIndex =  self.currentSelectionType?.rawValue ?? 0
            }
            else {
                self.currentSelectionType = .tags
            }
        }
        else {
            self.currentSelectionType = sender.selectedSegmentIndex == 0 ? .radio : .checkbox
        }
    }

    @IBAction func alignmentValueChanged(_ sender: UISegmentedControl) {
        self.alignment = sender.selectedSegmentIndex == 0 ? .left : .right
    }

    @IBAction func directionValueChanged(_ sender: UISegmentedControl) {
        if self.selectionTypeSegment.selectedSegmentIndex == 2 {
            self.directionSegment.selectedSegmentIndex = 0
            self.showSelectionAlert()
        }
        else {
            self.scrollDirection = sender.selectedSegmentIndex == 0 ? .vertical : .horizontal
        }
    }
}
