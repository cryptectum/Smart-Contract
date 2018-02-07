pragma solidity ^0.4.15;
import './F_BaseToken.sol';

contract fileUploadEnabled is BaseToken {
    
    uint public fileNumber=1;
    
    struct file{
        string hash;
        string name;
        string desc;
    }
    mapping(uint=>file) public fileStorage;
    function uploadFileHash (string fileHash, string fileName, string fileDescription) ownerOnly{
        require(msg.sender==owner);
        fileStorage[fileNumber].hash = fileHash;
        fileStorage[fileNumber].name = fileName;
        fileStorage[fileNumber].desc = fileDescription;
        fileNumber++;
    }

    function retriveFilehash(uint _fileNumber) returns(string,string,string){
        return  (fileStorage[_fileNumber].hash, fileStorage[_fileNumber].name, fileStorage[_fileNumber].desc);
    }
}