--variables
gravity = 0.15
friction = 0.85

--number of frames player can spend in the air and still be able to jump
max_coyote = 10
coyote_time = 0

--test
x1r = 0 
y1r = 0
x2r = 0
y2r = 0
col_l = "no"
col_r = "no"
col_u = "no"
col_d = "no"


function player_init(spawn_x, spawn_y)
    
    player = 
        {
            sp = 1,
            x = spawn_x,
            y = spawn_y,
            w = 8,
            h = 8,
            flip = false,
            dx = 0,
            dy = 0,
            max_dx = 2,
            max_dy = 3,
            acc = 0.5,
            boost = 2,
            ani = 0,
            running = false ,
            jumping = false ,
            sliding = false ,
            landed = false,
            bubble_size = 1
        }
end


k_left = 0
k_right = 1
k_up = 2
k_down = 3
k_x = 5
--player
function player_update()
    
    --physics
    player.dy += gravity
    player.dx *= friction 
    --controls
    if btn(k_left) then 
        if player.landed then
            sfx(12)
        end
        player.dx -= player.acc
        player.running = true
        player.flip = true
    end
    if btn(k_right) then
        if player.landed then
            sfx(12)
        end
        player.dx += player.acc
        player.running = true
        player.flip = false
    end
    --slide
    if player.running and
    not btn(k_left) and
    not btn(k_right) and
    not player.falling and 
    not player.jumping then
        player.running = false
        player.sliding = true
    end

    --jump 
    if btnp(k_x) and 
    player.landed then
        sfx(11)
        player.dy -= player.boost
        player.landed = false
    end

    --collision
    if player.dy > 0 then
        if coyote_time <= 0 then
            coyote_time = 10
        end
        player.falling = true
        player.jumping = false

        player.dy = limit_speed(player.dy, player.max_dy)
        if collide_map(player, "down", 0) then
            
            player.landed = true
           
            player.falling = false
            player.dy = 0
            player.y -= (player.y + player.h + 1) % 8 - 1 
        end 
    elseif player.dy < 0 then
        player.jumping = true
        if collide_map(player, "up", 1) then
            player.dy = 0
        end
    end

    --left & right
    if player.dx < 0 then
        player.dx = limit_speed(player.dx, player.max_dx)
        if collide_map(player, "left", 1) then
            player.dx = 0
        end
    end
    if player.dx > 0 then
        player.dx = limit_speed(player.dx, player.max_dx)
        if collide_map(player, "right", 1) then
            player.dx = 0
        end
    end

    --stop sliding 
    if player.sliding then
        if abs(player.dx) <.2
        or player.running then
            player.dx = 0
            player.sliding = false
        end
    end

    player.x += player.dx
    player.y += player.dy

     --coyote time
    if coyote_time > 0 then
       coyote_time -= 1
       if coyote_time <= 0 then
           player.landed = false
           coyote_time = 0
       end
    end

    player.bubble_size = radius * radius * 64
    --printh(player.bubble_size, "log.txt")
end
function player_animate()
    local shift = 48
    if player.jumping then
        player.sp = 7 + shift
    elseif player.falling then
        player.sp = 8 + shift
    elseif player.slide then 
        player.sp = 9 + shift
    elseif player.running then
        if time() - player.ani > .1 then
            player.ani = time()
            player.sp += 1
            if player.sp > 6 + shift then 
                player.sp = 3 + shift
            end
        end
    else --idle
        if time() - player.ani > .3 then 
            player.ani = time()
            player.sp += 1 
            if player.sp > 2 + shift then
                player.sp = 1 + shift 
            end
        end
    end
end

--update and draw
function draw_player()

    spr(player.sp, player.x, player.y, 1, 1, player.flip)

    --test--
    rect(x1r, y1r, x2r, y2r, 7)
    
end

--collisions
function collide_map(obj, dir, flag)
    local x = obj.x local y = obj.y
    local w = obj.w local h = obj.h
    local x1 = 0 local y1 = 0
    local x2 = 0 local y2 = 0
    if dir == "left" then
        x1 = x - 1 
        y1 = y
        x2 = x 
        y2 = y + h - 1 
    elseif dir == "right" then
        x1 = x + w - 1
        y1 = y
        x2 = x + w
        y2 = y + h - 1
    elseif dir == "up" then
        x1 = x + 2
        y1 = y - 1
        x2 = x + w - 3
        y2 = y
    elseif dir == "down" then
        x1 = x + 2
        y1 = y + h
        x2 = x + w - 3
        y2 = y + h 
    end
    --test--
    --[[x1r = x1 
    y1r = y1
    x2r = x2
    y2r = y2]]--

    x1 /= 8
    y1 /= 8
    x2 /= 8
    y2 /= 8
    if fget(mget(x1, y1), flag)
    or fget(mget(x1, y2), flag)
    or fget(mget(x2, y1), flag)
    or fget(mget(x2, y2), flag) then 
        return true
    else return false 
    end
end

--speed limit
function limit_speed(num, maximum)
    return mid(-maximum, num, maximum)
end