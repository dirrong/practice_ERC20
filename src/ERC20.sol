// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./EIP712.sol";


contract ERC20 is EIP712{
    mapping(address => uint256) private balances; // 각 address 잔고 정보
    mapping(address => mapping(address => uint256)) private allowances; // (소유자, 사용자) 조합에 대한 인출 허용량
    mapping(address => uint256) private _nonces;
    uint256 private _totalSupply; // 총 토큰 발행량


    string private _name;
    string private _symbol;
    uint8 private _decimal;
    bool public paused = false;
    bytes32 hash = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Pause();


    constructor (string memory name, string memory version) EIP712(name, version) {
        _name = name;
        _symbol = version;
        _totalSupply = 100 ether;
        balances[msg.sender] = 100 ether;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimal;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }


    function transfer(address _to, uint256 _value) external returns (bool success) {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer from the zero address");
        require(balances[msg.sender] >= _value, "value exceeds balance");

        unchecked {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }
        
        emit Transfer(msg.sender, _to, _value);

    }

    function transferFrom (address _from, address _to, uint256 _value) external returns (bool success) {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_from != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");

        uint256 currentAllowance = allowance(_from, msg.sender);
        require(currentAllowance >= _value, "insufficient allowance");

        unchecked {
            allowances[_from][msg.sender] -= _value;
        }

        require(balances[_from] >= _value, "value exceeds balance");

        unchecked {
            balances[_from] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(_from, _to, _value);
    }


    function pause() public {
        require(paused);

        emit Pause();
    }
    

    function approve(address _to, uint256 _value) public returns (bool success) {
        address _from = msg.sender;
        //allowances[_from][_to] = _value;
        _approve(_from, _to, _value);
    } 


    function _approve(address _from, address _to, uint256 _value) public returns (bool success) {
        allowances[_from][_to] = _value;
    } 


    function allowance(address _owner, address _to) public view returns (uint256) {
        return allowances[_owner][_to];
    }


    function permit(address _owner, address _spender, uint256 _value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        uint newnonce = _nonces[_owner]; 
        bytes32 structHash = keccak256(abi.encode(hash, _owner, _spender, _value, newnonce, deadline));
        bytes32 HASH = _toTypedDataHash(structHash);

        require(block.timestamp <= deadline);

        _nonces[_owner] += 1;
        
        address signer = ecrecover(HASH, v, r, s);
        require(_owner == signer, "INVALID_SIGNER");


        _approve(_owner, _spender, _value);
    }


    function nonces(address _addr) public returns (uint256) {
        return _nonces[_addr];
    }


    function _mint(address _owner, uint256 _value) internal returns (bool success) {
        require(_owner != address(0));
        
        _totalSupply += _value;
        balances[_owner] += _value;

        emit Transfer(address(0), _owner, _value);
    }


    function _burn(address _owner, uint _value) internal returns (bool success) {
        require(_owner != address(0));

        _totalSupply -= _value;
        balances[_owner] -= _value;

        emit Transfer(_owner, address(0), _value);
    }


}