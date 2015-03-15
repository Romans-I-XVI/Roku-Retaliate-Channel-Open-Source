'The scripted events are probably some of my most confusing and possibly improperly laid out portions of code, but hey, they work.

'Randomly chooses a scripted event to execute.
Function select_scripted_action()
    m.timer_scripts = m.timer_scripts+1
    if m.timer_scripts = m.random_number_4
        'print "Difficulty = " ; m.difficulty
        if m.difficulty = 3
            random = rnd(5)-1
        else
            random = rnd(4)-1
        end if
        m.run_script[random] = true
        print "running script : " ; random
        m.spawn_enemies = false
        if random = 2 or random = 3 or random = 4
            m.clear_enemy_2 = true
        end if
        m.timer_scripts = 0
        m.random_number_4 = 1000+rnd(2000)
    end if
End Function

'Creates a diamond pattern with enemy 1 (Not currently implemented)
Function script_diamonds()
    m.timer_script = m.timer_script+1
    x = 640-27
    if m.timer_script = 10
            m.spr_enemy_1.Push(m.compositor.NewSprite(x+(60*m.script_wedge_count), -70, m.region_enemy_1))
            m.spr_enemy_1[m.spr_enemy_1.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0})
            m.spr_enemy_1.Push(m.compositor.NewSprite(x+(60*-m.script_wedge_count), -70, m.region_enemy_1))
            m.spr_enemy_1[m.spr_enemy_1.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0})
            m.script_wedge_count = m.script_wedge_count + 1
            if m.script_wedge_count < 7
                m.timer_script = 0
            end if
    else if m.timer_script = 20
            m.spr_enemy_1.Push(m.compositor.NewSprite(x+(60*m.script_wedge_count), -70, m.region_enemy_1))
            m.spr_enemy_1[m.spr_enemy_1.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0})
            m.spr_enemy_1.Push(m.compositor.NewSprite(x+(60*-m.script_wedge_count), -70, m.region_enemy_1))
            m.spr_enemy_1[m.spr_enemy_1.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0})
            m.script_wedge_count = m.script_wedge_count - 1
            if m.script_wedge_count > 0
                m.timer_script = 11
            else
                m.timer_script = 0
            end if
    end if
End Function

'Creates a wedge pattern with enemy 1
Function script_wedge()
    m.timer_script = m.timer_script+1
    x = 640-27
    if m.timer_script = 100
            m.spr_enemy_1.Push(m.compositor.NewSprite(x+(60*m.script_wedge_count), -70, m.region_enemy_1))
            m.spr_enemy_1[m.spr_enemy_1.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0})
            if m.script_wedge_count > 0
                m.spr_enemy_1.Push(m.compositor.NewSprite(x+(60*-m.script_wedge_count), -70, m.region_enemy_1))
                m.spr_enemy_1[m.spr_enemy_1.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0})
            end if
            m.script_wedge_count = m.script_wedge_count + 1
            if m.script_wedge_count < 8
                m.timer_script = 90
            end if
    else if m.timer_script = 150
        m.script_wedge_count = 0
        m.timer_script = 0
        m.run_script[0] = false
        m.spawn_enemies = true
        m.clear_enemy_2 = false
    end if
End Function

'Creates a reverse wedge pattern with enemy 1
Function script_wedge_2()
    m.timer_script = m.timer_script+1
    x = 640-27
    if m.timer_script = 100
            m.spr_enemy_1.Push(m.compositor.NewSprite(x+(60*m.script_wedge_count_2), -70, m.region_enemy_1))
            m.spr_enemy_1[m.spr_enemy_1.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0})
            if m.script_wedge_count_2 > 0
                m.spr_enemy_1.Push(m.compositor.NewSprite(x+(60*-m.script_wedge_count_2), -70, m.region_enemy_1))
                m.spr_enemy_1[m.spr_enemy_1.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0})
            end if
            m.script_wedge_count_2 = m.script_wedge_count_2 - 1
            if m.script_wedge_count_2 > -1
                m.timer_script = 90
            end if
    else if m.timer_script = 150
        m.script_wedge_count_2 = 7
        m.timer_script = 0
        m.run_script[1] = false
        m.spawn_enemies = true
        m.clear_enemy_2 = false
    end if
End Function

'Creates a wave of enemies with enemy 1
Function script_waves()
    m.timer_script = m.timer_script+1
    if m.timer_script = 100 or m.timer_script = 150 or m.timer_script = 200 or m.timer_script = 250 or m.timer_script = 300 or m.timer_script = 350
        x = 188
        for a = 0 to 11
            m.spr_enemy_1.Push(m.compositor.NewSprite(x+(78*a), -70, m.region_enemy_1))
            m.spr_enemy_1[m.spr_enemy_1.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0})
        end for
    end if
    if m.timer_script = 400
        m.spr_enemy_bullet = []
        m.timer_script = 0
        m.run_script[2] = false
        m.spawn_enemies = true
        m.clear_enemy_2 = false
    end if
