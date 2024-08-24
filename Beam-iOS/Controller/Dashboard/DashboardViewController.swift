//
//  DashboardViewController.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import UIKit
import SVProgressHUD

class DashboardViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var userName: UILabel!
    @IBOutlet private var walletAmount: UILabel!
    
    private var receivedTransactions: [Transaction] = []
    private var pendingTransactions: [Transaction] = []
    private var withdrawnTransactions: [Withdraw] = []
    private var pendingWithdraws: [Withdraw] = []
    
    private var sectionHeaders: [String] = ["Recent Transactions", "Pending Transactions", "Recent Withdrawals", "Pending Withdrawals"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureDashboard()
        self.getAllTransactions()
    }
    
    // Show the user their current available balance.
    private func configureDashboard() {
        guard let user = BeamNetworking.shared.sharedUser else { return }
        self.userName.text = "Welcome back, \(user.firstName ?? "User")"
        self.walletAmount.text = "$\(user.walletBalance)"
    }
    
    // Show the user all their current transactions (received and withdrawn)
    private func getAllTransactions() {
        if receivedTransactions.isEmpty || withdrawnTransactions.isEmpty || pendingTransactions.isEmpty {
            // If previously empty transaction array is being loaded, show a loader.
            SVProgressHUD.show()
        }
        
        sectionHeaders = ["Recent Transactions", "Pending Transactions", "Recent Withdrawals", "Pending Withdrawals"]
        
        BeamNetworking.shared.getAllTransactionsForUser { transactions in
            if let transactions = transactions {
                self.receivedTransactions = transactions.filter({ $0.transactionStatus == .paired })
                self.pendingTransactions = transactions.filter({ $0.transactionStatus == .unpaired })
            }
            
            if self.receivedTransactions.count == 0 {
                self.sectionHeaders.removeAll(where: { $0 == "Recent Transactions" })
            }
            
            if self.pendingTransactions.count == 0 {
                self.sectionHeaders.removeAll(where: { $0 == "Pending Transactions" })
            }
            
            self.refreshTable()
        }
        
        BeamNetworking.shared.getAllWithdrawsForUser { withdraws in
            if let withdraws = withdraws {
                self.withdrawnTransactions = withdraws.filter({ $0.withdrawStatus == .completed })
                self.pendingWithdraws = withdraws.filter({ $0.withdrawStatus == .pending })
            }
            
            if self.withdrawnTransactions.count == 0 {
                self.sectionHeaders.removeAll(where: { $0 == "Recent Withdrawals" })
            }
            
            if self.pendingWithdraws.count == 0 {
                self.sectionHeaders.removeAll(where: { $0 == "Pending Withdrawals" })
            }
            
            self.refreshTable()
        }
    }
    
    private func refreshTable() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
        }
    }
    
    // Allow the user to go to the Transactions page to see all on either received or withdrawn.
    @objc private func viewAllTransactions(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TransactionsViewController") as! TransactionsViewController
        let type = TransactionType(rawValue: sender.tag) ?? .transaction
        vc.transactionType = type
        
        switch type {
        case .transaction:
            vc.receivedTransactions = self.receivedTransactions
        case .withdraw:
            vc.withdrawnTransactions = self.withdrawnTransactions
        case .pendingTransaction:
            vc.pendingTransactions = self.pendingTransactions
        case .pendingWithdraw:
            vc.pendingWithdraw = self.pendingWithdraws
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func didTapOnFloatingButton(sender: UIButton) {
        let alert = UIAlertController(title: "Select Your Beam Type", message: "Tap on Receive to start the payment flow or tap on Withdraw to pull funds from your account!", preferredStyle: .actionSheet)
        let receiveAction = UIAlertAction(title: "Receive Funds", style: .default) { _ in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReceiveFundsNavController") as! UINavigationController
            if let receiveFundsVC = vc.topViewController as? SelectPlatformViewController {
                receiveFundsVC.transactionType = .transaction
            }
            self.present(vc, animated: true)
        }
        let withdrawAction = UIAlertAction(title: "Withdraw Funds", style: .default) { _ in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WithdrawFundsNavController") as! UINavigationController
            self.present(vc, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(receiveAction)
        alert.addAction(withdrawAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
}

// Show the user their most recent 3 transactions and most recent 3 withdrawls
extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        switch indexPath.section {
        case 0:
            cell.configureCellFor(transaction: receivedTransactions[indexPath.row])
        case 1:
            cell.configureCellFor(withdrawal: withdrawnTransactions[indexPath.row])
        default:
            cell.configureCellFor(pending: pendingTransactions[indexPath.row])
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return receivedTransactions.count < 3 ? receivedTransactions.count : 3
        case 1:
            return withdrawnTransactions.count < 3 ? withdrawnTransactions.count : 3
        default:
            return pendingTransactions.count < 3 ? pendingTransactions.count : 3
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TransactionDetailViewController") as! TransactionDetailViewController
            vc.transaction = receivedTransactions[indexPath.row]
            self.present(vc, animated: true)
        case 1:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WithdrawalDetailViewController") as! WithdrawalDetailViewController
            vc.transaction = withdrawnTransactions[indexPath.row]
            self.present(vc, animated: true)
        default:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TransactionDetailViewController") as! TransactionDetailViewController
            vc.pendingTransaction = pendingTransactions[indexPath.row]
            self.present(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 0, width: tableView.frame.width - 80, height: 60))
        headerLabel.text = sectionHeaders[section]
        headerLabel.textColor = .black
        headerLabel.font = .boldSystemFont(ofSize: 18.0)
        headerView.addSubview(headerLabel)
        
        let headerButton = UIButton(frame: CGRect(x: tableView.frame.width - 80, y: 0, width: 60, height: 40))
        headerButton.setTitle("See All", for: .normal)
        headerButton.setTitleColor(.black, for: .normal)
        headerButton.tag = section
        headerButton.addTarget(self, action: #selector(viewAllTransactions), for: .touchUpInside)
        headerView.addSubview(headerButton)
        return headerView
    }
}
