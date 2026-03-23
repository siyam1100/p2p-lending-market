// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract LendingMarket is ReentrancyGuard {
    struct Loan {
        address lender;
        address borrower;
        uint256 amount;
        uint256 collateral;
        uint256 dueDate;
        bool active;
        bool repaid;
    }

    IERC20 public immutable loanToken;
    uint256 public constant COLLATERAL_RATIO = 150; // 150% over-collateralized
    mapping(uint256 => Loan) public loans;
    uint256 public nextLoanId;

    event LoanInitiated(uint256 indexed id, address lender, uint256 amount, uint256 collateral);
    event LoanRepaid(uint256 indexed id);
    event Liquidated(uint256 indexed id);

    constructor(address _token) {
        loanToken = IERC20(_token);
    }

    function requestLoan(address _lender, uint256 _amount, uint256 _duration) external payable {
        uint256 requiredCollateral = (_amount * COLLATERAL_RATIO) / 100;
        require(msg.value >= requiredCollateral, "Insufficient collateral");

        uint256 loanId = nextLoanId++;
        loans[loanId] = Loan({
            lender: _lender,
            borrower: msg.sender,
            amount: _amount,
            collateral: msg.value,
            dueDate: block.timestamp + _duration,
            active: true,
            repaid: false
        });

        require(loanToken.transferFrom(_lender, msg.sender, _amount), "Transfer failed");
        emit LoanInitiated(loanId, _lender, _amount, msg.value);
    }

    function repayLoan(uint256 _id) external nonReentrant {
        Loan storage loan = loans[_id];
        require(loan.active, "Loan not active");
        require(msg.sender == loan.borrower, "Not borrower");

        loan.active = false;
        loan.repaid = true;

        require(loanToken.transferFrom(msg.sender, loan.lender, loan.amount), "Repayment failed");
        payable(msg.sender).transfer(loan.collateral);

        emit LoanRepaid(_id);
    }

    function liquidate(uint256 _id) external {
        Loan storage loan = loans[_id];
        require(loan.active, "Loan not active");
        require(block.timestamp > loan.dueDate, "Loan not expired");

        loan.active = false;
        payable(loan.lender).transfer(loan.collateral);

        emit Liquidated(_id);
    }
}
