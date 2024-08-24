//
//  TransactionsViewController.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import UIKit

class TransactionsViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!

    var transactionType: TransactionType = .transaction
    
    var receivedTransactions: [Transaction] = []
    var pendingTransactions: [Transaction] = []
    var withdrawnTransactions: [Withdraw] = []
    var pendingWithdraw: [Withdraw] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
}

extension TransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        switch transactionType {
        case .transaction:
            cell.configureCellFor(transaction: receivedTransactions[indexPath.row])
        case .withdraw:
            cell.configureCellFor(withdrawal: withdrawnTransactions[indexPath.row])
        case .pendingTransaction:
            cell.configureCellFor(pending: pendingTransactions[indexPath.row])
        case .pendingWithdraw:
            cell.configureCellFor(withdrawal: pendingWithdraw[indexPath.row])
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch transactionType {
        case .transaction:
            return receivedTransactions.count
        case .pendingTransaction:
            return pendingTransactions.count
        case .withdraw:
            return withdrawnTransactions.count
        case .pendingWithdraw:
            return pendingWithdraw.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch transactionType {
        case .transaction:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TransactionDetailViewController") as! TransactionDetailViewController
            vc.transaction = receivedTransactions[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        case .withdraw:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WithdrawalDetailViewController") as! WithdrawalDetailViewController
            vc.transaction = withdrawnTransactions[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        case .pendingTransaction:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TransactionDetailViewController") as! TransactionDetailViewController
            vc.pendingTransaction = pendingTransactions[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        case .pendingWithdraw:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WithdrawalDetailViewController") as! WithdrawalDetailViewController
            vc.transaction = pendingWithdraw[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
