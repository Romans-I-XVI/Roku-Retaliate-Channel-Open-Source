Function Start(screen,port,difficulty,sounds) 
    'print "Difficulty = : " ; difficulty
    di = CreateObject("roDeviceInfo")
    this = {
        'set general variables
        timer: CreateObject("roTimeSpan")
        background_timer: CreateObject("roTimeSpan")
        ship_timer: CreateObject("roTimeSpan")
        registry: CreateObject("roRegistrySection", "music")
        audioplayer: CreateObject("roAudioPlayer")
        background_music: CreateObject("roAssociativeArray")
        compositor: CreateObject("roCompositor")
        font_registry: CreateObject("roFontRegistry")
        font: ""
        port: port
        screen: screen
        white: &hFFFFFFFF
        black: &h000000FF 
        blue: &h0000FFFF
        difficulty: difficulty
        enemy_1_speed: 4500-(725*difficulty)
        enemy_2_speed: 800/((difficulty+1)*4)
        enemy_1_spawn: 240/((difficulty+1)*2) 
        enemy_bullet_speed: 2200-(300*difficulty)
        background_speed: 5800-(1160*difficulty)
        shield_life: 100
        move_speed: 8
        score: 0
        ammo: 0
        death_timer: 0 
        ship_y: 576
        paused_time_background: 0 
        paused_time_ship: 0
        background_y: 0
        background_old_y: 0
        ship_x: 0
        ship_old_x: 0
        audio_channel: 0
        display_mode: di.GetDisplayType()
        
        'set functions
        CreateEnemy1: create_enemy_1
        CreateEnemy2: create_enemy_2
        MoveBullet: move_bullet
        MoveEnemyBullet: move_enemy_bullet
        MoveEnemy1: move_enemy_1
        CheckEnemy1: check_enemy_1
        CheckEnemy2: check_enemy_2
        CheckEnemyBulletCollision: check_enemy_bullet_collision
        MoveLeft: move_left
        MoveRight: move_right
        Shield: shield
        CreateExplosions: create_explosions
        CreatePlayerExplosion: create_player_explosion
        CreateUI: create_ui
        CreateEnemyBullet: create_enemy_bullet
        BulletSpam: bullet_spam
        ScriptWedge: script_wedge
        ScriptWedge2: script_wedge_2
        ScriptWaves: script_waves
        ScriptFrown: script_frown
        ScriptBulletHell:script_bullet_hell
        ScriptedActions: select_scripted_action
        MoveBackground: move_background
        ShipMoveSpeed: ship_move_speed
        SwapAudioChannel: swap_audio_channel
        LinearTween: linear_tween
        
        'set game variables
        down_pressed: 0
        moving_left: 0
        moving_right: 0
        shield_on: 0 
        timer_enemy_1: 0
        timer_enemy_2: 0
        timer_bullet_spam: 0
        timer_hell_spam: 0
        random_number_1: 50+rnd(350)
        random_number_2: 50+rnd(350)
        random_number_3: 200+rnd(1200)
        random_number_4: 1000+rnd(2000)
        hell_interval: 5
        spamming: 0
        hell_spam: 0 
        bullet_id: 0
        enemy_bullet_id: 0
        explosion_positions: []
        player_explosion_position: 0
        dead: 0
        paused: false
        timer_scripts: 0
        timer_script: 0
        run_script: [false,false,false,false]
        spawn_enemies: true
        clear_enemy_2: false
        script_wedge_count: 0
        script_wedge_count_2: 7
        script_frown_count: 5
        hell_alternate: 1
        
        'Set Optimization Variables
        spr_ship_x: 610
        
        'create sprites
        spr_ship: ""
        spr_shield: ""
        spr_bullet: []
        spr_enemy_bullet: []
        spr_enemy_1: []
        spr_enemy_2: []
        spr_background: ""
        spr_border_1: ""
        spr_border_2: ""
        
        'create bitmaps
        bm_ship_top: CreateObject("roBitmap", "pkg:/sprites/spr_ship_top.png") 
        bm_ship_left: CreateObject("roBitmap", "pkg:/sprites/spr_ship_left.png")
        bm_ship_right: CreateObject("roBitmap", "pkg:/sprites/spr_ship_right.png")
        bm_bullet: CreateObject("roBitmap", "pkg:/sprites/spr_bullet.png")  
        bm_enemy_bullet: CreateObject("roBitmap", "pkg:/sprites/spr_enemy_bullet.png")  
        bm_shield: CreateObject("roBitmap", "pkg:/sprites/spr_shield.png")
        bm_enemy_1: CreateObject("roBitmap", "pkg:/sprites/spr_enemy_1.png")
        bm_enemy_2: CreateObject("roBitmap", "pkg:/sprites/spr_enemy_2.png")
        bm_background: CreateObject("roBitmap", "pkg:/sprites/spr_background.png")
        bm_border: CreateObject("roBitmap", "pkg:/sprites/spr_line.png")
        bm_explosion: [ CreateObject("roBitmap", "pkg:/sprites/spr_explosion_0.png"),
            CreateObject("roBitmap", "pkg:/sprites/spr_explosion_1.png"),
            CreateObject("roBitmap", "pkg:/sprites/spr_explosion_2.png"),
            CreateObject("roBitmap", "pkg:/sprites/spr_explosion_3.png"),
            CreateObject("roBitmap", "pkg:/sprites/spr_explosion_4.png"),
            CreateObject("roBitmap", "pkg:/sprites/spr_explosion_5.png")
            ]
        bm_player_explosion: [ CreateObject("roBitmap", "pkg:/sprites/spr_playerexplosion_0.png"),
            CreateObject("roBitmap", "pkg:/sprites/spr_playerexplosion_1.png"),
            CreateObject("roBitmap", "pkg:/sprites/spr_playerexplosion_2.png"),
            CreateObject("roBitmap", "pkg:/sprites/spr_playerexplosion_3.png"),
            CreateObject("roBitmap", "pkg:/sprites/spr_playerexplosion_4.png"),
            CreateObject("roBitmap", "pkg:/sprites/spr_playerexplosion_5.png")
            CreateObject("roBitmap", "pkg:/sprites/spr_playerexplosion_6.png")
            ]
            
        'create sounds
        snd_enemy_explosion: sounds.snd_enemy_explosion
        snd_player_explosion: sounds.snd_player_explosion
        snd_absorb: sounds.snd_absorb
        
        
        'initialize regions
        region_ship_top: ""
        region_ship_left: ""
        region_ship_right: ""
        region_bullet: ""
        region_shield: ""
        region_enemy_1: ""
        region_bullet_2: ""
        region_background: ""
        region_border: ""
        
        }
    'Start Music
    this.background_music.url = "tmp:/snd_background_music.wma"
    this.audioplayer.addcontent(this.background_music)
    this.audioplayer.setloop(true)
    this.audioplayer.play()
    
    'Set Regions
    this.font = this.font_registry.GetDefaultFont(this.font_registry.GetDefaultFontSize(), true, false)
    this.region_ship_top = CreateObject("roRegion", this.bm_ship_top, 0, 0, 68, 89) 
    this.region_ship_left = CreateObject("roRegion", this.bm_ship_left, 0, 0, 68, 89) 
    this.region_ship_right = CreateObject("roRegion", this.bm_ship_right, 0, 0, 68, 89) 
    this.region_bullet = CreateObject("roRegion", this.bm_bullet, 0, 0, 9, 22)
    this.region_enemy_bullet = CreateObject("roRegion", this.bm_enemy_bullet, 0, 0, 9, 22)
    this.region_shield = CreateObject("roRegion", this.bm_shield, 0, 0, 130, 130)
    this.region_enemy_1 = CreateObject("roRegion", this.bm_enemy_1, 0, 0, 54, 67)
    this.region_enemy_2 = CreateObject("roRegion", this.bm_enemy_2, 0, 0, 59, 89)
    this.region_border = CreateObject("roRegion", this.bm_border, 0, 0, 4, 720)
    this.region_background = CreateObject("roRegion", this.bm_background, 0, 0, 960, 720)
    this.region_background.SetWrap(true)
    
    'Setup Screen    
    this.screen.SetMessagePort(this.port)
    this.compositor.SetDrawTo(this.screen, 0) 
    this.screen.SetAlphaEnable(true)
    
    'Draw Initial Screen
    this.spr_background = this.compositor.NewSprite(160, 0, this.region_background)
    this.spr_ship = this.compositor.NewSprite(610, this.ship_y, this.region_ship_top)
    this.spr_shield = this.compositor.NewSprite(-200, -200, this.region_shield)
    this.spr_border_1 = this.compositor.NewSprite(156, 0, this.region_border)
    this.spr_border_2 = this.compositor.NewSprite(1120, 0, this.region_border)
    this.spr_ship.SetData(-1)
    this.spr_shield.SetData(-2)
    this.spr_ship.MoveTo(610,this.ship_y)
    this.compositor.DrawAll()
    this.screen.swapbuffers()

    while (true)
        msg = this.port.GetMessage() 
        if (type(msg) = "roUniversalControlEvent")
            'print "appRoScreen  index = "; msg.GetInt()
            code = msg.GetInt()
            if code = 0 'back pressed 
                results = {score: -1}
                return results
            else if code = 4 'left pressed
                if this.dead = 0 and this.paused = false
                curPos = this.spr_ship.GetX()
                this.spr_ship.Remove()
                this.spr_ship = this.compositor.NewSprite(curPos, this.ship_y, this.region_ship_left)
                this.spr_ship.SetData(-1)
                this.moving_left = 1
                end if
            else if code = 104 'left released
                if this.dead = 0 and this.paused = false
                curPos = this.spr_ship.GetX()
                this.spr_ship.Remove()
                this.spr_ship = this.compositor.NewSprite(curPos, this.ship_y, this.region_ship_top)
                this.spr_ship.SetData(-1)
                this.moving_left = 0
                end if
            else if code = 5 'right pressed
                if this.dead = 0 and this.paused = false
                curPos = this.spr_ship.GetX()
                this.spr_ship.Remove()
                this.spr_ship = this.compositor.NewSprite(curPos, this.ship_y, this.region_ship_right)
                this.spr_ship.SetData(-1)
                this.moving_right = 1
                end if
            else if code = 105 'right released
                if this.dead = 0 and this.paused = false
                curPos = this.spr_ship.GetX()
                this.spr_ship.Remove()
                this.spr_ship = this.compositor.NewSprite(curPos, this.ship_y, this.region_ship_top)
                this.spr_ship.SetData(-1)
                this.moving_right = 0
                end if
            else if code = 2 'up pressed
                if this.dead = 0 and this.paused = false
                    if this.ammo > 0
                        this.bullet_id = this.bullet_id + 1
                        this.ammo = this.ammo - 1
                        this.spr_bullet.Push(this.compositor.NewSprite(this.spr_ship.GetX()+29 , 610, this.region_bullet))
                        this.spr_bullet[(this.spr_bullet.Count()-1)].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0, id: this.bullet_id})
                    end if
                end if
            else if code = 3 'down pressed
                if this.dead = 0 and this.paused = false
                    this.shield_on = 1
                    this.down_pressed = 1
                end if
            else if code = 103 'down released
                if this.dead = 0 and this.paused = false
                    this.shield_on = 0
                    this.down_pressed = 0
                end if
            else if code = 13 'play/pause pressed
                if this.paused = false
                    this.paused = true
                    this.screen.DrawText("Paused",640-(this.font.GetOneLineWidth("Paused",1000)/2),340,this.white,this.font)
                    this.screen.swapbuffers()
                    this.audioplayer.Pause()
                    this.timer.Mark()
                else 
                    this.paused = false
                    this.audioplayer.Resume()
                    for each item in this.spr_enemy_1
                        data = item.GetData()
                        item.SetData({timer: data.timer,paused_time: data.paused_time+this.timer.TotalMilliseconds()})
                    end for
                    for each item in this.spr_enemy_2
                        data = item.GetData()
                        item.SetData({timer: data.timer, paused_time: data.paused_time+this.timer.TotalMilliseconds(),time_without_movement: data.time_without_movement,random_fire: data.random_fire, bullet_timer: data.bullet_timer, stopped: data.stopped})
                    end for
                    for each item in this.spr_enemy_bullet
                        data = item.GetData()
                        item.SetData({timer: data.timer,paused_time: data.paused_time+this.timer.TotalMilliseconds()})
                    end for
                    for each item in this.spr_bullet
                        data = item.GetData()
                        item.SetData({timer: data.timer,paused_time: data.paused_time+this.timer.TotalMilliseconds(), id: data.id})
                    end for
                    this.paused_time_background = this.paused_time_background + this.timer.TotalMilliseconds()
                    this.paused_time_ship = this.paused_time_ship + this.timer.TotalMilliseconds()
                end if
            end if    
        end if 
        if this.paused = false
            this.spr_ship_x = this.spr_ship.GetX()
            this.timer.Mark()
            this.MoveBackground()
            this.ShipMoveSpeed()
            this.ScriptedActions()
            if this.spawn_enemies = true
                this.CreateEnemy1()
                this.CreateEnemy2()
            end if
            if this.spawn_enemies = false
                if this.run_script[0] = true
                    this.ScriptWedge()
                else if this.run_script[1] = true
                    this.ScriptWedge2()
                else if this.run_script[2] = true
                    this.ScriptWaves()
                else if this.run_script[3] = true
                    this.ScriptBulletHell()
                else if this.run_script[4] = true
                    this.ScriptFrown()
                end if
            end if
            this.BulletSpam()
            this.MoveBullet() 
            this.MoveEnemyBullet()
            this.MoveEnemy1()
            this.CheckEnemy1()
            this.CheckEnemy2()
            this.CheckEnemyBulletCollision()
            this.MoveLeft()
            this.MoveRight()
            this.Shield()
            this.compositor.DrawAll()
            if this.dead = 1
                this.CreatePlayerExplosion()
                this.death_timer = this.death_timer + 1
                if this.death_timer = 120
                        
                    results = {score: this.score
                               table: ""
                               difficulty: difficulty
                               }
                    
                    if difficulty = 0  
                        results.table = "Highscores_Easy"
                    else if difficulty = 1
                        results.table = "Highscores_Normal"
                    else if difficulty = 2
                        results.table = "Highscores_Hard"
                    else if difficulty = 3
                        results.table = "Highscores_Extreme"
                    end if
                              
                    return results
                end if
            end if
            this.CreateExplosions()
            this.CreateUI()
            this.screen.swapbuffers()  
        end if
    end while
