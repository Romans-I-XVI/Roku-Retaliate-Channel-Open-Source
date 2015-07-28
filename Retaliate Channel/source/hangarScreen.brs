Function HangarScreen(screen,port)

   'Set Variables
    selected_ship_timer = CreateObject("roTimeSpan")
    select_ship_multiplier = 0
    ships_start_x = 597
    ships_y = 280
    buttons_start_y = 225
    left_side_start_x = 210  '522 start have space 598
    black=&h000000FF
    white=&hffffffff
    Index = 0
    score = -1
    tilt_left = 0
    tilt_right = 0
    cursor_speed = 1
    ships = ["ship_1","ship_2","ship_3","ship_4","ship_5"]
    select_ship = ""
    deselect_ship = ""
    for a = 0 to ships.Count()-1
        if ships[a] = m.active_ship
            current_active_ship = a
            exit for
        end if
    end for
    active_ship_x = 695
    active_ship_y = 50
    left_pressed = false
    right_pressed = false
    next_tilt = "right"
    rnd_shield = 0
    rnd_shield_old = 0
    x_offset = 0
    y_offset = 0
    
    'Create Timers
    ship_tilt_timer = CreateObject("roTimeSpan")
    shield_animation_timer = CreateObject("roTimeSpan")
    pressed_timespan = CreateObject("roTimeSpan")
    
    'Create Bitmaps
    bm_double_arrow_right = CreateObject("roBitmap", "pkg:/sprites/spr_double_arrow_right.png")
    bm_double_arrow_left = CreateObject("roBitmap", "pkg:/sprites/spr_double_arrow_left.png")
    bm_ship_logo = {ship_1: CreateObject("roBitmap", "pkg:/sprites/spr_hangar_logo_ship_1.png"),ship_2: CreateObject("roBitmap", "pkg:/sprites/spr_hangar_logo_ship_2.png"),ship_3: CreateObject("roBitmap", "pkg:/sprites/spr_hangar_logo_ship_3.png"),ship_4: CreateObject("roBitmap", "pkg:/sprites/spr_hangar_logo_ship_4.png"),ship_5: CreateObject("roBitmap", "pkg:/sprites/spr_hangar_logo_ship_5.png")}
    bm_left_side_text = [CreateObject("roBitmap", "pkg:/sprites/spr_hangar_logo_body.png"),CreateObject("roBitmap", "pkg:/sprites/spr_hangar_logo_trim_0.png"),CreateObject("roBitmap", "pkg:/sprites/spr_hangar_logo_trim_1.png"),CreateObject("roBitmap", "pkg:/sprites/spr_hangar_logo_shield.png")]
    bm_bar= CreateObject("roBitmap", "pkg:/sprites/spr_bar.png") 
    bm_hue= CreateObject("roBitmap", "pkg:/sprites/spr_hue.png") 
    bm_sat= CreateObject("roBitmap", "pkg:/sprites/spr_sat.png")
    bm_sat_border= CreateObject("roBitmap", "pkg:/sprites/spr_sat_border.png") 
    bm_pointer_0= CreateObject("roBitmap", "pkg:/sprites/spr_pointer_0.png") 
    bm_pointer_1= CreateObject("roBitmap", "pkg:/sprites/spr_pointer_1.png") 
    bm_button_reset_0= CreateObject("roBitmap", "pkg:/sprites/spr_button_reset_0.png")
    bm_button_reset_1= CreateObject("roBitmap", "pkg:/sprites/spr_button_reset_1.png")
    bm_button_done_0= CreateObject("roBitmap", "pkg:/sprites/spr_button_done_0.png")
    bm_button_done_1= CreateObject("roBitmap", "pkg:/sprites/spr_button_done_1.png")
    bm_ship = {ship_1: {}
        ship_2: {}
        ship_3: {}
        ship_4: {}
        ship_5: {}
        }
    
    'Set Shield Bitmap
    bm_shield = []
    for a = 0 to 3
        for b = 0 to 3
            bm_shield.Push(CreateObject("roBitmap", "pkg:/sprites/shield/spr_shield_"+a.tostr()+"_"+b.tostr()+".png"))
        end for
    end for
    for each key in bm_ship
        bm_ship[key].top_1 = CreateObject("roBitmap", "pkg:/sprites/ships/spr_"+key+"_top_1.png") 
        bm_ship[key].top_2 = CreateObject("roBitmap", "pkg:/sprites/ships/spr_"+key+"_top_2.png")
        bm_ship[key].top_3 = CreateObject("roBitmap", "pkg:/sprites/ships/spr_"+key+"_top_3.png")
        bm_ship[key].left_1 = CreateObject("roBitmap", "pkg:/sprites/ships/spr_"+key+"_left_1.png") 
        bm_ship[key].left_2 = CreateObject("roBitmap", "pkg:/sprites/ships/spr_"+key+"_left_2.png")
        bm_ship[key].left_3 = CreateObject("roBitmap", "pkg:/sprites/ships/spr_"+key+"_left_3.png")
        bm_ship[key].right_1 = CreateObject("roBitmap", "pkg:/sprites/ships/spr_"+key+"_right_1.png") 
        bm_ship[key].right_2 = CreateObject("roBitmap", "pkg:/sprites/ships/spr_"+key+"_right_2.png")
        bm_ship[key].right_3 = CreateObject("roBitmap", "pkg:/sprites/ships/spr_"+key+"_right_3.png")
    end for
    
    'Create Sounds
    snd_move = CreateObject("roAudioResource", "navsingle")
    
    'Draw initial screen
    
    screen.Clear(black)
    screen.DrawObject(160,0,m.bm_background)
    screen.DrawRect(156,0,4,720,white)
    screen.DrawRect(1280-160,0,4,720,white)
    screen.swapbuffers()
    screen.Clear(black)
    screen.DrawObject(160,0,m.bm_background)
    screen.DrawRect(156,0,4,720,white)
    screen.DrawRect(1280-160,0,4,720,white)
    screen.swapbuffers()
    
    
    while (true)
        msg = wait(1, port) 
        if (type(msg) = "roUniversalControlEvent")
            'print "appRoScreen  index = "; msg.GetInt()
            code = msg.GetInt()
            if code = 0 'back pressed
                snd_move.Trigger(55)
                return -1
            else if code = 4 'left pressed
                if index < 8
                    left_pressed = true
                    pressed_timespan.Mark()
                else if index = 9
                    snd_move.Trigger(55)
                    index = 8
                end if
            else if code = 104 'left released
                left_pressed = false
                cursor_speed = 1
            else if code = 5 'right pressed
                if index < 8
                    right_pressed = true
                    pressed_timespan.Mark()
                else if index = 8
                    snd_move.Trigger(55)
                    index = 9
                end if
            else if code = 105 'right released
                right_pressed = false
                cursor_speed = 1
            else if code = 2 'up pressed
                if Index > 0
                    snd_move.Trigger(55)
                    if index = 9
                        index = index - 2
                    else 
                        index = index - 1
                    end if
                end if
            else if code = 3 'down pressed
                if Index < 8
                    snd_move.Trigger(55)
                    Index = Index + 1
                end if
            else if code = 6 'select pressed
                if Index = 8
                    return -1
                end if
                if Index = 9
                    m.ship_color[m.active_ship].part_1.hue = 0
                    m.ship_color[m.active_ship].part_1.sat = 0
                    m.ship_color[m.active_ship].part_1.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_1.hue,m.ship_color[m.active_ship].part_1.sat,100,255)
                    m.ship_color[m.active_ship].part_2.hue = 210
                    m.ship_color[m.active_ship].part_2.sat = 80
                    m.ship_color[m.active_ship].part_2.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_2.hue,m.ship_color[m.active_ship].part_2.sat,100,255)
                    m.ship_color[m.active_ship].part_3.hue = 0
                    m.ship_color[m.active_ship].part_3.sat = 80
                    m.ship_color[m.active_ship].part_3.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_3.hue,m.ship_color[m.active_ship].part_3.sat,100,255)
                    m.ship_color[m.active_ship].shield.hue = 220
                    m.ship_color[m.active_ship].shield.sat = 85
                    m.ship_color[m.active_ship].shield.hex = HSVAtoRGBA(m.ship_color[m.active_ship].shield.hue,m.ship_color[m.active_ship].shield.sat,100,255)
                end if
            else if code = 8 'rewind pressed
                if current_active_ship > 0
                    snd_move.Trigger(55)
                    current_active_ship = current_active_ship - 1
                    'm.active_ship = ships[current_active_ship]
                    selected_ship_timer.Mark()
                    select_ship = ships[current_active_ship]
                    deselect_ship = ships[current_active_ship+1]
                    
                end if  
            else if code = 9 'fast forward pressed
                if current_active_ship < 4
                    snd_move.Trigger(55)
                    selected_ship_timer.Mark()
                    current_active_ship = current_active_ship + 1
                    select_ship = ships[current_active_ship]
                    deselect_ship = ships[current_active_ship-1]
                end if
            
            end if
        end if
        
        
        if right_pressed
            timespan = pressed_timespan.TotalMilliseconds()
            if timespan > 200 
                cursor_speed = 1.5
            end if
            if timespan > 300
                cursor_speed = 2
            end if
            if timespan > 400
                cursor_speed = 2.5
            end if
            if timespan > 500
                cursor_speed = 3
            end if
            
            if index = 0 and m.ship_color[m.active_ship].part_1.hue < 360
                m.ship_color[m.active_ship].part_1.hue = m.ship_color[m.active_ship].part_1.hue + cursor_speed
                m.ship_color[m.active_ship].part_1.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_1.hue,m.ship_color[m.active_ship].part_1.sat,100,255)
            else if index = 1 and m.ship_color[m.active_ship].part_1.sat < 100
                m.ship_color[m.active_ship].part_1.sat = m.ship_color[m.active_ship].part_1.sat + 1
                m.ship_color[m.active_ship].part_1.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_1.hue,m.ship_color[m.active_ship].part_1.sat,100,255)
            else if index = 2 and m.ship_color[m.active_ship].part_2.hue < 360
                m.ship_color[m.active_ship].part_2.hue = m.ship_color[m.active_ship].part_2.hue + cursor_speed
                m.ship_color[m.active_ship].part_2.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_2.hue,m.ship_color[m.active_ship].part_2.sat,100,255)
            else if index = 3 and m.ship_color[m.active_ship].part_2.sat < 100
                m.ship_color[m.active_ship].part_2.sat = m.ship_color[m.active_ship].part_2.sat + 1
                m.ship_color[m.active_ship].part_2.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_2.hue,m.ship_color[m.active_ship].part_2.sat,100,255)
            else if index = 4 and m.ship_color[m.active_ship].part_3.hue < 360
                m.ship_color[m.active_ship].part_3.hue = m.ship_color[m.active_ship].part_3.hue + cursor_speed
                m.ship_color[m.active_ship].part_3.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_3.hue,m.ship_color[m.active_ship].part_3.sat,100,255)
            else if index = 5 and m.ship_color[m.active_ship].part_3.sat < 100
                m.ship_color[m.active_ship].part_3.sat = m.ship_color[m.active_ship].part_3.sat + 1
                m.ship_color[m.active_ship].part_3.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_3.hue,m.ship_color[m.active_ship].part_3.sat,100,255)
            else if index = 6 and m.ship_color[m.active_ship].shield.hue < 360
                m.ship_color[m.active_ship].shield.hue = m.ship_color[m.active_ship].shield.hue + cursor_speed
                m.ship_color[m.active_ship].shield.hex = HSVAtoRGBA(m.ship_color[m.active_ship].shield.hue,m.ship_color[m.active_ship].shield.sat,100,255)
            else if index = 7 and m.ship_color[m.active_ship].shield.sat < 100
                m.ship_color[m.active_ship].shield.sat = m.ship_color[m.active_ship].shield.sat + 1
                m.ship_color[m.active_ship].shield.hex = HSVAtoRGBA(m.ship_color[m.active_ship].shield.hue,m.ship_color[m.active_ship].shield.sat,100,255)
            end if
        
        end if
        if left_pressed
            timespan = pressed_timespan.TotalMilliseconds()
            if timespan > 200 
                cursor_speed = 1.5
            end if
            if timespan > 300
                cursor_speed = 2
            end if
            if timespan > 400
                cursor_speed = 2.5
            end if
            if timespan > 500
                cursor_speed = 3
            end if
        
            if index = 0 and m.ship_color[m.active_ship].part_1.hue > 0
                m.ship_color[m.active_ship].part_1.hue = m.ship_color[m.active_ship].part_1.hue - cursor_speed
                m.ship_color[m.active_ship].part_1.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_1.hue,m.ship_color[m.active_ship].part_1.sat,100,255)
            else if index = 1 and m.ship_color[m.active_ship].part_1.sat > 0
                m.ship_color[m.active_ship].part_1.sat = m.ship_color[m.active_ship].part_1.sat - 1
                m.ship_color[m.active_ship].part_1.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_1.hue,m.ship_color[m.active_ship].part_1.sat,100,255)
            else if index = 2 and m.ship_color[m.active_ship].part_2.hue > 0
                m.ship_color[m.active_ship].part_2.hue = m.ship_color[m.active_ship].part_2.hue - cursor_speed
                m.ship_color[m.active_ship].part_2.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_2.hue,m.ship_color[m.active_ship].part_2.sat,100,255)
            else if index = 3 and m.ship_color[m.active_ship].part_2.sat > 0
                m.ship_color[m.active_ship].part_2.sat = m.ship_color[m.active_ship].part_2.sat - 1
                m.ship_color[m.active_ship].part_2.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_2.hue,m.ship_color[m.active_ship].part_2.sat,100,255)
            else if index = 4 and m.ship_color[m.active_ship].part_3.hue > 0
                m.ship_color[m.active_ship].part_3.hue = m.ship_color[m.active_ship].part_3.hue - cursor_speed
                m.ship_color[m.active_ship].part_3.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_3.hue,m.ship_color[m.active_ship].part_3.sat,100,255)
            else if index = 5 and m.ship_color[m.active_ship].part_3.sat > 0
                m.ship_color[m.active_ship].part_3.sat = m.ship_color[m.active_ship].part_3.sat - 1
                m.ship_color[m.active_ship].part_3.hex = HSVAtoRGBA(m.ship_color[m.active_ship].part_3.hue,m.ship_color[m.active_ship].part_3.sat,100,255)
            else if index = 6 and m.ship_color[m.active_ship].shield.hue > 0
                m.ship_color[m.active_ship].shield.hue = m.ship_color[m.active_ship].shield.hue - cursor_speed
                m.ship_color[m.active_ship].shield.hex = HSVAtoRGBA(m.ship_color[m.active_ship].shield.hue,m.ship_color[m.active_ship].shield.sat,100,255)
            else if index = 7 and m.ship_color[m.active_ship].shield.sat > 0
                m.ship_color[m.active_ship].shield.sat = m.ship_color[m.active_ship].shield.sat - 1
                m.ship_color[m.active_ship].shield.hex = HSVAtoRGBA(m.ship_color[m.active_ship].shield.hue,m.ship_color[m.active_ship].shield.sat,100,255)
            end if
        
        end if
        
        
        
        
        'Draw Screen
        screen.Clear(black)
        
        screen.DrawObject(160,0,m.bm_background) 
        screen.DrawRect(156,0,4,720,white)
        screen.DrawRect(1280-160,0,4,720,white)
           
        for a = 0 to 3
            screen.DrawObject(210,25+(140*a),bm_left_side_text[a])
            screen.DrawObject(210,55+(140*a),bm_hue)
            screen.DrawObject(210,115+(140*a),bm_sat_border)
        end for  
        
        
        screen.DrawObject((active_ship_x + 120) +  - 110 - 64,active_ship_y + 100,bm_double_arrow_left)
        screen.DrawObject((active_ship_x + 120) + 110, active_ship_y + 100,bm_double_arrow_right)
        screen.DrawObject(210,115,bm_sat, m.ship_color[m.active_ship].part_1.hex)
        screen.DrawObject(210,115+(140*1),bm_sat, m.ship_color[m.active_ship].part_2.hex)
        screen.DrawObject(210,115+(140*2),bm_sat, m.ship_color[m.active_ship].part_3.hex)
        screen.DrawObject(210,115+(140*3),bm_sat, m.ship_color[m.active_ship].shield.hex)
        
        'Draw Ship
        if ship_tilt_timer.TotalMilliseconds() > 1000
            ship_tilt_timer.Mark()
            if tilt_left = 1
                next_tilt = "right"
                tilt_left = 0
            else if tilt_right = 1 
                next_tilt = "left"
                tilt_right = 0
            else 
                if next_tilt = "right"
                    tilt_right = 1
                else
                    tilt_left = 1
                end if
            end if
          
        end if
        x = -80
        for each key in ships
            x = x + 80
            if key = select_ship
                newx = Linear_Tween(ships_start_x+x, active_ship_x, selected_ship_timer.TotalMilliseconds(), 300)
                newy = Linear_Tween(ships_y, active_ship_y, selected_ship_timer.TotalMilliseconds(), 300)
                newscale = Linear_Tween(1.0, 2.0, selected_ship_timer.TotalMilliseconds(), 300)
                screen.DrawScaledObject(newx, newy, newscale, newscale, bm_ship[key].top_1, m.ship_color[key].part_1.hex)
                screen.DrawScaledObject(newx, newy, newscale, newscale, bm_ship[key].top_2, m.ship_color[key].part_2.hex)
                screen.DrawScaledObject(newx, newy, newscale, newscale, bm_ship[key].top_3, m.ship_color[key].part_3.hex)
                if newy = active_ship_y
                    m.active_ship = key
                    select_ship = ""
                    deselect_ship = ""
                    select_ship_multiplier = 0
                end if
            else if key = deselect_ship
                newx = Linear_Tween(active_ship_x, ships_start_x+x,  selected_ship_timer.TotalMilliseconds(), 300)
                newy = Linear_Tween(active_ship_y, ships_y, selected_ship_timer.TotalMilliseconds(), 300)
                newscale = Linear_Tween(2.0, 1.0, selected_ship_timer.TotalMilliseconds(), 300)
                screen.DrawScaledObject(newx, newy, newscale, newscale, bm_ship[key].top_1, m.ship_color[key].part_1.hex)
                screen.DrawScaledObject(newx, newy, newscale, newscale, bm_ship[key].top_2, m.ship_color[key].part_2.hex)
                screen.DrawScaledObject(newx, newy, newscale, newscale, bm_ship[key].top_3, m.ship_color[key].part_3.hex)
            else if key <> m.active_ship 
                screen.DrawObject(ships_start_x+x, ships_y, bm_ship[key].top_1, m.ship_color[key].part_1.hex)
                screen.DrawObject(ships_start_x+x, ships_y, bm_ship[key].top_2, m.ship_color[key].part_2.hex)
                screen.DrawObject(ships_start_x+x, ships_y, bm_ship[key].top_3, m.ship_color[key].part_3.hex)
            else if key = m.active_ship and select_ship <> ""
                screen.DrawObject(ships_start_x+x, ships_y, bm_ship[key].top_1, m.ship_color[key].part_1.hex)
                screen.DrawObject(ships_start_x+x, ships_y, bm_ship[key].top_2, m.ship_color[key].part_2.hex)
                screen.DrawObject(ships_start_x+x, ships_y, bm_ship[key].top_3, m.ship_color[key].part_3.hex)
            end if
        end for
        
        if select_ship = ""
            screen.DrawObject(1280-160-590,active_ship_y - 28, bm_ship_logo[m.active_ship])
            if tilt_left = 1
                screen.DrawScaledObject(active_ship_x, active_ship_y, 2.0, 2.0, bm_ship[m.active_ship].left_1, m.ship_color[m.active_ship].part_1.hex)
                screen.DrawScaledObject(active_ship_x, active_ship_y, 2.0, 2.0, bm_ship[m.active_ship].left_2, m.ship_color[m.active_ship].part_2.hex)
                screen.DrawScaledObject(active_ship_x, active_ship_y, 2.0, 2.0, bm_ship[m.active_ship].left_3, m.ship_color[m.active_ship].part_3.hex)
            end if
            if tilt_right = 1
                screen.DrawScaledObject(active_ship_x, active_ship_y, 2.0, 2.0, bm_ship[m.active_ship].right_1, m.ship_color[m.active_ship].part_1.hex)
                screen.DrawScaledObject(active_ship_x, active_ship_y, 2.0, 2.0, bm_ship[m.active_ship].right_2, m.ship_color[m.active_ship].part_2.hex)
                screen.DrawScaledObject(active_ship_x, active_ship_y, 2.0, 2.0, bm_ship[m.active_ship].right_3, m.ship_color[m.active_ship].part_3.hex)            
            end if
            if tilt_left = 0 and tilt_right = 0
                screen.DrawScaledObject(active_ship_x, active_ship_y, 2.0, 2.0, bm_ship[m.active_ship].top_1, m.ship_color[m.active_ship].part_1.hex)
                screen.DrawScaledObject(active_ship_x, active_ship_y, 2.0, 2.0, bm_ship[m.active_ship].top_2, m.ship_color[m.active_ship].part_2.hex)
                screen.DrawScaledObject(active_ship_x, active_ship_y, 2.0, 2.0, bm_ship[m.active_ship].top_3, m.ship_color[m.active_ship].part_3.hex)
            end if
        end if
        
        if shield_animation_timer.TotalMilliseconds() > 50
            rnd_shield_old = rnd_shield
            shield_animation_timer.Mark()
            set_shield_animation:
            rnd_shield = cint(rnd(16)-1)
            if rnd_shield = rnd_shield_old
                goto set_shield_animation
            end if
        end if
        screen.DrawScaledObject(active_ship_x-31, active_ship_y+350, 2.0, 2.0, bm_shield[rnd_shield], m.ship_color[m.active_ship].shield.hex)
        
        
        'Draw Pointers
        if index = 0
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].part_1.hue/360)*312,55+(140*0),bm_pointer_1)
        else 
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].part_1.hue/360)*312,55+(140*0),bm_pointer_0)
        end if
        if index = 1
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].part_1.sat/100)*312,115+(140*0),bm_pointer_1)
        else
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].part_1.sat/100)*312,115+(140*0),bm_pointer_0)
        end if
        if index = 2
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].part_2.hue/360)*312,55+(140*1),bm_pointer_1)
        else
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].part_2.hue/360)*312,55+(140*1),bm_pointer_0)
        end if
        if index = 3
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].part_2.sat/100)*312,115+(140*1),bm_pointer_1)
        else 
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].part_2.sat/100)*312,115+(140*1),bm_pointer_0)
        end if
        if index = 4 
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].part_3.hue/360)*312,55+(140*2),bm_pointer_1)
        else 
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].part_3.hue/360)*312,55+(140*2),bm_pointer_0)
        end if
        if  index = 5
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].part_3.sat/100)*312,115+(140*2),bm_pointer_1)
        else 
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].part_3.sat/100)*312,115+(140*2),bm_pointer_0)
        end if
        if  index = 6
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].shield.hue/360)*312,55+(140*3),bm_pointer_1)
        else 
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].shield.hue/360)*312,55+(140*3),bm_pointer_0)
        end if
        if  index = 7
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].shield.sat/100)*312,115+(140*3),bm_pointer_1)
        else 
            screen.DrawObject(left_side_start_x-24+(m.ship_color[m.active_ship].shield.sat/100)*312,115+(140*3),bm_pointer_0)
        end if
        if index = 8
            screen.DrawObject(232-100,585,bm_button_done_1)
        else
            screen.DrawObject(232-100,585,bm_button_done_0)        
        end if
        if index = 9
            screen.DrawObject(232+100,585,bm_button_reset_1)
        else
            screen.DrawObject(232+100,585,bm_button_reset_0)        
        end if
        
        screen.swapbuffers()
    end while

End Function