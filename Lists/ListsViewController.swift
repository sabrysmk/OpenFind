//
//  ListsViewController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class ListsViewController: UIViewController, Searchable {
    /// external models
    var listsViewModel: ListsViewModel
    var toolbarViewModel: ToolbarViewModel
    var realmModel: RealmModel
    var searchViewModel: SearchViewModel
    
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset = CGFloat(0)
    
    var updateNavigationBar: (() -> Void)?
    
    @IBOutlet var collectionView: UICollectionView!
    lazy var listsFlowLayout: ListsCollectionFlowLayout = createFlowLayout()
    
    /// details
    var detailsViewController: ListsDetailViewController?
    
    /// selection
    var selectBarButton: UIBarButtonItem!
    lazy var toolbarView = ListsSelectionToolbarView(model: listsViewModel)
    
    init?(
        coder: NSCoder,
        listsViewModel: ListsViewModel,
        toolbarViewModel: ToolbarViewModel,
        realmModel: RealmModel,
        searchViewModel: SearchViewModel
    ) {
        self.listsViewModel = listsViewModel
        self.toolbarViewModel = toolbarViewModel
        self.realmModel = realmModel
        self.searchViewModel = searchViewModel
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Lists"
        
        _ = listsFlowLayout
        listsUpdated()
        
        view.backgroundColor = .secondarySystemBackground
        collectionView.backgroundColor = .clear
        
        setupCollectionView()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: Global.safeAreaInsets)
        additionalSearchBarOffset = -collectionView.contentOffset.y - baseSearchBarOffset - searchViewModel.getTotalHeight()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        /// refresh for dark mode
        updateCellColors()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { context in
            self.baseSearchBarOffset = self.getCompactBarSafeAreaHeight(with: Global.safeAreaInsets)
            self.updateNavigationBar?()
        }
    }
}