End Function

'Randomly create instances of Enemy 1
Function create_enemy_1()
    m.timer_enemy_1 = m.timer_enemy_1+1
    if m.timer_enemy_1 = m.random_number_1
        m.timer_enemy_1 = 0
        m.random_number_1 = 10+rnd(m.enemy_1_spawn)
        m.spr_enemy_1.Push(m.compositor.NewSprite(160+rnd(906) , -70, m.region_enemy_1))
        m.spr_enemy_1[m.spr_enemy_1.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0})   
        'Print "Creating new sprite 'Enemy 1' "
    end if
End Function

'Randomly create instances of Enemy 2
Function create_enemy_2()
    m.timer_enemy_2 = m.timer_enemy_2+1
    if m.timer_enemy_2 = m.random_number_2
        m.timer_enemy_2 = 0
        m.random_number_2 = 200+rnd(500)
        if m.spr_enemy_2.Count() < 5
            switch_position:
            enemy_2_rnd_pos = 240+((rnd(5)-1)*180)
            for each item in m.spr_enemy_2
                if enemy_2_rnd_pos = item.GetX()
                    'print "generating new position"
                    goto switch_position
                end if
            end for
            m.spr_enemy_2.Push(m.compositor.NewSprite(enemy_2_rnd_pos, -100, m.region_enemy_2))
            m.spr_enemy_2[m.spr_enemy_2.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0,time_without_movement: 0,random_fire: 200+rnd(m.enemy_2_speed), bullet_timer: 0, stopped: false})
            'Print "Creating new sprite 'Enemy 2' "
        end if
    end if
