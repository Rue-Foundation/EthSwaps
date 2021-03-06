pragma solidity ^0.4.6;

contract Oracle{

struct DocumentStruct{
   uint value;
 }

mapping(bytes32 => DocumentStruct) public documentStructs;

function StoreDocument(bytes32 key, uint value) returns (bool success) {
  documentStructs[key].value = value;
 return true;
}

}

contract Swap {
enum SwapState {available,open,started,ended}
SwapState public currentState;
address public counterparty1;
address public counterparty2;
uint public notional;
bool public long;
uint public margin;
address public oracleID;
bytes32 public endDate;
address public creator; 
uint256 public startValue;

modifier onlyState(SwapState expectedState) { if (expectedState == currentState) {_;} else {throw; } }

function Swap(address OAddress){
    d = Oracle(OAddress);
    oracleID = OAddress;
    creator = msg.sender;
    currentState = SwapState.available;
}

Oracle d;

function CreateSwap(uint _notional, bool _long, bytes32 _startDate, bytes32 _endDate) onlyState(SwapState.available) payable returns (bool) {
    margin = msg.value;
    counterparty1 = msg.sender;
    notional = _notional;
    long = _long;
    currentState = SwapState.open;
    endDate = _endDate;
    startValue = RetrieveData(_startDate);
    return true;
}

function EnterSwap() onlyState(SwapState.open) payable returns (bool) {

    if(msg.value == margin) {
        counterparty2 = msg.sender;
        currentState = SwapState.started;
        return true;
    } else {
      throw;
    }
}
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    function transferFrom(
        address _from,
         address _to,
        uint256 _amount
    ) returns (bool success) {
       if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
             && _amount > 0
             && balances[_to] + _amount > balances[_to]) {
             balances[_from] -= _amount;
           allowed[_from][msg.sender] -= _amount;
             balances[_to] += _amount;
             return true;
         } else {
             return false;
         }
    }

function PaySwap() onlyState(SwapState.started) returns (bool){
    var endValue = RetrieveData(endDate);
    var change = notional * (startValue - endValue) / startValue;
    var lvalue = change >= margin ? (this.balance) : (margin + change);
    var svalue = change <= -margin ? (this.balance) : (margin - change);
    if (lvalue > 0 ){
        if (long){
            transferFrom(this,counterparty1,lvalue);
        }
        else{
            transferFrom(this,counterparty2,lvalue);
        }
    }
    if (svalue > 0){
        if (long){
            transferFrom(this,counterparty2,svalue);
        }
        else{
            transferFrom(this,counterparty1,svalue);
        }
    }
    currentState = SwapState.ended;
    return true;
}


 struct DocumentStruct{
    uint value;
  }    
      function RetrieveData(bytes32 key) 
        public
        constant
        returns(uint) 
      {
        DocumentStruct memory doc;
      doc.value = d.documentStructs(key);
        return doc.value;
     }

}
