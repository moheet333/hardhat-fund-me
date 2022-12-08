//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./PriceConverter.sol";

error FundMe__NotOwner();

/**@title Ac ontract for crowd funding
 * @author Moheet Shendarkar
 * @notice This contract is to demo a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 10 * 1e18; // optimized

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    address private immutable i_owner; // optimized

    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner(); // new
        }
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }
    /**
     * @notice This function funds this contract
     * @dev This implements price feeds as our library
     */

    function fund() public payable {

        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH!"
        ); // 1e18 = 10^18 wei = 1 eth
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
        // reverting message returns the extra gas required for computation
    }

    function withDraw() public onlyOwner {
        //set mapping to zero
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funderAddress = s_funders[funderIndex];
            s_addressToAmountFunded[funderAddress] = 0;
        }

        s_funders = new address[](0);

        //call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed!");
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder) public view returns(uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns(AggregatorV3Interface) {
        return s_priceFeed;
    }

    // function cheaperWithDraw() public payable onlyOwner {
    //     address[] memory funders = s_funders;
    //     // mapping cant be in memory
    //     for(uint256 funderIndex=0;funderIndex<funders.length;funderIndex++) {
    //         address funder = funders[funderIndex];
    //         s_addressToAmountFunded[funder] = 0;
    //     }
    //     s_funders = new address[](0);
    //     (bool success,) = i_owner.call{value: address(this).balance}("");
    //     require(success);
    // }
}