End Function


'Execute bullet spam script
Function bullet_spam()
    m.timer_bullet_spam = m.timer_bullet_spam+1
    if m.timer_bullet_spam = m.random_number_3
        m.timer_bullet_spam = 0
        m.random_number_3 = 5
        m.spamming = m.spamming + 1
        for each item in m.spr_enemy_2
            data = item.GetData()
            if data.stopped = true and m.run_script[3] = false
                m.CreateEnemyBullet(item.GetX()+25, item.GetY()+75, m.difficulty)
            end if
        end for
        if m.spamming = 5
            m.random_number_3 = 200+rnd(1200)
            m.spamming = 0
        end if
        'Print "Creating new sprite 'Enemy 1' "
    end if
End Function

'Change player bullet position
Function move_bullet()
    removed = -1
    for each bullet in m.spr_bullet 
        data = bullet.GetData()
        timer = data.timer
        newY = m.LinearTween(610, -40, timer.TotalMilliseconds()-data.paused_time, 1100)
        'print "Bullet move speed = " ; newY-bullet.GetY()
        bullet.MoveTo(bullet.GetX(), newY)
        if newY <= -38
            removed = removed+1
        end if
    end for
    if removed > -1
        for r = 0 to removed
            m.spr_bullet[0].Remove()
            m.spr_bullet.Shift()
        end for
    end if
