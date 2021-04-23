const NFT = artifacts.require("NFT");

let utils=require('web3-utils')
const {
  BN,           // Big Number support 
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert,
  increase,
  increastTo, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');
let nft;
/**
    * W:1 X: 1 Y: 1 encodes to:		110011001
    W:1 X: 0 Y: 0 encodes to:		110001000
    W:1 X:-1 Y:-1 encodes to:		109990999
    W:1 X:-1000 Y:-1000 encodes to:	100000000
    W:0 X: 1 Y: 1 encodes to:		  10011001 (this is the most tricky one, but it’s still relatively easy to parse)
 */

contract("encoderTests", accounts => {
    
    before(async function() {
   
     nft = await NFT.new("test uri")
     let guestrole=await nft.GUEST()
     nft.registerCreator(accounts[1])
     nft.registerCreator(accounts[2])
     nft.setTransferLock([1,2,3,4,5,6,7,8,9,10])
    });
    it("registers new objects:",async function(){
        await nft.registerNewObject("test object 1",{from:accounts[1]})
        await nft.registerNewObject("test object 2",{from:accounts[2]})
        await nft.registerNewObject("test object 3",{from:accounts[1]})
        await nft.registerNewObject("test object 4",{from:accounts[2]})
        let id=await nft.getFormId(1,1,1,1)
        console.log(id.toString())
        let user1Objects=await nft.getUserObjects(accounts[1])
        let user2Objects=await nft.getUserObjects(accounts[2])
        await nft.mintform(1,1,"This is some form data",{from:accounts[1]})
        assert.equal(await nft.balanceOf(accounts[1],id),1,"after minting account 1 has a form")
        await nft.copyform(id,accounts[5],{from:accounts[1]}) 
        assert.equal(await nft.balanceOf(accounts[5],id),1,"form is copied to account 5")
        await expectRevert( nft.safeTransferFrom(
            accounts[1],
            accounts[4],
            id,
            1,
            "0x",
            {from:accounts[1]}
       ),"token transfers are locked for this type")
    })
  
})