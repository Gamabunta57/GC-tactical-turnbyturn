DB = {
    unit = {
        {
            move = 2,
            attack = 5,
            defence = 3,
            hp = 10,
            sight = 5,
            range = 1,
            type = "melee"
        },
        melee = 1
    },

    blockingTile = {
        5, 6, 11, 12, 17, 18, 23, 24, 27, 29, 30, 33, 34, 35, 36
    },
}

DB.unitTileId = {
    _34 = {
        type = DB.unit.melee,
        player = P2
    }, 
    _35 = {
        type = DB.unit.archer,
        player = P2
    }, 
    _28 = {
        type = DB.unit.melee,
        player = P1
    }, 
    _29 = {
        type = DB.unit.archer,
        player = P1
    }, 
}