End Function

'Change enemy bullet position
Function move_enemy_bullet()
    removed = -1
    for each bullet in m.spr_enemy_bullet 
        data = bullet.GetData()
        newY = m.LinearTween(145, 740, data.timer.TotalMilliseconds()-data.paused_time, m.enemy_bullet_speed)
        'print "Enemy bullet move speed = " ; newY-bullet.GetY()
        bullet.MoveTo(bullet.GetX(), newY)
        if newY >= 740
            removed = removed+1
        end if
    end for
    if removed > -1
        for r = 0 to removed
            m.spr_enemy_bullet[0].Remove()
            m.spr_enemy_bullet.Shift()
        end for
    end if
End Function

'Move enemy 1
Function move_enemy_1()
    removed = -1
    for each item in m.spr_enemy_1
        data = item.GetData()
        timer = data.timer
        newY = m.LinearTween(-70, 740, timer.TotalMilliseconds()-data.paused_time, m.enemy_1_speed)
        'print "Enemy 1 move speed = " ; newY-item.GetY()
        item.MoveTo(item.GetX(), newY)
        if newY = 740
            removed = removed+1
        end if 
    end for
    if removed > -1
        for r = 0 to removed
            m.spr_enemy_1[0].Remove()
            m.spr_enemy_1.Shift()
        end for
    end if
    'print "Number of spr_enemy_1 : " ; m.spr_enemy_1.Count()
