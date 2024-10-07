
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC4626.sol";

abstract contract ERC4626 is IERC4626 {
    using Math for uint256;

    IERC20 private immutable _asset;
    uint8 private immutable _underlyingDecimals;

    constructor(IERC20 asset_) {
        (bool success, uint8 assetDecimals) = _tryGetAssetDecimals(asset_); 
        _underlyingDecimals = success ? assetDecimals : 18;
        _asset = asset_;
    }

    function _tryGetAssetDecimals(IERC20 asset_) private view returns(bool, uint8) {
        (bool success, bytes memory encodedDecimals) = address(asset_).staticcall(
            abi.encodeWithSelector(IERC20Metadata.decimals.selector)
        );

        if (success && encodedDecimals.length >= 32) {
            uint returnedDecimals = abi.decode(encodedDecimals, (uint256));
            if (returnedDecimals <= type(uint8).max) {
                return (true, uint8(returnedDecimals));
            }
        }

        return (false, 0);
    }

    function asset() external view returns(address) {
        return address(_asset);
    }

    function totalAssets() external view returns(uint) {
        _asset.balanceOf(address(this));
    }

    function convertToShares(uint assets) external view returns(uint) {
        _convertToShares(assets, Math.Rounding.Down);
    }

    function convertToAssets(uint shares) external view returns(uint) {
        _convertToAssets(assets, Math.Rounding.Down);
    }

    function maxDeposit(address receiver) external view virtual returns(uint) {
        return type(uint256).max;
    }

    function maxMint(address receiver) external view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address owner) external view virtual returns (uint256) {
        _convertToAssets(balanceOf(owner), Math.Rounding.Down);
    }

    function maxRedeem(address owner) external view virtual returns (uint256) {
        return balanceOf(owner);
    }


    function previewDeposit(uint assets) external view virtual returns(uint) {
        _convertToShares(assets, Math.Rounding.Down);
    }

    function previewMint(uint256 shares) external view virtual returns (uint256) {
        _convertToAssets(shares, Math.Rounding.Down);
    }

    function previewWithdraw(uint256 assets) external view virtual returns (uint256) {
        _convertToShares(assets, Math.Rounding.Down);
    }

    function previewRedeem(uint256 shares) external view virtual returns (uint256) {
        _convertToAssets(shares, Math.Rounding.Down);
    }

    function deposit(uint assets, address receiver) external returns(uint) {
        require(assets <= maxDeposit(receiver));
        uint shares = previewDeposit(assets);
        _deposit(msg.sender, receiver, assets, shares);

        return shares;
    }

    function mint(uint shares, address receiver) external returns(uint) {
        require(shares <= maxMint(receiver));
        uint assets = previewMint(shares);
        _deposit(msg.sender, receiver, assets, shares);

        return assets;
    }

    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256) {
        require(assets <= maxWithdraw(owner));

        uint shares = previewWithdraw(assets);
        _withdraw(msg.sender, receiver, owner, assets, shares);
    
        return shares;
    }

    function reedem(uint256 shares, address receiver, address owner) external returns (uint256) {
        require(shares <= maxReedem(owner));

        uint assets = previewRedeem(shares);
        _withdraw(msg.sender, receiver, owner, assets, shares);

        return assets;
    }

    function _deposit(
        address caller,
        address receiver,
        uint assets,
        uint shares
    ) internal virtual {
        _asset.transferFrom(caller, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(caller, receiver, assets, shares);
    }

    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint assets,
        uint shares
    ) internal virtual {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        _burn(owner, shares);
        _asset.transfer(receiver, assets);

        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    function _convertToShares(uint assets, Math.Rounding rounding) internal view virtual returns(uint) {
        // (assets * totalSupply) / totalAssets
        uint shares = assets.muldiv(totalSupply()  + 10 ** _decimalOffset(), totalAssets() + 1, rounding);

        return shares;
    }

    function _convertToAssets(uint shares, Math.Rounding rounding) internal view virtual returns(uint) {
        // (assets * totalSupply) / totalAssets
        uint assets = shares.muldiv(totalAssets() + 1, totalSupply()  + 10 ** _decimalOffset(), rounding);

        return assets;
    }

    function _decimalOffset() internal view virtual returns(uint8) {
        return 0;
    }
}
