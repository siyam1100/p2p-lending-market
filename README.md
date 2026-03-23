# P2P Lending Market

A professional-grade, flat-structured lending primitive. Unlike pooled liquidity protocols (Aave/Compound), this repository facilitates direct Peer-to-Peer lending where borrowers and lenders agree on specific terms.

## Core Features
* **Collateral Management:** Securely locks ETH as collateral for ERC-20 loans (e.g., USDC).
* **Liquidation Engine:** Allows third-party liquidators to seize collateral if the value falls below the Health Factor.
* **Fixed Terms:** Predetermined interest rates and repayment deadlines.
* **Security:** Implements `ReentrancyGuard` and standard OpenZeppelin access controls.

## Workflow
1. **Lender:** Deposits tokens into a `LoanOffer`.
2. **Borrower:** Accepts the offer by locking the required ETH collateral.
3. **Repayment:** Borrower returns the principal + interest before the deadline.
4. **Liquidation:** If the deadline passes or collateral value drops, the lender or liquidator claims the ETH.

## Setup
1. `npm install`
2. Configure your Oracle address for collateral pricing in `LendingMarket.sol`.