End Function

'Perform enemy 1 actions
Function check_enemy_1()
    d = 0
    count = m.spr_enemy_1.Count()-1
    for a = 0 to count
    e = a-d
    col_enemy_1 = m.spr_enemy_1[e].CheckMultipleCollisions()
        if col_enemy_1 <> invalid
            for each item in col_enemy_1 
                if type(item.GetData()) = "roAssociativeArray"
                    bullet_count = m.spr_bullet.Count()-1-d 
                    for b = 0 to bullet_count
                        if (b-d) > -1
                            data1 = m.spr_bullet[b-d].GetData()
                            data2 = item.GetData()
                            if data1.id = data2.id
                                m.spr_bullet[b-d].Remove()
                                m.spr_bullet.Delete(b-d)
                                m.snd_enemy_explosion.Trigger(80)
                                m.explosion_positions.Push({ x: m.spr_enemy_1[a-d].GetX()+27-17, y: m.spr_enemy_1[a-d].GetY()+34-17, animation_position: 0 })
                                m.spr_enemy_1[a-d].Remove()
                                m.spr_enemy_1.Delete(a-d)
                                m.score = m.score + 10
                                d = d+1
                                exit for
                            end if
                        else 
                            exit for
                        end if
                    end for
                end if
                if type(item.GetData()) = "roInteger"
                    if item.GetData() = -1
                        if m.shield_on = 0 
                            if (a-d) > -1
                                m.snd_player_explosion.Trigger(80)
                                m.dead = 1
                                m.spr_ship.Remove()
                                m.explosion_positions.Push({ x: m.spr_enemy_1[a-d].GetX()+27-17, y: m.spr_enemy_1[a-d].GetY()+34-17, animation_position: 0 })
                                m.spr_enemy_1[a-d].Remove()
                                m.spr_enemy_1.Delete(a-d)
                                d = d+1
                            end if
                        end if
                    end if
                    if item.GetData() = -2
                        m.snd_enemy_explosion.Trigger(80)
                        m.explosion_positions.Push({ x: m.spr_enemy_1[a-d].GetX()+27-17, y: m.spr_enemy_1[a-d].GetY()+34-17, animation_position: 0 })
                        m.spr_enemy_1[a-d].Remove()
                        m.spr_enemy_1.Delete(a-d)
                        m.score = m.score + 5
                        d = d+1
                    end if
                end if
            end for
        end if
    end for
    'if d > 0
    '    print "Deleted " ; d ; " instances of 'Enemy 1'"
    'end if
