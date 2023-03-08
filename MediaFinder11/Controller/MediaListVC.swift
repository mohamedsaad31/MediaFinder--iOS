//
//  MediaListVC.swift
//  MediaFinder11
//
//  Created by mohamed saad on 29/12/2022.
//

import UIKit
import Alamofire
import AlamofireImage
import AVKit
class MediaListVC: UIViewController, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.tableView.reloadData()
    }
    enum MediaType: String {
        case music
        case movie
        case tvShow
        
        var searchParam: String {
            switch self {
            case .music:
                return "music"
            case .movie:
                return "movie"
            case .tvShow:
                return "tvShow"
            }
        }
    }
    //MARK: - Outlets.
    @IBOutlet weak var mediaTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    //MARK: - Propreties.
    var mediaList: [Media] = []
    var selectedMediaType: MediaType = .music
    var searchQuery: String?
    let imageView = UIImageView(image: UIImage(named: "search-icon"))
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    //MARK: - Life Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Media List"
        UserDefaults.standard.set(true, forKey: "isSignedIn")
        UserDefaults.standard.set(true, forKey: "isSignedUp")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        // Add constraints to position the image view in the center of the screen
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        tableView.register(UINib(nibName: "MoviesCell", bundle: nil), forCellReuseIdentifier: "MoviesCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100 // set an initial estimated height
        
        
        //activity indicator to the view and center it
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
        setUpProfileButton()
    }
    //MARK: - Actions.
    @objc private func addTapped(){
        goToProfile()
    }
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if searchBar.text?.isEmpty == true {
            let alert = UIAlertController(title: "Sorry", message: "Please search for a word first", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            // Reset segmented control to previous selection
            switch selectedMediaType {
            case .music:
                sender.selectedSegmentIndex = 0
            case .movie:
                sender.selectedSegmentIndex = 1
            case .tvShow:
                sender.selectedSegmentIndex = 2
            }
            return
        }
        switch sender.selectedSegmentIndex {
        case 0:
            selectedMediaType = .music
        case 1:
            selectedMediaType = .movie
        case 2:
            selectedMediaType = .tvShow
        default:
            break
        }
        fetchData()
    }
    @objc func animateImage(sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        UIView.animate(withDuration: 0.1, animations: {
            imageView.transform = CGAffineTransform(translationX: -13, y: 0)
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                imageView.transform = CGAffineTransform.identity
            })
        }
    }
    @objc func playPreview(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: buttonPosition) else { return }
        let media = mediaList[indexPath.row]
        guard let previewUrlString = media.previewUrl, let previewUrl = URL(string: previewUrlString) else { return }
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: previewUrl)
        present(playerVC, animated: true) {
            playerVC.player?.play()
        }
    }
    private func goToProfile(){
        let profileVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
//MARK: - Table View Data Source Methods
extension MediaListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mediaList.isEmpty {
            activityIndicator.stopAnimating()
            imageView.isHidden = false
        } else {
            imageView.isHidden = true
        }
        return mediaList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoviesCell", for: indexPath) as! MoviesCell
        let media = mediaList[indexPath.row]
        switch selectedMediaType {
        case .music:
            cell.titleLabel.text = media.trackName
            cell.descriptionLabel.text = media.artistName ?? ""
        case .movie:
            cell.titleLabel.text = media.trackName
            cell.descriptionLabel.text = media.longDescription ?? ""
        case .tvShow:
            cell.titleLabel.text = media.artistName ?? ""
            cell.descriptionLabel.text = media.longDescription ?? ""
        }
        cell.thumbnailImageView.af.setImage(withURL: URL(string: media.artworkUrl100 ?? "")!, placeholderImage: UIImage(named: "placeholderImage"))
        cell.playButton.isHidden = !(media.kind == "song" || media.kind == "feature-movie" || media.kind == "tv-episode")
        cell.playButton.addTarget(self, action: #selector(playPreview(sender:)), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(animateImage(sender:)))
        cell.thumbnailImageView.addGestureRecognizer(tapGesture)
        cell.thumbnailImageView.isUserInteractionEnabled = true
        //Make the descriptionLabel resizable
        cell.descriptionLabel.numberOfLines = 0
        cell.descriptionLabel.lineBreakMode = .byWordWrapping
        cell.descriptionLabel.sizeToFit()
        
        activityIndicator.stopAnimating()
        
        return cell
    }
    //Make the cell resizable
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let media = mediaList[indexPath.row]
        let cellWidth = tableView.bounds.width
        let titleLabelHeight = heightForLabel(text: media.trackName ?? "", font: UIFont.systemFont(ofSize: 18), width: cellWidth)
        let descriptionLabelHeight = heightForLabel(text: media.longDescription ?? "", font: UIFont.systemFont(ofSize: 16), width: cellWidth)
        let thumbnailHeight = cellWidth / 3 * 4
        let padding: CGFloat = 16 + 8 + 8 + 16 + 10 + 10
        let playButtonHeight: CGFloat = media.kind == "song" || media.kind == "feature-movie" || media.kind == "tv-episode" ? 50 : 0
        return titleLabelHeight + descriptionLabelHeight + thumbnailHeight + padding + playButtonHeight
    }
    //Helper function to calculate label height
    func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
}
//MARK: - API Manager
extension MediaListVC {
    func fetchMediaData(searchText: String) {
        APIManger.fetchData(for: selectedMediaType.rawValue, searchTerm: searchText) { [weak self] (result) in
            switch result {
            case .success(let media):
                self?.mediaList = media
                self?.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
//MARK: - Search Bar Delegate Methods
extension MediaListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchData), object: nil)
        if searchText.count >= 3 {
            perform(#selector(fetchData), with: nil, afterDelay: 0.5)
        }
    }
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        mediaList = []
        tableView.reloadData()
    }
    func setUpProfileButton(){
        let button = UIButton(type: .custom)
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
        let attributedTitle = NSAttributedString(string: "Profile", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setTitleColor(.orange, for: .normal)
        button.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem?.tintColor = .orange
        
        
    }
    @objc func fetchData() {
        activityIndicator.startAnimating()
        imageView.isHidden = true
        guard let searchText = searchBar.text else { return }
        fetchMediaData(searchText: searchText)
    }
    @objc func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text else { return }
        if query.count < 3 {
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter at least 3 characters.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            searchQuery = query
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchData), object: nil)
            perform(#selector(fetchData), with: nil, afterDelay: 0.5)
        }
    }
}