End Function

'Creates a fun "frown" looking spawn of enemies. Includes tears of bullets.
Function script_frown()
    m.timer_script = m.timer_script+1
    x = 640-27
    if m.timer_script > 189 and m.spr_enemy_2.Count() = 0
        'print "waiting for enemy 2 to be cleared" 
        m.clear_enemy_2 = false
    end if
    if m.timer_script = 190 and m.clear_enemy_2 = true
        m.timer_script = 189
    end if
    if m.timer_script = 200
            m.spr_enemy_1.Push(m.compositor.NewSprite(x+(60*m.script_frown_count), -70, m.region_enemy_1))
            m.spr_enemy_1[m.spr_enemy_1.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0})
            m.spr_enemy_1.Push(m.compositor.NewSprite(x+(60*-m.script_frown_count), -70, m.region_enemy_1))
            m.spr_enemy_1[m.spr_enemy_1.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0})
            m.script_frown_count = m.script_frown_count - 1
            if m.script_frown_count > -1
                m.timer_script = 198 - m.script_frown_count
            end if
    else if m.timer_script = 220
            m.spr_enemy_2 = []
            m.spr_enemy_2.Push(m.compositor.NewSprite(420, -100, m.region_enemy_2))
            m.spr_enemy_2[m.spr_enemy_2.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0,time_without_movement: 0,random_fire: 200+rnd(m.enemy_2_speed), bullet_timer: 0, stopped: false})
            m.spr_enemy_2.Push(m.compositor.NewSprite(780, -100, m.region_enemy_2))
            m.spr_enemy_2[m.spr_enemy_2.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0,time_without_movement: 0,random_fire: 200+rnd(m.enemy_2_speed), bullet_timer: 0, stopped: false})
    else if m.timer_script = 250
        data = m.spr_enemy_2[0].GetData()
        if data.stopped = true
            'print "firing spam"
            m.timer_bullet_spam = m.random_number_3-1
        else 
            m.timer_script = 249
        end if
    else if m.timer_script = 320
        m.script_frown_count = 5
        m.timer_script = 0
        m.run_script[4] = false
        m.spawn_enemies = true
        m.clear_enemy_2 = false
    end if
End Function

'Spawns a row of enemy 2 and rains bullets. 
Function script_bullet_hell()
    m.timer_script = m.timer_script+1
    if m.timer_script > 189 and m.spr_enemy_2.Count() = 0
        'print "waiting for enemy 2 to be cleared" 
        m.clear_enemy_2 = false
    end if
    if m.timer_script = 190 and m.clear_enemy_2 = true
        m.timer_script = 189
    end if
    if m.timer_script = 200
        x = 210
        m.spr_enemy_2 = []
        for a = 0 to 10
            m.spr_enemy_2.Push(m.compositor.NewSprite(x+(80*a), -100, m.region_enemy_2))
            m.spr_enemy_2[m.spr_enemy_2.Count()-1].SetData({timer: CreateObject("roTimeSpan"), paused_time: 0,time_without_movement: 0,random_fire: 200+rnd(m.enemy_2_speed), bullet_timer: 0, stopped: false})
        end for
    end if
    if m.timer_script > 250
        m.timer_hell_spam = m.timer_hell_spam+1
        if m.timer_hell_spam = m.hell_interval and m.hell_spam < 11
            m.timer_hell_spam = 0
            m.hell_interval = 10
            m.hell_spam = m.hell_spam + 1
            for each item in m.spr_enemy_2
                m.hell_alternate = m.hell_alternate*-1
                if m.hell_alternate = 1
                    m.CreateEnemyBullet(item.GetX()+25, item.GetY()+75, m.difficulty)
                end if
            end for
            if m.spr_enemy_2.Count()/2 = Int(m.spr_enemy_2.Count()/2)
                m.hell_alternate = m.hell_alternate*-1
            end if
            'Print "Creating new sprite 'Enemy 1' "
        end if
    end if
    
    if m.timer_script = 550
        'Print "Getting rid of all these enemy 2's"
        m.clear_enemy_2 = true
    end if
    if m.timer_script = 650
        if m.spr_enemy_2.Count() = 0
            m.spr_enemy_bullet = []
            m.hell_spam = 0
            m.spawn_enemies = true
            m.run_script[3] = false
            m.timer_script = 0
            m.hell_alternate = 1
            m.timer_hell_spam = 0
            m.hell_interval = 10
            m.clear_enemy_2 = false
        else
            m.timer_script = 649
        end if
    end if
    
End Function