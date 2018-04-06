pragma solidity 0.4.18;


contract SingleElimTournament {

    struct Tournament {
        uint bond;
        uint maxPlayers;
        address[] players;
        uint8[] percentages;
        address[] proposedBracket;
        uint proposedIndex;
        mapping(address => uint) approvedBracket;
        TournamentStatus status;
    }

    event BracketProposed(uint id, address proposer, uint index, address[] bracket);

    function getTournament(uint id) external view returns (
        uint bond, 
        uint maxPlayers,
        address[] players,
        uint8[] percentages,
        address[] proposedBracket,
        uint proposedIndex,
        TournamentStatus status
    ) {
        Tournament memory t = tournaments[id];
        return (
            t.bond, t.maxPlayers, t.players, t.percentages, 
            t.proposedBracket, t.proposedIndex, t.status
        );
    }

    enum TournamentStatus {
        Open,
        Closed
    }

    Tournament[] tournaments;

    function createTournament(uint requiredBond, uint maxPlayers, uint8[] percentages) external returns (uint) {

        require(percentages.length <= maxPlayers);

        require(maxPlayers >= 2);

        Tournament memory t = Tournament({
            bond: requiredBond,
            maxPlayers: maxPlayers,
            players: new address[](0),
            proposedBracket: new address[](0),
            proposedIndex: 0,
            percentages: percentages,
            status: TournamentStatus.Open
        });

        uint id = tournaments.push(t) - 1;

        return id;
    }

    function joinTournament(uint id) external {
        Tournament storage t = tournaments[id];

        require(msg.value >= t.bond);

        require(t.status == TournamentStatus.Open);

        require(t.players.length < t.maxPlayers);

        t.players.push(msg.sender);
    }

    function proposeBracket(uint id, address[] bracket) external {
        
        Tournament storage t = tournaments[id];

        // must be different to current bracket
        if (bracket.length == t.proposedBracket.length) {
            bool flag = false;
            for (uint i = 0; i < bracket.length; i++) {
                if (bracket[i] != t.proposedBracket[i]) {
                    flag = true;
                    break;
                }
            }
            require(flag);
        }

        t.proposedBracket = bracket;
        t.proposedIndex++;

        BracketProposed(id, msg.sender, t.proposedIndex, t.proposedBracket);
    }

    function approveBracket(uint id, uint index) external {

        require(index > 0);

        Tournament storage t = tournaments[id];

        require(t.status == TournamentStatus.Open);

        require(index <= t.proposedIndex);

        t.approvedBracket[msg.sender] = index;
    }

    function close(uint id) external {

        Tournament storage t = tournaments[id];

        require(t.status == TournamentStatus.Open);

        require(t.proposedIndex > 0);

        // must all agree
        for (uint i = 0; i < t.players.length; i++) {
            require(t.approvedBracket[t.players[i]] == t.proposedIndex);
        }   

        t.status = TournamentStatus.Closed;
    }

    function payout(uint id) external {

        Tournament storage t = tournaments[id];

        require(t.status == TournamentStatus.Closed);

        uint index = 0;
        for (uint i = 0; i < t.players.length; i++) {
            if (t.players[i] == msg.sender) {
                index = i;
            }
        }

        // check it's not just blank
        if (index == 0) {
            require(t.players[0] == msg.sender);
        }

        require(t.percentages.length > index);

        require(t.percentages[index] > 0);

        uint total = t.players.length * t.bond;

        uint toPay = (total * t.percentages[index]) / 100;

        // watch reentracy
        t.percentages[index] = 0;

        msg.sender.transfer(toPay);

    }

}