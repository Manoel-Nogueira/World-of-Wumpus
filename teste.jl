using OrderedCollections

#= Notação do mundo de wumpus:

    Wumpus: 🐻
    Brisa: 💨 
    Fedor: 💩 
    Caçador: 🤠
    Vazio / Terreno: 🟩 
    Ouro: 💵 
    Buraco: 🌌

    Encontros:

    Brisa c/ Fedor: 👃
    Brisa c/ Brisa: 🌀
    Brisa c/ Brisa c/ Fedor: 💦
    Brisa c/ Ouro: 💶
    Fedor c/ Ouro: 💴
    Brisa c/ Fedor c/ Ouro: 💷
    Brisa c/ Brisa c/ Ouro: 💸
    Brisa c/ Brisa c/ Fedor c/ Ouro:💰
    


=#

COORDINATES  = [                    [1, 3], [1, 4],
                            [2, 2], [2, 3], [2, 4],
                    [3, 1], [3, 2], [3, 3], [3, 4],
                    [4, 1], [4, 2], [4, 3], [4, 4],
                ]

POSITIONS = OrderedDict([([1, 1], '🟩')])
SAFE_POSITIONS = []
CHOSEN_DIRECTION = []
BEST_WAY = [[1, 1]]
HAVE_BREEZE = []
HAVE_HOLES = []
HAVE_STINK = []
HAVE_WUMPUS = []
COIN_EMOJIS = ['💸', '💶', '💴', '💷', '💸', '💰']
TRAPS = ['🐻', '🌌']
FOUND_GOLD = false
      
# Função para imprimir o mundo
function PrintWorld(world)

    for row in eachrow(world)
        
        println(join(row, "")) 

    end

end

# Função para limpar o console
function ClearConsole()

    if Sys.islinux()

        run(`clear`)

    else
    
        run(`cls`)

    end
    
end

# Função para sortear um número entre 1 e 4
function DrawLots() 

    drawn = rand(COORDINATES )

    splice!(COORDINATES , searchsortedfirst(COORDINATES , drawn))

    return drawn
    
end

# Função para criar o wumpus
function CreateWumpus(world)

    drawn =  DrawLots()
    
    world[drawn[1], drawn[2]] = '🐻'

    if drawn[1] > 1

        world[drawn[1] - 1, drawn[2]] = '💩'

    end

    if drawn[1] < 4

        world[drawn[1] + 1, drawn[2]] = '💩'

    end

    if drawn[2] > 1

        world[drawn[1], drawn[2] - 1] = '💩'

    end

    if drawn[2] < 4

        world[drawn[1], drawn[2] + 1] = '💩'

    end
    
end

# Função para criar os buracos
function CreateHoles(world)

    drawn =  DrawLots()

    world[drawn[1], drawn[2]] = '🌌'

    if drawn[1] > 1 && world[drawn[1] - 1, drawn[2]]  != '🐻' && world[drawn[1] - 1, drawn[2]] != '🌌'

            if world[drawn[1] - 1, drawn[2]] == '💩'
            
                world[drawn[1] - 1, drawn[2]] = '👃'

            elseif  world[drawn[1] - 1, drawn[2]] == '💨'

                world[drawn[1] - 1, drawn[2]] = '🌀'

            else

                world[drawn[1] - 1, drawn[2]] = '💨'

            end

    end

    if drawn[1] < 4 && world[drawn[1] + 1, drawn[2]]  != '🐻' && world[drawn[1] + 1, drawn[2]] != '🌌'

            if world[drawn[1] + 1, drawn[2]] == '💩'
            
                world[drawn[1] + 1, drawn[2]] = '👃'

            elseif world[drawn[1] + 1, drawn[2]] == '💨'

                world[drawn[1] + 1, drawn[2]] = '🌀'

            else

                world[drawn[1] + 1, drawn[2]] = '💨'

            end

    end

    if drawn[2] > 1 && world[drawn[1], drawn[2] - 1] != '🐻' && world[drawn[1], drawn[2] - 1] != '🌌' 

            if world[drawn[1], drawn[2] - 1] == '💩'
            
                world[drawn[1], drawn[2] - 1] = '👃'

            elseif world[drawn[1], drawn[2] - 1] == '💨'

                world[drawn[1], drawn[2] - 1] = '🌀'

            elseif world[drawn[1], drawn[2] - 1] == '👃'

                world[drawn[1], drawn[2] - 1] = '💦'

            else

                world[drawn[1], drawn[2] - 1] = '💨'

            end

    end


    if drawn[2] < 4 && world[drawn[1], drawn[2] + 1] != '🐻' && world[drawn[1], drawn[2] + 1] != '🌌'

        if world[drawn[1], drawn[2] + 1] == '💩'
        
            world[drawn[1], drawn[2] + 1] = '👃'

        elseif world[drawn[1], drawn[2] + 1] == '💨' 

            world[drawn[1], drawn[2] + 1] = '🌀'
        
        else

            world[drawn[1], drawn[2] + 1] = '💨'

        end

    end
    
