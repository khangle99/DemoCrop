//
//  SelectFontViewController.swift
//  TestIsolate
//
//  Created by Khang L on 07/10/2022.
//

import UIKit

protocol SelectFontViewControllerDelegate: AnyObject {
    func didSelect(_ font: UIFont)
}

class SelectFontViewController: UIViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    weak var delegate: SelectFontViewControllerDelegate?
    
    
    @IBOutlet weak var fontTableview: UITableView!
    
    private var originalFonts: [(fontName: String, font: UIFont)] = {
        var fontList: [(String, UIFont)] = []
        UIFont.familyNames.forEach { famName in
            
            UIFont.fontNames(forFamilyName: famName).forEach { fontName in
                if let font = UIFont(name: fontName, size: 12) {
                    fontList.append((fontName, font))
                }
            }
        }
        return fontList
    }()
    
    private var filteredFonts: [(fontName: String, font: UIFont)]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredFonts = originalFonts
        fontTableview.delegate = self
        fontTableview.dataSource = self
        searchBar.delegate = self
        
    }
    
}

extension SelectFontViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredFonts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

            if( !(cell != nil))
            {
                cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }

        cell!.textLabel?.text = filteredFonts[indexPath.row].fontName
        cell!.textLabel?.font = filteredFonts[indexPath.row].font
            return cell!
        }
    
}

extension SelectFontViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredFonts = originalFonts
        } else {
            filteredFonts = originalFonts.filter({ fontName, font in
                fontName.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            })
        }
        
        fontTableview.reloadData()
    }
}

extension SelectFontViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(filteredFonts[indexPath.row].font)
        dismiss(animated: true)
    }
}

