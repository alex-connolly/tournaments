pragma solidity 0.4.17;


contract BaseTournament {


    struct Tournament {
        TournamentManager manager;
        uint requiredFee;
        address[] players;
        // stores references to indices within players array
        uint16[] bracket;
    }

    function createTournament(uint _fee) external returns (uint) {
        
        Tournament memory t = Tournament({
            requiredFee: _fee,
            players: ,
            bracket: 
        });

        uint id = tournaments.push(t) - 1;

        return id;
    }

    function createTournamentWithBracket(uint _id, ) {

    } 

    function 

}