End Function

'Perform Enemy 2 Actions
Function check_enemy_2()
    d = 0
    count = m.spr_enemy_2.Count()-1
    for a = 0 to count
    e = a-d
    x = m.spr_enemy_2[e].GetX()
    y = m.spr_enemy_2[e].GetY()
    data = m.spr_enemy_2[e].GetData()
    'print "Random fire = " ; data.random_fire
    'print "Timer = " ; data.bullet_timer
    'print "Stopped = " ; data.stopped
    if data.bullet_timer = data.random_fire
        if m.spawn_enemies = true and data.stopped = true and m.spamming = 0
            m.CreateEnemyBullet(x+25, y+75, m.difficulty)
            m.spr_enemy_2[e].SetData({timer: data.timer, paused_time: data.paused_time, time_without_movement: data.time_without_movement, random_fire: 100+rnd(m.enemy_2_speed), bullet_timer: 0, stopped: data.stopped})
            data = m.spr_enemy_2[e].GetData()
        else 
            m.spr_enemy_2[e].SetData({timer: data.timer, paused_time: data.paused_time, time_without_movement: data.time_without_movement, random_fire: 100+rnd(m.enemy_2_speed), bullet_timer: 0, stopped: data.stopped})
            data = m.spr_enemy_2[e].GetData()
        end if
    end if
    if y < 68  and m.clear_enemy_2 = false
        newY = m.LinearTween(-100, 740, data.timer.TotalMilliseconds()-data.paused_time, m.enemy_1_speed)
        m.spr_enemy_2[e].MoveTo(x, newY)
        m.spr_enemy_2[e].SetData({timer: data.timer, paused_time: data.paused_time, time_without_movement: data.time_without_movement, random_fire: data.random_fire, bullet_timer: data.bullet_timer, stopped: false})
    else if data.stopped = false
        m.spr_enemy_2[e].MoveTo(x, 68)
        m.spr_enemy_2[e].SetData({timer: data.timer, paused_time: data.paused_time, time_without_movement: data.timer.TotalMilliseconds()-data.paused_time, random_fire: data.random_fire, bullet_timer: data.bullet_timer, stopped: true})
    end if
    if m.clear_enemy_2 = true and data.stopped = true
        data.timer.Mark()
        m.spr_enemy_2[e].SetData({timer: data.timer, paused_time: 0, time_without_movement: data.time_without_movement, random_fire: data.random_fire, bullet_timer: data.bullet_timer, stopped: false})
        data = m.spr_enemy_2[e].GetData()
    end if
    if m.clear_enemy_2 = true
        'print "Time sent to LinearTween for instance " ; e " : " ; (data.timer.TotalMilliseconds()-data.paused_time)+data.time_without_movement
        newY = m.LinearTween(-100, 740, (data.timer.TotalMilliseconds()-data.paused_time)+data.time_without_movement, m.enemy_1_speed)
        m.spr_enemy_2[e].MoveTo(x, newY)
        m.spr_enemy_2[e].SetData({timer: data.timer, paused_time: data.paused_time, time_without_movement: data.time_without_movement, random_fire: data.random_fire, bullet_timer: data.bullet_timer, stopped: false})
    end if
    data = m.spr_enemy_2[e].GetData()
    m.spr_enemy_2[e].SetData({timer: data.timer, paused_time: data.paused_time, time_without_movement: data.time_without_movement, random_fire: data.random_fire, bullet_timer: data.bullet_timer+1, stopped: data.stopped})
    col_enemy_2 = m.spr_enemy_2[e].CheckMultipleCollisions()
        if col_enemy_2 <> invalid
            for each item in col_enemy_2
                if type(item.GetData()) = "roAssociativeArray"
                    bullet_count = m.spr_bullet.Count()-1-d
                    for b = 0 to bullet_count
                        if (b-d) > -1
                            data1 = m.spr_bullet[b-d].GetData()
                            data2 = item.GetData()
                            if data1.id = data2.id
                                m.spr_bullet[b-d].Remove()
                                m.spr_bullet.Delete(b-d)
                                m.snd_enemy_explosion.Trigger(80)
                                m.explosion_positions.Push({ x: m.spr_enemy_2[a-d].GetX()+30-17, y: m.spr_enemy_2[a-d].GetY()+45-17, animation_position: 0 })
                                m.spr_enemy_2[a-d].Remove()
                                m.spr_enemy_2.Delete(a-d)
                                m.score = m.score + 10
                                d = d+1
                                exit for
                            end if
                        else 
                            exit for
                        end if
                    end for
                end if
                if type(item.GetData()) = "roInteger"
                    if item.GetData() = -1
                        if m.shield_on = 0 
                            if (a-d) > -1
                                m.snd_player_explosion.Trigger(80)
                                m.dead = 1
                                m.spr_ship.Remove()
                                m.explosion_positions.Push({ x: m.spr_enemy_2[a-d].GetX()+30-17, y: m.spr_enemy_2[a-d].GetY()+45-17, animation_position: 0 })
                                m.spr_enemy_2[a-d].Remove()
                                m.spr_enemy_2.Delete(a-d)
                                d = d+1
                            end if
                        end if
                    end if
                    if item.GetData() = -2
                        m.snd_enemy_explosion.Trigger(80)
                        m.explosion_positions.Push({ x: m.spr_enemy_2[a-d].GetX()+30-17, y: m.spr_enemy_2[a-d].GetY()+45-17, animation_position: 0 })
                        m.spr_enemy_2[a-d].Remove()
                        m.spr_enemy_2.Delete(a-d)
                        m.score = m.score + 5
                        d = d+1
                    end if
                end if
            end for
        end if
    end for
    for each item in m.spr_enemy_2
        if item.GetY() >= 735
            m.spr_enemy_bullet = []
            for each instance in m.spr_enemy_2
                instance.Remove()
            end for
            m.spr_enemy_2 = []
            m.clear_enemy_2 = false
             exit for
        end if 
    end for   
    'if d > 0
    '    print "Deleted " ; d ; " instance of 'Enemy 2'"
    'end if