end

# Função para criar o ouro
function CreateGold(world)

    drawn = DrawLots()

    if world[drawn[1], drawn[2]] == '💨'

        world[drawn[1], drawn[2]] = '💶'

    elseif  world[drawn[1], drawn[2]] == '💩'

        world[drawn[1], drawn[2]] = '💴'

    elseif  world[drawn[1], drawn[2]] == '👃'

        world[drawn[1], drawn[2]] = '💷'

    elseif world[drawn[1], drawn[2]] == '🌀'

        world[drawn[1], drawn[2]] = '💸'

    elseif world[drawn[1], drawn[2]] == '💦'

        world[drawn[1], drawn[2]] = '💰'

    else

        world[drawn[1], drawn[2]] = '💵'

    end
    
end

# Função para sortear uma direção
function DirectionRaffle(allMovements)

    #= Notação das direções

        U: Up
        D: dow
        L: Left
        R: Right

    =#

    directionsUDLR = ['U', 'D', 'L', 'R']
    directionsDR = ['D', 'R']

    return allMovements == true ? rand(directionsUDLR) : rand(directionsDR)
    
end

# Função para retornar a posição de um objeto
function Position(object, world)

    return findfirst(==(object), world)
    
end

# Função para movimentar o caçador
function HunterMove(world, direction)

    playerPosition = Position('🤠', world)

    if direction == 'U' && playerPosition[1] > 1

        println("up")

        if world[playerPosition[1] - 1, playerPosition[2]] == '🟩'
            
            POSITIONS[[playerPosition[1] - 1, playerPosition[2]]] = '🟩'
            
        elseif world[playerPosition[1] - 1, playerPosition[2]] == '💨'
        
            POSITIONS[[playerPosition[1] - 1, playerPosition[2]]] = '💨'
            HAVE_BREEZE = [[playerPosition[1] - 1, playerPosition[2]]]

        elseif world[playerPosition[1] - 1, playerPosition[2]] == '💩'
        
            POSITIONS[[playerPosition[1] - 1, playerPosition[2]]] = '💩'
            HAVE_STINK = [[playerPosition[1] - 1, playerPosition[2]]]

        elseif world[playerPosition[1] - 1, playerPosition[2]] == '👃'
            
            POSITIONS[[playerPosition[1] - 1, playerPosition[2]]] = '👃'
            HAVE_BREEZE = [[playerPosition[1] - 1, playerPosition[2]]]
            HAVE_STINK = [[playerPosition[1] - 1, playerPosition[2]]]
            
        elseif world[playerPosition[1] - 1, playerPosition[2]] == '🌀'
        
            POSITIONS[[playerPosition[1] - 1, playerPosition[2]]] = '🌀'
            HAVE_BREEZE = [[playerPosition[1] - 1, playerPosition[2]]]
            HAVE_BREEZE = [[playerPosition[1] - 1, playerPosition[2]]]

        elseif world[playerPosition[1] - 1, playerPosition[2]] == '💦'
        
            POSITIONS[[playerPosition[1] - 1, playerPosition[2]]] = '💦'
            HAVE_BREEZE = [[playerPosition[1] - 1, playerPosition[2]]]
            HAVE_BREEZE = [[playerPosition[1] - 1, playerPosition[2]]]
            HAVE_STINK = [[playerPosition[1] - 1, playerPosition[2]]]

        elseif world[playerPosition[1] - 1, playerPosition[2]] in COIN_EMOJIS
        
            POSITIONS[[playerPosition[1] - 1, playerPosition[2]]] = '🟩'
            FOUND_GOLD = true;

        elseif world[playerPosition[1] - 1, playerPosition[2]] in TRAPS

            world[playerPosition[1] - 1, playerPosition[2]] = '🤠'
            world[playerPosition[1], playerPosition[2]] = POSITIONS[[playerPosition[1], playerPosition[2]]]
            println("!!! O caçador morreu :| !!!")
            return false;

        end

        world[playerPosition[1] - 1, playerPosition[2]] = '🤠'
        world[playerPosition[1], playerPosition[2]] = POSITIONS[[playerPosition[1], playerPosition[2]]]


    elseif direction == 'D' && playerPosition[1] < 4

        println("dow")

        if world[playerPosition[1] + 1, playerPosition[2]] == '🟩'
            
            POSITIONS[[playerPosition[1] + 1, playerPosition[2]]] = '🟩'
            
        elseif world[playerPosition[1] + 1, playerPosition[2]] == '💨'
        
            POSITIONS[[playerPosition[1] + 1, playerPosition[2]]] = '💨'
            HAVE_BREEZE = [[playerPosition[1] + 1, playerPosition[2]]]

        elseif world[playerPosition[1] + 1, playerPosition[2]] == '💩'
        
            POSITIONS[[playerPosition[1] + 1, playerPosition[2]]] = '💩'
            HAVE_STINK = [[playerPosition[1] + 1, playerPosition[2]]]

        elseif world[playerPosition[1] + 1, playerPosition[2]] == '👃'
            
            POSITIONS[[playerPosition[1] + 1, playerPosition[2]]] = '👃'
            HAVE_BREEZE = [[playerPosition[1] + 1, playerPosition[2]]]
            HAVE_STINK = [[playerPosition[1] + 1, playerPosition[2]]]
            
        elseif world[playerPosition[1] + 1, playerPosition[2]] == '🌀'
        
            POSITIONS[[playerPosition[1] + 1, playerPosition[2]]] = '🌀'
            HAVE_BREEZE = [[playerPosition[1] + 1, playerPosition[2]]]
            HAVE_BREEZE = [[playerPosition[1] + 1, playerPosition[2]]]

        elseif world[playerPosition[1] + 1, playerPosition[2]] == '💦'
        
            POSITIONS[[playerPosition[1] + 1, playerPosition[2]]] = '💦'
            HAVE_BREEZE = [[playerPosition[1] + 1, playerPosition[2]]]
            HAVE_BREEZE = [[playerPosition[1] + 1, playerPosition[2]]]
            HAVE_STINK = [[playerPosition[1] + 1, playerPosition[2]]]

        elseif world[playerPosition[1] + 1, playerPosition[2]] in COIN_EMOJIS
        
            POSITIONS[[playerPosition[1] + 1, playerPosition[2]]] = '🟩'
            FOUND_GOLD = true;

        elseif world[playerPosition[1] + 1, playerPosition[2]] in TRAPS

            world[playerPosition[1] + 1, playerPosition[2]] = '🤠'
            world[playerPosition[1], playerPosition[2]] = POSITIONS[[playerPosition[1], playerPosition[2]]]
            println("!!! O caçador morreu :| !!!")
            return false;

        end

        world[playerPosition[1] + 1, playerPosition[2]] = '🤠'
        world[playerPosition[1], playerPosition[2]] = POSITIONS[[playerPosition[1], playerPosition[2]]]


    elseif direction == 'L' && playerPosition[2] > 1

        println("left")

        if world[playerPosition[1], playerPosition[2] - 1] == '🟩'
            
            POSITIONS[[playerPosition[1], playerPosition[2] - 1]] = '🟩'
            
        elseif world[playerPosition[1], playerPosition[2] - 1] == '💨'
        
            POSITIONS[[playerPosition[1], playerPosition[2] - 1]] = '💨'
            HAVE_BREEZE = [[playerPosition[1], playerPosition[2] - 1]]

        elseif world[playerPosition[1], playerPosition[2] - 1] == '💩'
        
            POSITIONS[[playerPosition[1], playerPosition[2] - 1]] = '💩'
            HAVE_STINK = [[playerPosition[1], playerPosition[2] - 1]]

        elseif world[playerPosition[1], playerPosition[2] - 1] == '👃'
            
            POSITIONS[[playerPosition[1], playerPosition[2] - 1]] = '👃'
            HAVE_BREEZE = [[playerPosition[1], playerPosition[2] - 1]]
            HAVE_STINK = [[playerPosition[1], playerPosition[2] - 1]]
            
        elseif world[playerPosition[1], playerPosition[2] - 1] == '🌀'
        
            POSITIONS[[playerPosition[1], playerPosition[2] - 1]] = '🌀'
            HAVE_BREEZE = [[playerPosition[1], playerPosition[2] - 1]]
            HAVE_BREEZE = [[playerPosition[1], playerPosition[2] - 1]]

        elseif world[playerPosition[1], playerPosition[2] - 1] == '💦'
        
            POSITIONS[[playerPosition[1], playerPosition[2] - 1]] = '💦'
            HAVE_BREEZE = [[playerPosition[1], playerPosition[2] - 1]]
            HAVE_BREEZE = [[playerPosition[1], playerPosition[2] - 1]]
            HAVE_STINK = [[playerPosition[1], playerPosition[2] - 1]]

        elseif world[playerPosition[1], playerPosition[2] - 1] in COIN_EMOJIS
        
            POSITIONS[[playerPosition[1], playerPosition[2] - 1]] = '🟩'
            FOUND_GOLD = true;

        elseif world[playerPosition[1], playerPosition[2] - 1] in TRAPS

            world[playerPosition[1], playerPosition[2] - 1] = '🤠'
            world[playerPosition[1], playerPosition[2]] = POSITIONS[[playerPosition[1], playerPosition[2]]]
            println("!!! O caçador morreu :| !!!")
            return false;

        end

        world[playerPosition[1], playerPosition[2] - 1] = '🤠'
        world[playerPosition[1], playerPosition[2]] = POSITIONS[[playerPosition[1], playerPosition[2]]]

    elseif direction == 'R' && playerPosition[2] < 4 

        println("right")
        
        if world[playerPosition[1], playerPosition[2] + 1] == '🟩'
            
            POSITIONS[[playerPosition[1], playerPosition[2] + 1]] = '🟩'
            
        elseif world[playerPosition[1], playerPosition[2] + 1] == '💨'
        
            POSITIONS[[playerPosition[1], playerPosition[2] + 1]] = '💨'
            HAVE_BREEZE = [[playerPosition[1], playerPosition[2] + 1]]

        elseif world[playerPosition[1], playerPosition[2] + 1] == '💩'
        
            POSITIONS[[playerPosition[1], playerPosition[2] + 1]] = '💩'
            HAVE_STINK = [[playerPosition[1], playerPosition[2] + 1]]

        elseif world[playerPosition[1], playerPosition[2] + 1] == '👃'
            
            POSITIONS[[playerPosition[1], playerPosition[2] + 1]] = '👃'
            HAVE_BREEZE = [[playerPosition[1], playerPosition[2] + 1]]
            HAVE_STINK = [[playerPosition[1], playerPosition[2] + 1]]
            
        elseif world[playerPosition[1], playerPosition[2] + 1] == '🌀'
        
            POSITIONS[[playerPosition[1], playerPosition[2] + 1]] = '🌀'
            HAVE_BREEZE = [[playerPosition[1], playerPosition[2] + 1]]
            HAVE_BREEZE = [[playerPosition[1], playerPosition[2] + 1]]

        elseif world[playerPosition[1], playerPosition[2] + 1] == '💦'
        
            POSITIONS[[playerPosition[1], playerPosition[2] + 1]] = '💦'
            HAVE_BREEZE = [[playerPosition[1], playerPosition[2] + 1]]
            HAVE_BREEZE = [[playerPosition[1], playerPosition[2] + 1]]
            HAVE_STINK = [[playerPosition[1], playerPosition[2] + 1]]

        elseif world[playerPosition[1], playerPosition[2] + 1] in COIN_EMOJIS
        
            POSITIONS[[playerPosition[1], playerPosition[2] + 1]] = '🟩'
            FOUND_GOLD = true;

        elseif world[playerPosition[1], playerPosition[2] + 1] in TRAPS

            world[playerPosition[1], playerPosition[2] + 1] = '🤠'
            world[playerPosition[1], playerPosition[2]] = POSITIONS[[playerPosition[1], playerPosition[2]]]
            println("!!! O caçador morreu :| !!!")
            return false;

        end

        world[playerPosition[1], playerPosition[2] + 1] = '🤠'
        world[playerPosition[1], playerPosition[2]] = POSITIONS[[playerPosition[1], playerPosition[2]]]


    end

    return true;
    
