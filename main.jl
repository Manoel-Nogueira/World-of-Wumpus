#= Notação do mundo de wumpus:

    Wumpus; Ö 🐻
    Brisa: ≋ 🌫️ 💨
    Fedor; § ♨️ 💩
    Heroi; Ÿ 🤠
    Vazio / Terreno: # 🟩
    Ouro; ©
    Buraco: O


=#

coordinates = [                 [1, 3], [1, 4],
                        [2, 2], [2, 3], [2, 4],
                [3, 1], [3, 2], [3, 3], [3, 4],
                [4, 1], [4, 2], [4, 3], [4, 4],
            ]

# Função para imprimir o mundo
function PrintWorld(world)

    for row in eachrow(world)
        
        println(join(row, "")) 

    end

end

# Função para sortear um número entre 1 e 4
function DrawLots() 

    drawn = rand(coordinates)

    splice!(coordinates, searchsortedfirst(coordinates, drawn))

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

    if drawn[1] > 1

        if world[drawn[1] - 1, drawn[2]]  != '🐻' && world[drawn[1] - 1, drawn[2]] != '🌌'

            world[drawn[1] - 1, drawn[2]] = '💨'

        end
    
    end

    if drawn[1] < 4

        if world[drawn[1] + 1, drawn[2]]  != '🐻' && world[drawn[1] + 1, drawn[2]] != '🌌'

            world[drawn[1] + 1, drawn[2]] = '💨'

        end
    
    end

    if drawn[2] > 1 

        if world[drawn[1], drawn[2] - 1] != '🐻' && world[drawn[1], drawn[2] - 1] != '🌌' 
 
            world[drawn[1], drawn[2] - 1] = '💨'

        end
    
    end


    if drawn[2] < 4

        if  world[drawn[1], drawn[2] + 1] != '🐻' && world[drawn[1], drawn[2] + 1] != '🌌'

            world[drawn[1], drawn[2] + 1] = '💨'

        end
    
    end
    
end

# Função para criar o ouro
function CreateGold(world)

    drawn = DrawLots()

    world[drawn[1], drawn[2]] = '💰'

    
end


function Run()

    world = fill('🟩', 4, 4)
    world[1, 1] = '🤠'

    CreateWumpus(world)

    CreateHoles(world)

    CreateHoles(world)

    CreateGold(world)

    PrintWorld(world)
    
end

Run()
