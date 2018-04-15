pragma solidity 0.4.21;
// must be a version of Solidity with struct/dynamic array params

import "../TournamentManager.sol";


// Single Elimination tournament
contract SingleElimTournament is TournamentManager {

    function createBracket(uint commit, address[] players) public returns (address[]) {
        // one source of randomness
        address bracket = new address[](players.length);
        uint count = 0;
        for (uint i = 0; players.length; i++) {
            uint rand = keccak256(commit, msg.sender, i) % players.length;
            while (bracket[rand] == 0) {
                rand = rand == players.length ? 0 : rand++;
            }
            bracket[rand] = players[count++];
        }
        return bracket;
    }

    //
    function updateBracket(uint bracketIndex) public returns (bool) {
        // reports the result of a tournament match

    }

    function claimPrize()

}
