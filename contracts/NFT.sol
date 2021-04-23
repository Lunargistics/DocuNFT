// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./openzeppelin/contracts/utils/Strings.sol";
import "./Admin.sol";
import "hardhat/console.sol";
/**
 * @title ERC1155Mock
 * This mock just publicizes internal functions for testing purposes
 */
contract NFT is ERC1155, Admin {
 
    string _baseURI;
    using Strings for uint256;
    uint maxObjects=10**9;
    uint maxForms;
    
    mapping(uint=>mapping(uint=>uint)) public formTypesMinted;
    mapping(address=>uint[]) public registeredObjects;
    mapping(uint=>address) public objectCreator;
    mapping(uint=>string ) public objectURI;
    mapping(address=>uint) public creator;
    mapping(uint=>bool) public revokedCreator;
    mapping(uint=>uint) public creatableObjects;


    uint maxFormTypes=10;
    uint createdObjects;
    uint creators;
    event newSpaceObject(uint objectID,address creator);

    constructor (string memory uri) ERC1155() {
        _baseURI=uri;
        // solhint-disable-previous-line no-empty-blocks
    }
    mapping(uint=>string) public _tokenURIs;

    function setURI(string memory newuri,uint id) public isMetadataAdmin() {
        _tokenURIs[id]=newuri;
    }
    function setBaseURI(string memory newuri) public isMetadataAdmin() {
        _baseURI=newuri;
    }
    function setMaxFormTypes(uint max) public isGlobalAdmin(){
        maxFormTypes=max;
    }
    function setTransferLock(uint[] memory _types) public isGlobalAdmin() {
        for(uint i=0;i<_types.length;i++){
            _setlocked(_types[i]);
        }
        
    }
    function getUserObjects(address u) public view returns(uint[] memory){
        return registeredObjects[u];
    }

    //token id is creatorID*10**64 + object*10**48 + +type*10**32 + formTypesMinted    
    function getFormId(uint _type,uint object,uint creator,uint minted) public view returns(uint){        
        return creator*10**64 + object*10**48+ _type*10**32+minted;
    }

    function getFormObject(uint token) public view returns(uint ){
        return (token/10**48) %10**16;
    }


    function uri(uint tokenid)   public view returns(string memory){
        string memory _tokenURI = _tokenURIs[tokenid];

        // If there is no base URI, return the token URI.
        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(_baseURI, tokenid.toString()));
    }

    function mint(address to, uint256 id, uint256 value, bytes memory data) public isMinter()  {
        _mint(to, id, value, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory values, bytes memory data) public isMinter() {
        _mintBatch(to, ids, values, data);
    }

    function burn( uint256 id, uint256 value) public  {
        _burn(msg.sender, id, value);
    }

    function burnBatch( uint256[] memory ids, uint256[] memory values) public {
        _burnBatch(msg.sender, ids, values);
    }

    function revokeCreatorPriveledges(uint creator) public isGlobalAdmin() {
        revokedCreator[creator]=!revokedCreator[creator];
    }
    function addObjectCreations(uint creator,uint value) public isGlobalAdmin() {
        creatableObjects[creator]+=value;
    }
    function transferFormOwner(uint creator,address newOwner) public isGlobalAdmin(){
        objectCreator[creator]=newOwner;
    }
    function mintform(uint formType,uint objectType,string memory formData) public {
        require(bytes(formData).length> 1,"form data must exist properly");
        require( objectCreator[objectType]==msg.sender);
        uint creatorID=creator[msg.sender];
        formTypesMinted[objectType][formType]+=1;
        uint ID=getFormId(formType,objectType,creatorID, formTypesMinted[objectType][formType]);
        console.log(ID);
        _tokenURIs[ID]=formData;
        _mint(msg.sender, ID, 1 ,"");
    }

    function registerNewObject(string memory data) public {
        require(creator[msg.sender]>0,"user must a creator to register an object");
        require(revokedCreator[creator[msg.sender]]==false,"creator has lost priviledges");
        require(creatableObjects[creator[msg.sender]]>0,"creator has no objects yet" );
        createdObjects+=1;
        creatableObjects[creator[msg.sender]]-=1;
        registeredObjects[msg.sender].push(createdObjects);
        objectCreator[createdObjects]=msg.sender;
        objectURI[createdObjects]=data;
        emit newSpaceObject(createdObjects,msg.sender);
    }

    function registerCreator(address a,uint limit) public  isGlobalAdmin(){
        //grantRole(GUEST, a);
        creators+=1;
        creator[a]=creators;
        creatableObjects[creators]+=limit;
    }

    function copyform(uint formID,address to) public{

        require( objectCreator[getFormObject(formID)]==msg.sender,"only object creator can copy a form");
        _mint(to,  formID, 1 ,"");
    }

        
}