//
//  GameViewController.swift
//  XO
//
//  Created by Рамиль Ибрагимов on 01.02.17.
//  Copyright © 2017 Рамиль Ибрагимов. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    // TODO
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet var gameFieldCollectionView: UICollectionView!
    
    @IBOutlet var gameFieldDataProvider: GameFieldDataProvider!
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    
    let leftMargin: CGFloat = 20
    
    var fieldSize: CGSize {
        let viewBounds = view.bounds
        let width = min(viewBounds.width, viewBounds.height) - (leftMargin * 2)
        
        return CGSize(width: width, height: width)
    }
    
    var gameEngine: GameEngine!
    
    var alreadySelectedGameCells = [IndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectGameFieldCell(sender:)), name: NSNotification.Name("SelectGameFieldCell"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(gameOver(sender:)), name: NSNotification.Name("GameOver"), object: nil)
        
        // TODO: Удалить
        //gameFieldCollectionView.frame.size = fieldSize
        
        gameEngine = GameEngine(loadCurrentGame: true)
        
        setupWinnerLabelText()
        
        gameFieldDataProvider.gameEngine = gameEngine
        
        gameFieldCollectionView.dataSource = gameFieldDataProvider
        gameFieldCollectionView.delegate = gameFieldDataProvider
        
        // TODO test
        gameFieldCollectionView.reloadData()
    }
    
    func setupWinnerLabelText() {
        if let winner = gameEngine.winner {
            switch winner {
            case Player.X:
                winnerLabel.text = "Победили крестики"
            case Player.O:
                winnerLabel.text = "Победили нолики"
            }
        } else {
            guard gameEngine.gameover == false else {
                winnerLabel.text = "Ничья"
                return
            }
            
            switch gameEngine.currentMove {
            case Player.X:
                winnerLabel.text = "Ход крестиков"
            case Player.O:
                winnerLabel.text = "Ход ноликов"
            }
        }
    }
    
    func gameOver(sender: NSNotification) {
        guard let userInfo = sender.userInfo else {
            fatalError()
        }
        
        gameEngine.winner = userInfo["winner"] as? Player
        setupWinnerLabelText()
    }
    
    func selectGameFieldCell(sender: NSNotification) {
        guard let indexPath = sender.userInfo?["indexPath"] as? IndexPath else {
            fatalError()
        }
        
        guard gameEngine != nil else {
            fatalError()
        }
        
        guard !gameEngine.gameover else {
            return
        }
        
        guard !alreadySelectedGameCells.contains(indexPath) else {
            return
        }
        
        let cell = gameFieldCollectionView.cellForItem(at: indexPath) as! GameFieldCell
        
        switch gameEngine.currentMove {
        case .X:
            let xMarkView = XMarkView(frame: cell.bounds)
            cell.addSubview(xMarkView)
        case .O:
            let oMarkView = OMarkView(frame: cell.bounds)
            cell.addSubview(oMarkView)
        }
        
        gameEngine.move(to: GameEngineMove(player: gameEngine.currentMove, x: indexPath.item, y: indexPath.section))
        
        alreadySelectedGameCells.append(indexPath)
        setupWinnerLabelText()
    }
    
    @IBAction func newGame() {
        gameEngine.removeCurrentGame()
        gameEngine = nil
        
        winnerLabel.text = ""
        gameEngine = GameEngine()
        
        gameFieldDataProvider.gameEngine = gameEngine
        
        alreadySelectedGameCells.removeAll()
        setupWinnerLabelText()
        
        gameFieldCollectionView.reloadData()
    }
}