End Function

'Check for collisions with enemy bullet
Function check_enemy_bullet_collision()
    d = 0
    count = m.spr_enemy_bullet.Count()-1
    for a = 0 to count
    col_enemy_bullet = m.spr_enemy_bullet[a-d].CheckMultipleCollisions()
        if col_enemy_bullet <> invalid
            for each item in col_enemy_bullet
                if type(item.GetData()) = "roInteger"
                    if item.GetData() = -1
                        if m.shield_on = 0 
                            if (a-d) > -1
                                m.snd_player_explosion.Trigger(80)
                                m.dead = 1
                                m.spr_ship.Remove()
                                m.spr_enemy_bullet[a-d].Remove()
                                m.spr_enemy_bullet.Delete(a-d)
                                d = d+1
                            end if
                        end if
                    end if
                    if item.GetData() = -2
                        m.snd_absorb.Trigger(80)
                        m.spr_enemy_bullet[a-d].Remove()
                        m.spr_enemy_bullet.Delete(a-d)
                        m.ammo = m.ammo + 1
                        d = d+1
                    end if
                end if
            end for
        end if
    end for
    'if d > 0
    '    print "Deleted " ; d ; " instance of 'Enemy 1'"
    'end if
End Function

'Move player left
Function move_left()
    if m.dead = 0
        if m.moving_left = 1
            if m.spr_ship_x > 172 
                m.spr_ship.MoveTo(m.spr_ship_x-m.move_speed,m.ship_y)
            end if
        end if
    end if
End Function

'Move player right
Function move_right()
    if m.dead = 0
        if m.moving_right = 1
            if m.spr_ship_x < 1040
                m.spr_ship.MoveTo(m.spr_ship_x+m.move_speed,m.ship_y) 
            end if
        end if
    end if
End Function

