import "./openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./Admin.sol";
interface saasNFT{
    function mint(address to, uint256 id, uint256 value, bytes memory data) external ;
}
contract saasPurchase is Admin{

    saasNFT public lunarToken;
    address payable public wallet;
    bool public salesOpen;
    uint public maxType=12;
    mapping(uint=>uint) public tokenPrices;
     
    constructor(address payable _wallet, address _lunarToken) public{
        wallet=_wallet;
        lunarToken= saasNFT(_lunarToken);
    }
    
    function purchase(uint _type) public payable{
        uint price=tokenPrices[_type];
        require(msg.value>=price,"user must send the correct value");
        require(_type>0 && _type <=maxType,"NFT id must be valid");
        lunarToken.mint(msg.sender, _type,1, "");
        wallet.transfer(msg.value);
    }

    function setPrices(uint[] memory prices,uint[] memory ids) public isGlobalAdmin() {
        require(prices.length==ids.length,"prices and ids must match");
        for(uint i=0;i<prices.length;i++){
            tokenPrices[ids[i]]=prices[i];
        }
    }

    function toggleSales() public isGlobalAdmin() {
        salesOpen=!salesOpen;
    }

    function setWallet(address payable a) public isGlobalAdmin() {
        wallet=a;
    }

}