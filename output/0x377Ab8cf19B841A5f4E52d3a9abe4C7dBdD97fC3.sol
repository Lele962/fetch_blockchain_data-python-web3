/*************************
    Hold and shill.
    No twitter, no TG. 
    Community based token.
    Initial goal $1
************************/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface IUSDCReceiver {
    function initialize(address) external;

    function withdraw() external;

    function withdrawUnsupportedAsset(address, uint256) external;
}

contract USDCReceiver is IUSDCReceiver, Ownable {
    address public usdc;
    address public token;

    constructor() Ownable() {
        token = msg.sender;
    }

    function initialize(address _usdc) public onlyOwner {
        require(usdc == address(0x0), "Already initialized");
        usdc = _usdc;
    }

    function withdraw() public {
        require(msg.sender == token, "Caller is not token");
        IERC20(usdc).transfer(token, IERC20(usdc).balanceOf(address(this)));
    }

    function withdrawUnsupportedAsset(address _token, uint256 _amount)
        public
        onlyOwner
    {
        if (_token == address(0x0)) payable(owner()).transfer(_amount);
        else IERC20(_token).transfer(owner(), _amount);
    }
}

contract PennyStonk is Context, IERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 private _uniswapV2Router02;

    USDCReceiver private _usdcReceiver;

    mapping(address => uint256) private _antiMEV;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _excludedFromFees;
    mapping(address => bool) private _excludedMaxTransactionAmount;

    bool public tradingOpen;
    bool private _swapping;
    bool public swapEnabled;
    bool public antiMEVEnabled;

    string private constant _name = "Penny Stonk";
    string private constant _symbol = "PENNY";

    uint8 private constant _decimals = 9;

    uint256 private constant _totalSupply = 100_000 * (10**_decimals);

    uint256 public buyLimit = _totalSupply.mul(2).div(100);
    uint256 public sellLimit = _totalSupply.mul(2).div(100);
    uint256 public walletLimit = _totalSupply.mul(2).div(100);

    uint256 public fee = 50; // 5%
    uint256 private _previousFee = fee;

    uint256 private _tokensForFee;
    uint256 private _swapTokensAtAmount = _totalSupply.mul(5).div(10000);

    address payable private _feeCollector;
    address private _uniswapV2Pair;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    modifier lockTheSwap() {
        _swapping = true;
        _;
        _swapping = false;
    }

    constructor() {
        _uniswapV2Router02 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(_uniswapV2Router02), _totalSupply);
        IERC20(USDC).approve(
            address(_uniswapV2Router02),
            IERC20(USDC).balanceOf(address(this))
        );
        _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router02.factory())
            .createPair(address(this), USDC);
        IERC20(_uniswapV2Pair).approve(
            address(_uniswapV2Router02),
            type(uint256).max
        );

        _usdcReceiver = new USDCReceiver();
        _usdcReceiver.initialize(USDC);
        _usdcReceiver.transferOwnership(msg.sender);

        _feeCollector = payable(_msgSender());
        _balances[address(this)] = _totalSupply;

        _excludedFromFees[owner()] = true;
        _excludedFromFees[address(this)] = true;
        _excludedFromFees[address(_usdcReceiver)] = true;
        _excludedFromFees[address(0xdead)] = true;

        _excludedMaxTransactionAmount[owner()] = true;
        _excludedMaxTransactionAmount[address(this)] = true;
        _excludedMaxTransactionAmount[address(_usdcReceiver)] = true;
        _excludedMaxTransactionAmount[address(0xdead)] = true;

        emit Transfer(address(0), address(this), _totalSupply);
    }

    receive() external payable {}

    fallback() external payable {}

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "PENNY: decreased allowance below address(0)"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(
            from != address(0),
            "PENNY: transfer from the address(0) address"
        );
        require(to != address(0), "PENNY: transfer to the address(0) address");
        require(
            amount > 0,
            "PENNY: Transfer amount must be greater than address(0)"
        );

        bool takeFee = true;
        bool shouldSwap = false;
        if (
            from != owner() &&
            to != owner() &&
            to != address(0) &&
            to != address(0xdead) &&
            !_swapping
        ) {
            if (!tradingOpen)
                require(
                    _excludedFromFees[from] || _excludedFromFees[to],
                    "PENNY: Trading is not allowed yet."
                );

            if (antiMEVEnabled) {
                if (
                    to != address(_uniswapV2Router02) &&
                    to != address(_uniswapV2Pair)
                ) {
                    require(
                        _antiMEV[tx.origin] < block.number - 1 &&
                            _antiMEV[to] < block.number - 1,
                        "PENNY: Transfer delay enabled. Try again later."
                    );
                    _antiMEV[tx.origin] = block.number;
                    _antiMEV[to] = block.number;
                }
            }

            if (
                from == _uniswapV2Pair &&
                to != address(_uniswapV2Router02) &&
                !_excludedMaxTransactionAmount[to]
            ) {
                require(
                    amount <= buyLimit,
                    "PENNY: Transfer amount exceeds the buyLimit."
                );
                require(
                    balanceOf(to) + amount <= walletLimit,
                    "PENNY: Exceeds maximum wallet token amount."
                );
            }

            if (
                to == _uniswapV2Pair &&
                from != address(_uniswapV2Router02) &&
                !_excludedMaxTransactionAmount[from]
            ) {
                require(
                    amount <= sellLimit,
                    "PENNY: Transfer amount exceeds the sellLimit."
                );

                shouldSwap = true;
            }
        }

        if (_excludedFromFees[from] || _excludedFromFees[to]) takeFee = false;

        uint256 contractBalance = balanceOf(address(this));
        bool canSwap = (contractBalance > _swapTokensAtAmount) && shouldSwap;

        if (
            canSwap &&
            swapEnabled &&
            !_swapping &&
            !_excludedFromFees[from] &&
            !_excludedFromFees[to]
        ) {
            _swapBack(contractBalance);
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(
            owner != address(0),
            "PENNY: approve from the address(0) address"
        );
        require(
            spender != address(0),
            "PENNY: approve to the address(0) address"
        );

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "PENNY: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _swapBack(uint256 contractBalance) internal lockTheSwap {
        if (contractBalance == 0 || _tokensForFee == 0) return;

        if (contractBalance > _swapTokensAtAmount * 10)
            contractBalance = _swapTokensAtAmount * 10;

        _swapTokensForTokens(contractBalance);

        _usdcReceiver.withdraw();

        _tokensForFee = 0;

        IERC20(USDC).transfer(
            _feeCollector,
            IERC20(USDC).balanceOf(address(this))
        );
    }

    function _swapTokensForTokens(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDC;
        _approve(address(this), address(_uniswapV2Router02), tokenAmount);
        _uniswapV2Router02
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(_usdcReceiver),
                block.timestamp
            );
    }

    function setFee(uint256 _fee) external onlyOwner {
        require(_fee <= 100, "Fee can't be set above 10%");
        fee = _fee;
    }

    function _removeFee() internal {
        if (fee == 0) return;
        _previousFee = fee;
        fee = 0;
    }

    function _restoreFee() internal {
        fee = _previousFee;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) internal {
        if (!takeFee) _removeFee();
        else amount = _takeFees(sender, amount);

        _transferStandard(sender, recipient, amount);

        if (!takeFee) _restoreFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) internal {
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    function _takeFees(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        if (fee > 0) {
            uint256 fees = amount.mul(fee).div(1000);
            _tokensForFee += (fees * fee) / fee;

            if (fees > 0) _transferStandard(sender, address(this), fees);

            amount -= fees;
        }

        return amount;
    }

    function usdcReceiverAddress() external view returns (address) {
        return address(_usdcReceiver);
    }

    function openTrading() public onlyOwner {
        require(!tradingOpen, "PENNY: Trading is already open");
        IERC20(USDC).approve(
            address(_uniswapV2Router02),
            IERC20(USDC).balanceOf(address(this))
        );
        _uniswapV2Router02.addLiquidity(
            address(this),
            USDC,
            balanceOf(address(this)),
            IERC20(USDC).balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        swapEnabled = true;
        antiMEVEnabled = true;
        tradingOpen = true;
    }

    function setBuyLimit(uint256 _buyTreshold) public onlyOwner {
        require(
            _buyTreshold >= (totalSupply().mul(1).div(1000)),
            "PENNY: Max buy amount cannot be lower than 0.1% total supply."
        );
        buyLimit = _buyTreshold;
    }

    function setSellLimit(uint256 _sellLimit) public onlyOwner {
        require(
            _sellLimit >= (totalSupply().mul(1).div(1000)),
            "PENNY: Max sell amount cannot be lower than 0.1% total supply."
        );
        sellLimit = _sellLimit;
    }

    function setWalletLimit(uint256 _walletLimit) public onlyOwner {
        require(
            _walletLimit >= (totalSupply().mul(1).div(100)),
            "PENNY: Max wallet amount cannot be lower than 1% total supply."
        );
        walletLimit = _walletLimit;
    }

    function setSwapTokensAtAmount(uint256 _swapAmountThreshold)
        public
        onlyOwner
    {
        require(
            _swapAmountThreshold >= (totalSupply().mul(1).div(100000)),
            "PENNY: Swap amount cannot be lower than 0.001% total supply."
        );
        require(
            _swapAmountThreshold <= (totalSupply().mul(5).div(1000)),
            "PENNY: Swap amount cannot be higher than 0.5% total supply."
        );
        _swapTokensAtAmount = _swapAmountThreshold;
    }

    function setSwapEnabled(bool onoff) public onlyOwner {
        swapEnabled = onoff;
    }

    function setAntiMEVEnabled(bool onoff) public onlyOwner {
        antiMEVEnabled = onoff;
    }

    function setFeeCollector(address feeCollector) public onlyOwner {
        require(
            feeCollector != address(0),
            "PENNY: _feeCollector address cannot be 0"
        );
        _feeCollector = payable(feeCollector);
        _excludedFromFees[feeCollector] = true;
        _excludedMaxTransactionAmount[feeCollector] = true;
    }

    function excludeFromFees(address[] memory addresses, bool excluded)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < addresses.length; i++)
            _excludedFromFees[addresses[i]] = excluded;
    }

    function excludeFromMaxTransaction(
        address[] memory addresses,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++)
            _excludedMaxTransactionAmount[addresses[i]] = excluded;
    }

    function withdrawETH() public {
        require(msg.sender == _feeCollector, "Unauthorized");
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}(
            ""
        );
    }

    function withdrawForeignTokens(address tokenAddress) public {
        require(msg.sender == _feeCollector, "Unauthorized");
        require(tokenAddress != address(this), "Cannot withdraw this token");
        require(IERC20(tokenAddress).balanceOf(address(this)) > 0, "No tokens");
        uint256 amount = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }

    function removeLimits() public onlyOwner {
        buyLimit = _totalSupply;
        sellLimit = _totalSupply;
        walletLimit = _totalSupply;
    }
}