'Display shield if enabled
Function shield()
    if m.dead = 0
        if m.shield_on = 1
            m.spr_shield.MoveTo(m.spr_ship_x-33,m.ship_y-21)
            if m.shield_life > 0
                m.shield_life = m.shield_life - (.3*(m.difficulty+1))
                if m.shield_life < 0
                    m.shield_life = 0
                end if
            else 
                m.shield_on = 0
                m.shield_life = 0
            end if
        else 
            m.spr_shield.MoveTo(-200,-200) 
            if m.down_pressed = 0
                if m.shield_life < 100
                    m.shield_life = m.shield_life + 1.2 
                else
                    m.shield_life = 100
                end if
            end if
        end if
    end if
End Function

'Cycle through explosions array
Function create_explosions()
    for each item in m.explosion_positions
        m.screen.DrawObject(item.x, item.y, m.bm_explosion[item.animation_position])
        item.animation_position = item.animation_position + 1
        if item.animation_position = 5
            m.explosion_positions.Shift()
        end if
    end for    
End Function

'Create explosion if player is dead
Function create_player_explosion()
        m.player_explosion_position = m.player_explosion_position + 1
        if m.player_explosion_position <= 6
            m.screen.DrawObject(m.spr_ship_x, m.spr_ship.GetY(), m.bm_player_explosion[m.player_explosion_position])
        end if 
End Function

'Draw UI elements
Function create_ui()
    shield_life_color = int(65279+(m.shield_life*2.56))
    if shield_life_color > 65535
        shield_life_color = 65535
    else if shield_life_color < 65279
        shield_life_color = 65279
    end if
    x_adjustment = 0
    y_adjustment = 0 
    if m.display_mode = "16:9 anamorphic"
        y_adjustment = 10
        x_adjustment = 20
    else if m.display_mode = "4:3 standard"
        y_adjustment = 15
        x_adjustment = 20
    end if
    m.screen.DrawRect(170,680-y_adjustment,m.shield_life*3,25,shield_life_color)
    m.screen.DrawRect(0,0,156,720,m.black)
    m.screen.DrawRect(1124,0,156,720,m.black)
    m.screen.DrawText("Score: "+str(m.score),640-(m.font.GetOneLineWidth("Score: "+str(m.score),1000)/2),20,m.white,m.font)
    m.screen.DrawText("Ammo: "+str(m.ammo),890-x_adjustment,660-y_adjustment,m.white,m.font) 
    m.screen.DrawText(str(int(m.shield_life))+"%",160,660-y_adjustment,m.white,m.font)
End Function

'Create enemy bullet 
Function create_enemy_bullet(start_x,start_y,difficulty)
    new_enemy = m.compositor.NewSprite(start_x , start_y, m.region_enemy_bullet)
    new_enemy.SetData({timer: CreateObject("roTimeSpan"), paused_time: 0})
    m.spr_enemy_bullet.Push(new_enemy)
End Function

'Move Scrolling Background
Function move_background()
    m.background_old_y = m.background_y
    m.background_y = m.LinearTween(0, 720, m.background_timer.TotalMilliseconds()-m.paused_time_background, m.background_speed)
    'print "Background speed = " ; (m.background_y-m.background_old_y)*-1
    m.region_background.OffSet(0,(m.background_y-m.background_old_y)*-1,0,0)
    if m.background_y >= 720
        m.background_timer.Mark()
        m.paused_time_background = 0
        m.background_old_y = 0
        m.background_y = 0
    end if
End Function

'Use Linear Tween to move ship (I know there's a better way but I just wanted to constistantly use the Linear Tween function to move all sprites)
Function ship_move_speed()
    m.ship_old_x = m.ship_x
    m.ship_x = m.LinearTween(0, 868, m.ship_timer.TotalMilliseconds()-m.paused_time_ship, 2000)
    m.move_speed = m.ship_x-m.ship_old_x
    if m.ship_x >= 720
        m.ship_timer.Mark()
        m.paused_time_ship = 0
        m.ship_old_x = 0
        m.ship_x = 0
    end if
End Function

'Linear Tween Function
Function linear_tween(start_pos, finish_pos, currentTime, duration)
    If currentTime > duration Then Return finish_pos
    change = finish_pos - start_pos
    time = currentTime / duration
    Return change * time + start_pos
End Function

'Not used, supposed to potentially fix audio dropping if two sounds play at once but it didn't seem to help for me.
Function swap_audio_channel()
    if m.audio_channel = 0
        m.audio_channel = 1
    else
        m.audio_channel = 0
    end if
End Function