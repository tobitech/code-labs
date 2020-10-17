pragma solidity >=0.4.21 <0.6.0;

contract IScoreStore {
  function GetScore(string name) returns (int);
}

contract MyGame {
  function ShowScore(string name) returns (int) {
    IScoreStore scoreStore = IScoreStore();
  }
}