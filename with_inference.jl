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
COIN_EMOJIS = ['💵', '💶', '💴', '💷', '💸', '💰']
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

    if world[direction[1], direction[2]] == '🟩'
        
        POSITIONS[[direction[1], direction[2]]] = '🟩'
        
    elseif world[direction[1], direction[2]] == '💨'
    
        POSITIONS[[direction[1], direction[2]]] = '💨'

    elseif world[direction[1], direction[2]] == '💩'
    
        POSITIONS[[direction[1], direction[2]]] = '💩'

    elseif world[direction[1], direction[2]] == '👃'
        
        POSITIONS[[direction[1], direction[2]]] = '👃'
        
    elseif world[direction[1], direction[2]] == '🌀'
    
        POSITIONS[[direction[1], direction[2]]] = '🌀'

    elseif world[direction[1], direction[2]] == '💦'
    
        POSITIONS[[direction[1], direction[2]]] = '💦'

    elseif world[direction[1], direction[2]] in COIN_EMOJIS

        POSITIONS[[direction[1], direction[2]]] = '🟢'

    elseif world[direction[1], direction[2]] in TRAPS

        world[direction[1], direction[2]] = '🤠'
        world[playerPosition[1], playerPosition[2]] = POSITIONS[[playerPosition[1], playerPosition[2]]]
        println("!!! 🪦 O caçador morreu 🪦 !!!")
        return false;

    end

    world[direction[1], direction[2]] = '🤠'
    world[playerPosition[1], playerPosition[2]] = POSITIONS[[playerPosition[1], playerPosition[2]]]

    return true;
    
end

# Função para salvar os adjacentes de uma posição
function SaveAdjacents(position, direction)

    if position[1] > 1

        push!(direction, [[position[1] - 1, position[2]]])

    end

    if position[1] < 4

        push!(direction, [[position[1] + 1, position[2]]])

    end

    if position[2] > 1

        push!(direction, [[position[1], position[2] - 1]])

    end

    if position[2] < 4

        push!(direction, [[position[1], position[2] + 1]])

    end
    
end        

# Função para fazer as inferências
function MakeInference(world)

    global FOUND_GOLD

    direction = []

    hunter = Position('🤠', world)

    exploring = POSITIONS[[hunter[1], hunter[2]]]

    choice = []

    if exploring == '🟩'

        SaveAdjacents(hunter, direction)

        choices = rand(direction)
        choice = [choices[1][1], choices[1][2]]

        push!(SAFE_POSITIONS, [hunter[1], hunter[2]])
        vcat(SAFE_POSITIONS, direction)

        push!(CHOSEN_DIRECTION,[hunter[1], hunter[2]])
    
    elseif exploring == '💨'

        SaveAdjacents(hunter, direction)

        println([CHOSEN_DIRECTION[end]])
        println(direction)

        index = Position([CHOSEN_DIRECTION[end]], direction)
        deleteat!(direction, index)
        push!(HAVE_BREEZE, [hunter[1], hunter[2]])
        vcat(HAVE_HOLES, direction)
        
        choice = CHOSEN_DIRECTION[end]

    elseif  exploring == '🌀'

        holes = []

        SaveAdjacents(hunter, direction)

        println([CHOSEN_DIRECTION[end]])
        println(direction)

        index = Position([CHOSEN_DIRECTION[end]], direction)
        deleteat!(direction, index)
        push!(HAVE_BREEZE, [hunter[1], hunter[2]])

        if length(direction) == 2

            empty!(HAVE_HOLES)

            println("Buracos nas posições: ", direction)

            SaveAdjacents(direction[1], holes)
            vcat(SAFE_POSITIONS, holes)

            SaveAdjacents(direction[2], holes)
            vcat(SAFE_POSITIONS, holes)

        end

        vcat(HAVE_HOLES, direction)

        choice = CHOSEN_DIRECTION[end]
        
    elseif exploring == '🟢'

        println("✨ O caçador encontrou o tesouro ✨")
        #choice = pop!(CHOSEN_DIRECTION)
        FOUND_GOLD = true

    elseif length(CHOSEN_DIRECTION) > 0 

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

    game = 0

    while game < 20

        direction = MakeInference(world)

        if !FOUND_GOLD

            if !(HunterMove(world, (direction[1], direction[2])))

                PrintWorld(world)
                println(' ')
                
                break

            end

        else

            while !isempty(CHOSEN_DIRECTION)
                
                aux = pop!(CHOSEN_DIRECTION)

                HunterMove(world, aux)

                PrintWorld(world)
                println(' ')    

                if aux[1] == 1 && aux[2] == 1

                    println("🎉 O caçador ganhou o jogo 🎉")

                    FOUND_GOLD = false
                    game = 30
                    break
                    
                end

            end

        end

        PrintWorld(world)
        println(' ') 

        game += 1

    end
    
end

Run()
