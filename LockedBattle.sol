pragma solidity 0.4.17;

import "./AccessControl.sol";


contract LockedBattle is Battle, Pausable {

    Duel[] public duels;

    struct Duel {
        uint8 bestOfX;
        uint8 count;
        uint64[] defenderParts;
        uint64[] attackerParts;
        uint8[] attackerMoves;
        bytes32 commit;
        address first;
        address second;
        DuelStatus status;
    }

    enum DuelStatus {
        Open,
        Exhausted,
        Completed,
        Cancelled
    }

    function createBattle(address _creator, uint[] _partIds,
        bytes32 _commit, uint _revealLength) external payable whenNotPaused returns (uint) {

        Duel duel 
    }


    function winnerOf(uint _id, uint) public returns (address) {
        Duel memory d = duels[_id];
        if (d.firstWins > d.secondWins) {
            return d.first;
        } else if (d.secondWins > d.firstWins) {
            return d.second;
        }
        return address(0);
    }

    function loserOf(uint _id, uint) public returns (address) {
        Duel memory d = duels[_id];
        if (d.firstWins > d.secondWins) {
            return d.second;
        } else if (d.secondWins > d.firstWins) {
            return d.first;
        }
        return address(0);
    }

    function commitMoves(uint _id, uint64 _partIds, bytes32 _commit) public {
        require(count < bestOfX);

        require(msg.value >= defenderFee);

        require(base.hasOrderedPartIds(_partIds));

        Duel storage d = duels[_id];

        require(d.status == DuelStatus.Open);

        address defender = count % 2 == 0 ? d.first : d.second;

        require(msg.sender == defender);

        d.commit = _commit;

    }

    function attack(uint _id, uint64[] _partIds, uint8[] _moves) external payable {
        
        require(base.hasOrderedRobotParts(_partIds));

        require(msg.value >= attackerFee);

        Duel storage d = duels[_id];
        
        require(d.status == DuelStatus.Open);

        address attacker = count % 2 == 0 ? d.second : d.first;

        require(msg.sender == attacker);

        d.attackerMoves = _moves;
        d.status = DuelStatus.Exhausted;
        d.attackerParts = _partIds;
        d.attackTime = now;


    }

    function claimTimeVictory(uint64 _id) public {

        Duel storage d = duels[_id];

        require(d.status == DuelStatus.Exhausted);
        require(now > d.attackTime + d.revealTime);

        _recordAttackerWin(d);

        _resetDuel(d);
    }

    function revealMoves(uint64 _id, uint8[] moves, bytes32 _seed) public returns (bool) {

        Duel storage d = duels[_id];

        address defender = count % 2 == 0 ? d.first : d.second;

        require(msg.sender == defender);

        require(d.commit = keccack256(_moves, _seed));

        if (!_isValidMoves(_moves)) {
            _recordAttackerWin(d);
            _resetDuel(d);
        }

    }

    function _recordAttackerWin(Duel storage _d) internal {
        if (count % 2 == 0) {
            _d.secondWins++;
        } else {
            _d.firstWins++;
        }
    }

    function _resetDuel(Duel storage _d) internal {
        _d.commit = "";
        _d.defenderParts = new uint64[](0);
        _d.attackerParts = new uint64[](0);
        _d.attackerMoves = new uint8[](0);
        _d.count++;
    }

}