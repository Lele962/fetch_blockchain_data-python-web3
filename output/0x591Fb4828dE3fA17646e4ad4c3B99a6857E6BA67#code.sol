// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Local Imports
import "../interfaces/IGvToken.sol";
import "../interfaces/IRcaController.sol";

/// @dev Customized Sushi MasterChef to meet the need of ez-tokens farming

/// This implementation updates Sushi MasterChefV1 such that the rewarder can
/// drip reward tokens to this contract instead of minting like sushi does.
/// Everything else remains the same we remove migration logic as we
/// won't need that and we rename sushi to ease.

contract MasterChef is Ownable {
    using SafeERC20 for IERC20;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many ez tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of EASE
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * ezVault.accEasePerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a ezVault. Here's what happens:
        //   1. The ezVault's `accEasePerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each ez-vault.
    struct EzVaultInfo {
        IERC20 ezToken; // Address of ez-token contract.
        uint256 allocPoint; // How many allocation points assigned to this ez-vault. EASE to distribute per block. Same for all ez-vaults
        uint256 lastRewardBlock; // Last block number that EASE distribution occurs.
        uint256 accEasePerShare; // Accumulated EASE per share, times 1e12. See below.
    }

    // Accumulated EASE per share scale factor
    uint256 public constant MULTIPLIER = 1e12;
    // The EASE TOKEN!
    IERC20 public immutable ease;
    // ease growing vote token
    IGvToken public immutable gvToken;
    // EASE tokens rewarded per block.
    uint256 public easePerBlock;
    // Info of each ez-vault.
    EzVaultInfo[] public ezVaultInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all ez-vaults.
    uint256 public totalAllocPoint = 0;
    // The block number when EASE mining starts.
    uint256 public startBlock;

    /* ========== EVENTS ========== */
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    event VaultAdded(address indexed ezVaultAddress, uint256 indexed vaultId);

    constructor(
        IERC20 _ease,
        IGvToken _gvToken,
        uint256 _easePerBlock
    ) {
        ease = _ease;
        gvToken = _gvToken;
        easePerBlock = _easePerBlock;
        startBlock = block.number;
        // approve ease to gvToken
        ease.approve(address(_gvToken), type(uint256).max);
    }

    /// @notice returns total number of ez-vaults that are available for farming
    function poolLength() external view returns (uint256) {
        return ezVaultInfo.length;
    }

    /// @notice Add a new ez-vault. Can only be called by the owner.
    /// DO NOT add the same ez-vault more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20 _ezToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        ezVaultInfo.push(
            EzVaultInfo({
                ezToken: _ezToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accEasePerShare: 0
            })
        );
        emit VaultAdded(address(_ezToken), ezVaultInfo.length - 1);
    }

    /// @notice Update the given pool's EASE allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint =
            totalAllocPoint -
            ezVaultInfo[_pid].allocPoint +
            _allocPoint;
        ezVaultInfo[_pid].allocPoint = _allocPoint;
    }

    /// @notice Update ease per block. Can be called by only Owner
    function setEasePerBlock(uint256 _easePerBlock) external onlyOwner {
        massUpdatePools();
        easePerBlock = _easePerBlock;
    }

    /// @notice Sweep farming tokens to the owner. Can be called by only owner.
    function sweep(uint256 amount) external onlyOwner {
        ease.safeTransfer(msg.sender, amount);
    }

    /// @notice View function to see pending EASE on frontend.
    function pendingEase(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        EzVaultInfo storage ezVault = ezVaultInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accEasePerShare = ezVault.accEasePerShare;
        uint256 lpSupply = ezVault.ezToken.balanceOf(address(this));
        if (block.number > ezVault.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = block.number - ezVault.lastRewardBlock;

            uint256 easeReward = (multiplier *
                easePerBlock *
                ezVault.allocPoint) / totalAllocPoint;
            accEasePerShare =
                accEasePerShare +
                ((easeReward * MULTIPLIER) / lpSupply);
        }
        return ((user.amount * accEasePerShare) / MULTIPLIER) - user.rewardDebt;
    }

    /// @notice Update reward vairables for all ez-vaults. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = ezVaultInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    /// @notice Update reward variables of the given ez-vault to be up-to-date.
    function updatePool(uint256 _pid) public {
        EzVaultInfo storage ezVault = ezVaultInfo[_pid];
        if (block.number <= ezVault.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = ezVault.ezToken.balanceOf(address(this));
        if (lpSupply == 0) {
            ezVault.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number - ezVault.lastRewardBlock;
        uint256 easeReward = (multiplier * easePerBlock * ezVault.allocPoint) /
            totalAllocPoint;
        ezVault.accEasePerShare =
            ezVault.accEasePerShare +
            ((easeReward * MULTIPLIER) / lpSupply);
        ezVault.lastRewardBlock = block.number;
    }

    /// @notice Deposit ez-tokens to MasterChef for EASE allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        EzVaultInfo storage ezVault = ezVaultInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = (user.amount * ezVault.accEasePerShare) /
                (MULTIPLIER) -
                (user.rewardDebt);
            if (pending != 0) {
                gvToken.depositFor(msg.sender, pending);
            }
        }
        ezVault.ezToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount += _amount;
        user.rewardDebt = (user.amount * ezVault.accEasePerShare) / MULTIPLIER;
        emit Deposit(msg.sender, _pid, _amount);
    }

    /// @notice Withdraw ez-tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        EzVaultInfo storage ezVault = ezVaultInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = (user.amount * ezVault.accEasePerShare) /
            (MULTIPLIER) -
            (user.rewardDebt);
        if (pending != 0) {
            gvToken.depositFor(msg.sender, pending);
        }
        user.amount -= _amount;
        user.rewardDebt = (user.amount * ezVault.accEasePerShare) / MULTIPLIER;

        // Withdraw ezTokens
        if (_amount != 0) {
            ezVault.ezToken.safeTransfer(address(msg.sender), _amount);
            emit Withdraw(msg.sender, _pid, _amount);
        }
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        EzVaultInfo storage ezVault = ezVaultInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        ezVault.ezToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }
}