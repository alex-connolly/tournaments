pragma solidity 0.4.17;

import "./AccessControl.sol";
import "./Battle.sol";

contract SeededTournament is Pausable {

    Battle battle;

    struct Tournament {
        uint8 seedingMatches;
        uint8 bestOfX;
        uint64 endOfSeeding;
        uint64 requiredPlayers;
        address[] players;
        mapping(address => Player) stats;
    }

    struct Player {
        uint8 seedingMatchesPlayed;
        // use elo instead of glicko etc to save gas
        uint16 elo;
    }

    Tournament[] public tournaments;

    // everyone plays n seeding matches, then a double elimination bracket is set up
    // these seeding matches are best of x

    function createTournament(
        uint _fee,
        uint8 _seedingMatches, 
        uint8 _bestOfX, 
        uint64 _seedingLimit,
        uint64 _requiredPlayers
    ) public returns (uint) {
        require(_seedingMatches > 0);
        require(_bestOfX > 0);
        require(_seedingLimit > 100);
        require(_requiredPlayers >= 2);

        Tournament memory t = Tournament({
            fee: _fee,
            seedingMatches: _seedingMatches,
            bestOfX: _bestOfX,
            seedingLimit: _seedingLimit,
            requiredPlayers: _requiredPlayers,
            players : new Player[](0)
        });

        uint id = tournaments.push(t) - 1;

        return id;
    }

    function joinTournament(uint _id) public {

        Tournament storage t = tournaments[_id];

        uint _fee = t.fee;

        require(msg.value >= _fee);

        // no overpays
        if (msg.value > t.fee) {
            msg.sender.transfer(msg.value - _fee);
        }

        Player memory p = Player({
            addr: msg.sender,
            seedingMatchesPlayed: 0,
            elo: 1600
        });

        t.players.push(p);

    }

    function commit();

    // bracket isn't randomised, it's ordered according to elo
    // ties split according to initial order
    // if you played zero 
    function createBracket() {
        Tournament memory t = tournaments[_id];
        require(block.number >= t.endOfSeeding);
    }

    function createSeedingMatches() {
        
        battle.createBattle();

    }

    function reportVictory(uint _id) {
        Tournament memory t = tournaments[_id];

    }

    function _expected(uint64 _aElo, uint64 _bElo) internal returns (uint64) {
        return 1 / (1 + 10 ** ((_aElo - _bElo) / 400));
    }

    uint64 k = 32;

    function setK(uint64 _k) external onlyOwner {
        k = _k;
    }

    function setBattle(address _battle) external onlyOwner {
        battle = _battle;
    }

    function _elo(uint64 _old, uint64 _exp, uint64 _score) {
        return _old + k * (_score - _exp);
    }

}