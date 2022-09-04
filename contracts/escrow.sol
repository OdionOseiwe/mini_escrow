// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


interface IERC721 {
    function transferFrom(
        address from,
        address to,
        uint256 nftid
    ) external returns(bool);
}
contract  escrow {
/// @dev    a escrow contrcact that first two partes are involved
/// @dev    the contract is a third party that holds the assets until the conditions 
/// @dev    are meet then it transfer the assets 

   /// @dev state variables

   address public  buyer;
   address public seller;
   IERC721 public NFT_contract_address;
   uint256 public NFTprice;
   uint256 tokenId;
 
   bool tranferedNFT;

   event sellerTransferred(address seller, uint256 price);

   /// custom errors

   /// not enough ethers
   error NotEnoughETH();

    constructor(address _nft_contract_address, uint256 tokenid, address _seller, address _buyer) {
        NFT_contract_address = IERC721(_nft_contract_address);
        tokenId = tokenid;
        seller = _seller;
        buyer = _buyer;
    }

    function sellerDespositsNFT(uint256 _priceofNFT) external {
        require(msg.sender == seller, "not seller");
        NFTprice = _priceofNFT;
        bool sent = IERC721(NFT_contract_address).transferFrom(seller, address(this), tokenId); 
        require(sent, "failed");
        tranferedNFT = true; 

        emit sellerTransferred(seller, NFTprice);
    }

    function buyersendsETH() external payable {
        require(tranferedNFT == true, "has not desposited nft");
        require(msg.sender == buyer, "not buyer");
        if(msg.value != NFTprice){
            revert NotEnoughETH();
        }
        IERC721(NFT_contract_address).transferFrom(address(this),buyer , tokenId); 
        (bool sent,) = seller.call{value:NFTprice}("");
        require(sent, "failed");
    }

    function contractBal() external view returns(uint256){
        return address(this).balance;
    }

//    function sellerdepositEthforPurchase()

}


   