end

# Função para salvar os adjacentes de uma posição
function SaveAdjacents(position, direction)

    if position[1] > 1

        SAFE_POSITIONS = [[position[1] - 1, position[2]]]
        push!(direction, 'U')

    end

    if position[1] < 4

        SAFE_POSITIONS = [[position[1] + 1, position[2]]]
        push!(direction, 'D')

    end

    if position[2] > 1

        SAFE_POSITIONS = [[position[1], position[2] - 1]]
        push!(direction, 'L')

    end

    if position[2] < 4

        SAFE_POSITIONS = [[position[1], position[2] + 1]]
        push!(direction, 'R')

    end
    
end        

# Função para fazer as inferências
function MakeInference(world)

    direction = []
     
    hunter = Position('🤠', world)

    exploring = POSITIONS[[hunter[1], hunter[2]]]

    choice = 'M'

    if exploring == '🟩'

        #SAFE_POSITIONS = [[hunter]]
        SaveAdjacents(hunter, direction)

        choice = rand(direction)
        push!(CHOSEN_DIRECTION, choice)
        

    else

        #SaveAdjacents(hunter, direction)
        #deleteat!(direction, Position(last(CHOSEN_DIRECTION), direction)) 
        choice = pop!(CHOSEN_DIRECTION)

    end

    return choice
    
end


function Run()

    world = fill('🟩', 4, 4)
    world[1, 1] = '🤠'
    game = true

    CreateWumpus(world)

    CreateHoles(world)

    CreateHoles(world)

    CreateGold(world)

    PrintWorld(world)
    println(' ')

    while game

        println(POSITIONS)

        direction = MakeInference(world)

        if !(HunterMove(world, direction)) 

            PrintWorld(world)
            println(' ')
            
            break

        end

        #ClearConsole()
        PrintWorld(world)
        println(' ')

        if FOUND_GOLD 

            println("C:", CHOSEN_DIRECTION)

            while !isempty(CHOSEN_DIRECTION)
                
                aux = pop!(CHOSEN_DIRECTION)

                HunterMove(world, aux)

                PrintWorld(world)
                println(' ')    

            end

            Println("🎉 O caçador ganhou o jogo 🎉")

            game = false

        end
    

    end
    
end

Run()
