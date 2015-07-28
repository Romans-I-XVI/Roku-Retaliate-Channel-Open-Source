Library "v30/bslDefender.brs" 
Library "Roku_Ads.brs"
Sub Main() 
    'Perform first run functions if applicable
    port=CreateObject("roMessagePort") 
    info = {firstname: ""
            lastname: ""}
    'Set Globals
    m.paid = false
    m.ad_timer = CreateObject("roTimeSpan")
    m.ad_interval = GetAdInterval()
    upgrade_check_success = get_user_purchases()
    m.active_score_table = "alltime"
    m.prefix = GetVPSLocation()
    m.ship_color = {}
    m.ship_color.ship_1 = { part_1: {hue: 0, sat: 0, hex: 0}
                    part_2: {hue: 0, sat: 0, hex: 0}
                    part_3: {hue: 0, sat: 0, hex: 0}
                    shield: {hue: 0, sat: 0, hex: 0}
                    }
    m.ship_color.ship_2 = { part_1: {hue: 0, sat: 0, hex: 0}
                    part_2: {hue: 0, sat: 0, hex: 0}
                    part_3: {hue: 0, sat: 0, hex: 0}
                    shield: {hue: 0, sat: 0, hex: 0}
                    }
    m.ship_color.ship_3 = { part_1: {hue: 0, sat: 0, hex: 0}
                    part_2: {hue: 0, sat: 0, hex: 0}
                    part_3: {hue: 0, sat: 0, hex: 0}
                    shield: {hue: 0, sat: 0, hex: 0}
                    }
    m.ship_color.ship_4 = { part_1: {hue: 0, sat: 0, hex: 0}
                    part_2: {hue: 0, sat: 0, hex: 0}
                    part_3: {hue: 0, sat: 0, hex: 0}
                    shield: {hue: 0, sat: 0, hex: 0}
                    }
    m.ship_color.ship_5 = { part_1: {hue: 0, sat: 0, hex: 0}
                    part_2: {hue: 0, sat: 0, hex: 0}
                    part_3: {hue: 0, sat: 0, hex: 0}
                    shield: {hue: 0, sat: 0, hex: 0}
                    }
                    
    'Check Registry    
    registry_active_ship = CreateObject("roRegistrySection", "active_ship")
    m.active_ship = "ship_1"
    if registry_active_ship.Exists("active_ship") 
         m.active_ship = registry_active_ship.Read("active_ship")
    else
        registry_active_ship.Write("active_ship", "ship_1")
    end if
    registry = CreateObject("roRegistrySection", "name")
    registry_color = {}
    registry_color.ship_1 = CreateObject("roRegistrySection", "ship_1")
    registry_color.ship_2 = CreateObject("roRegistrySection", "ship_2")
    registry_color.ship_3 = CreateObject("roRegistrySection", "ship_3")
    registry_color.ship_4 = CreateObject("roRegistrySection", "ship_4")
    registry_color.ship_5 = CreateObject("roRegistrySection", "ship_5")
    for each key in registry_color
        if registry_color[key].Exists("part_1_hue")
            m.ship_color[key].part_1.hue = registry_color[key].Read("part_1_hue").toint()
            m.ship_color[key].part_1.sat = registry_color[key].Read("part_1_sat").toint()
            m.ship_color[key].part_2.hue = registry_color[key].Read("part_2_hue").toint()
            m.ship_color[key].part_2.sat = registry_color[key].Read("part_2_sat").toint()
            m.ship_color[key].part_3.hue = registry_color[key].Read("part_3_hue").toint()
            m.ship_color[key].part_3.sat = registry_color[key].Read("part_3_sat").toint()
            m.ship_color[key].shield.hue = registry_color[key].Read("shield_hue").toint()
            m.ship_color[key].shield.sat = registry_color[key].Read("shield_sat").toint()
            
        else
            registry_color[key].Write("part_1_hue", "0")
            registry_color[key].Write("part_1_sat", "0")
            registry_color[key].Write("part_2_hue", "210")
            registry_color[key].Write("part_2_sat", "80")
            registry_color[key].Write("part_3_hue", "0")
            registry_color[key].Write("part_3_sat", "80")
            registry_color[key].Write("shield_hue", "220")
            registry_color[key].Write("shield_sat", "85")
            m.ship_color[key].part_1.hue = 0
            m.ship_color[key].part_1.sat = 0
            m.ship_color[key].part_2.hue = 210
            m.ship_color[key].part_2.sat = 80
            m.ship_color[key].part_3.hue = 0
            m.ship_color[key].part_3.sat = 80
            m.ship_color[key].shield.hue = 220
            m.ship_color[key].shield.sat = 85
        end if
        m.ship_color[key].part_1.hex = HSVAtoRGBA(m.ship_color[key].part_1.hue,m.ship_color[key].part_1.sat,100,255)
        m.ship_color[key].part_2.hex = HSVAtoRGBA(m.ship_color[key].part_2.hue,m.ship_color[key].part_2.sat,100,255)
        m.ship_color[key].part_3.hex = HSVAtoRGBA(m.ship_color[key].part_3.hue,m.ship_color[key].part_3.sat,100,255)
        m.ship_color[key].shield.hex = HSVAtoRGBA(m.ship_color[key].shield.hue,m.ship_color[key].shield.sat,100,255)
    end for
    
        'm.ship_color["ship_1"].part_1.hex = HSVAtoRGBA(0,0,100,255)
        'm.ship_color["ship_1"].part_2.hex = HSVAtoRGBA(200,80,100,255)
        'm.ship_color["ship_1"].part_3.hex = HSVAtoRGBA(0,80,100,255)
        
    
        
    sounds = {snd_enemy_explosion: CreateObject("roAudioResource", "pkg:/sounds/snd_enemy_explosion.wav"),
        snd_player_explosion: CreateObject("roAudioResource", "pkg:/sounds/snd_player_explosion.wav"),
        snd_absorb: CreateObject("roAudioResource", "pkg:/sounds/snd_absorb.wav")}
    if registry.Exists("firstname") 
         info.firstname = registry.Read("firstname")
         info.lastname = registry.Read("lastname")
    else
        canvas = CreateObject("roImageCanvas")
        items = []
        di = CreateObject("roDeviceInfo")
        display_mode = di.GetDisplayType()
        display_size = di.GetDisplaySize()
        if display_mode = "HDTV"
            items.Push({
                url: "pkg:/sprites/spr_background.png"
                TargetRect: {x: 0, y: 0, w: 960, h: 720}
            })
            items.Push({
                url: "pkg:/sprites/spr_background.png"
                TargetRect: {x: 960, y: 0, w: 960, h: 720}
            })
            items.Push({
                url: "pkg:/sprites/spr_dpad.png"
                TargetRect: {x: 490, y: 40, w: 300, h: 220}
                })
        else 
            items.Push({
                url: "pkg:/sprites/spr_background.png"
                TargetRect: {x: 0, y: 0, w: display_size.w, h: display_size.h}
            })
            items.Push({
                url: "pkg:/sprites/spr_dpad_small.png"
                TargetRect: {x: 270, y: 40, w: 190, h: 140}
                })
        end if
        canvas.SetMessagePort(port)
        canvas.SetLayer(0, { Color: "#ff000000", CompositionMode: "Source" })
        canvas.SetLayer(1,items)
        canvas.show()
        if not registry.Exists("notfirststart")
            registry.Write("notfirststart","true")
            dialog = CreateObject("roMessageDialog")
            dialog.SetMessagePort(port)
            dialog.SetTitle("Welcome To Retaliate: The Concept!")
            dialog.SetText("This is Retaliate in its most basic form. Steal ammo, score points, and top the leaderboard!")
            dialog.EnableOverlay(true) 
            dialog.AddButton(1, "Sweet!")
            dialog.EnableBackButton(true)
            dialog.Show()
            While True
                dlgMsg = wait(0, dialog.GetMessagePort())
                If type(dlgMsg) = "roMessageDialogEvent"
                    if dlgMsg.isButtonPressed()
                        if dlgMsg.GetIndex() = 1
                            dialog.Close()
                            exit while
                        end if
                    else if dlgMsg.isScreenClosed()
                        dialog.Close()
                        exit while
                    end if
                end if
            end while  
            dialog = CreateObject("roMessageDialog")
            port=CreateObject("roMessagePort")
            dialog.SetMessagePort(port)
            dialog.SetTitle("The Unique Idea")
            dialog.SetText("You start each round with absolutly no ammo! Block enemy bullets with your shield to steal them and retaliate!")
            dialog.EnableOverlay(true) 
            dialog.AddButton(1, "Oh that's interesting.")
            dialog.EnableBackButton(true)
            dialog.Show()
            While True
                dlgMsg = wait(0, dialog.GetMessagePort())
                If type(dlgMsg) = "roMessageDialogEvent"
                    if dlgMsg.isButtonPressed()
                        if dlgMsg.GetIndex() = 1
                            dialog.Close()
                            exit while
                        end if
                    else if dlgMsg.isScreenClosed()
                        dialog.Close()
                        exit while
                    end if
                end if
            end while 
        end if
        dialog = CreateObject("roMessageDialog")
        port=CreateObject("roMessagePort")
        dialog.SetMessagePort(port)
        dialog.SetTitle("Online Leaderboards")
        dialog.SetText("If you would like your scores to be posted to the online leaderboards please select 'Share' in the following dialog.")
        dialog.EnableOverlay(true) 
        dialog.AddButton(1, "Ok")
        dialog.EnableBackButton(true)
        dialog.Show()
        While True
            dlgMsg = wait(0, dialog.GetMessagePort())
            If type(dlgMsg) = "roMessageDialogEvent"
                if dlgMsg.isButtonPressed()
                    if dlgMsg.GetIndex() = 1
                        dialog.Close()
                        exit while
                    end if
                else if dlgMsg.isScreenClosed()
                    dialog.Close()
                    exit while
                end if
            end if
        end while
        store = CreateObject("roChannelStore")
        store.SetMessagePort(port)
        info = store.GetPartialUserData("firstname,lastname")
        if info <> invalid
            if info.firstname <> "" and info.firstname <> " "
                registry.Write("firstname",info.firstname)
                registry.Write("lastname",info.lastname)
            end if
        end if
    end if    
    
    'Set Variables
    buttons_start_y = 225
    buttons_start_x = 235
    black=&h000000FF
    white=&hffffffff
    rowIndex=0
    colIndex=0
    score = -1
    
    'Create Bitmaps
    'Set Background Global
    m.bm_background= CreateObject("roBitmap", "pkg:/sprites/spr_background.png")
    bm_button_easy_0=CreateObject("roBitmap", "pkg:/sprites/spr_button_easy_0.png") 
    bm_button_easy_1=CreateObject("roBitmap", "pkg:/sprites/spr_button_easy_1.png") 
    bm_button_normal_0=CreateObject("roBitmap", "pkg:/sprites/spr_button_normal_0.png") 
    bm_button_normal_1=CreateObject("roBitmap", "pkg:/sprites/spr_button_normal_1.png") 
    bm_button_hard_0=CreateObject("roBitmap", "pkg:/sprites/spr_button_hard_0.png") 
    bm_button_hard_1=CreateObject("roBitmap", "pkg:/sprites/spr_button_hard_1.png") 
    bm_button_extreme_0=CreateObject("roBitmap", "pkg:/sprites/spr_button_extreme_0.png") 
    bm_button_extreme_1=CreateObject("roBitmap", "pkg:/sprites/spr_button_extreme_1.png") 
    bm_button_hangar_0=CreateObject("roBitmap", "pkg:/sprites/spr_button_hangar_0.png") 
    bm_button_hangar_1=CreateObject("roBitmap", "pkg:/sprites/spr_button_hangar_1.png") 
    bm_button_upgrade_0=CreateObject("roBitmap", "pkg:/sprites/spr_button_upgrade_0.png") 
    bm_button_upgrade_1=CreateObject("roBitmap", "pkg:/sprites/spr_button_upgrade_1.png") 
    bm_logo=CreateObject("roBitmap", "pkg:/sprites/spr_logo.png") 
    bm_subtitle=CreateObject("roBitmap", "pkg:/sprites/spr_subtitle.png") 
    bm_romans=CreateObject("roBitmap", "pkg:/sprites/spr_romans.png") 
    bm_scripture_1=CreateObject("roBitmap", "pkg:/sprites/spr_scripture_1.png") 
    bm_scripture_2=CreateObject("roBitmap", "pkg:/sprites/spr_scripture_2.png") 
    
    'Create Sounds
    snd_move = CreateObject("roAudioResource", "navsingle")
    
    'Draw initial screen
    screen=CreateObject("roScreen", true, 1280, 720)
    screen.SetPort(port)
    screen.SetAlphaEnable(true)
    for a = 0 to 1
        screen.Clear(black)
        screen.DrawObject(160,0,m.bm_background)
        screen.DrawRect(156,0,4,720,white)
        screen.DrawRect(1280-160,0,4,720,white)
        screen.DrawObject(190,20,bm_logo)
        screen.DrawObject(640-267, 150, bm_subtitle)
        screen.DrawObject(buttons_start_x,buttons_start_y,bm_button_easy_1)
        screen.DrawObject(buttons_start_x+410,buttons_start_y,bm_button_normal_0)
        screen.DrawObject(buttons_start_x,buttons_start_y+126,bm_button_hard_0)
        screen.DrawObject(buttons_start_x+410,buttons_start_y+126,bm_button_extreme_0)
        if m.paid = true
            screen.DrawObject(buttons_start_x+203,buttons_start_y+240,bm_button_hangar_0)
        else
            screen.DrawObject(buttons_start_x+203,buttons_start_y+240,bm_button_upgrade_0)
        end if
        screen.DrawObject(640-296,600,bm_romans)
        screen.DrawObject(640-392,640,bm_scripture_1)
        screen.DrawObject(640-407,660,bm_scripture_2)
        screen.swapbuffers()
    end for
    
    if not upgrade_check_success
        dialog = CreateObject("roMessageDialog")
        dialog.SetMessagePort(port)
        dialog.SetTitle("Couldn't Connect To Server")
        dialog.SetText("It appears you're not connected to the internet. Retaliate will still work but you may experience long waits on screens that attempt to connect to the internet.")
        dialog.EnableOverlay(true) 
        dialog.AddButton(1, "Ok")
        dialog.EnableBackButton(true)
        dialog.Show()
        While True
            dlgMsg = wait(0, dialog.GetMessagePort())
            If type(dlgMsg) = "roMessageDialogEvent"
                if dlgMsg.isButtonPressed()
                    if dlgMsg.GetIndex() = 1
                        dialog.Close()
                        exit while
                    end if
                else if dlgMsg.isScreenClosed()
                    dialog.Close()
                    exit while
                end if
            end if
        end while 
    end if
    
    
    while (true)
        msg = wait(1, port) 
        if (type(msg) = "roUniversalControlEvent")
            'print "appRoScreen  index = "; msg.GetInt()
            code = msg.GetInt()
            if code = 0 'back pressed
                snd_move.Trigger(55)
                exit while
            else if code = 4 'left pressed
                if colIndex > 0 and rowIndex < 2
                    snd_move.Trigger(55)
                    colIndex = colIndex - 1
                end if
            else if code = 5 'right pressed
                if colIndex < 1 and rowIndex < 2
                    snd_move.Trigger(55)
                    colIndex = colIndex + 1
                end if
            else if code = 2 'up pressed
                if rowIndex > 0
                    snd_move.Trigger(55)
                    rowIndex = rowIndex - 1
                end if
            else if code = 3 'down pressed
                if rowIndex < 2
                    snd_move.Trigger(55)
                    rowIndex = rowIndex + 1
                end if
            else if code = 6 'select pressed
                snd_move.Trigger(55)
                play:
                index = (rowIndex*2)+colIndex 
                if index < 4 
                    results = Start(screen,port,index,sounds) 
                    if results.score > -1
                        replay = ScoreScreen(screen,port,results,info)
                        if replay = true
                            goto play
                        end if
                    end if
                else
                    if index = 4 or index = 5
                        if m.paid = true
                            HangarScreen(screen,port)
                            registry_active_ship.Write("active_ship",m.active_ship)
                            for each key in registry_color
                                registry_color[key].Write("part_1_hue", int(m.ship_color[key].part_1.hue).tostr())
                                registry_color[key].Write("part_1_sat", int(m.ship_color[key].part_1.sat).tostr())
                                registry_color[key].Write("part_2_hue", int(m.ship_color[key].part_2.hue).tostr())
                                registry_color[key].Write("part_2_sat", int(m.ship_color[key].part_2.sat).tostr())
                                registry_color[key].Write("part_3_hue", int(m.ship_color[key].part_3.hue).tostr())
                                registry_color[key].Write("part_3_sat", int(m.ship_color[key].part_3.sat).tostr())
                                registry_color[key].Write("shield_hue", int(m.ship_color[key].shield.hue).tostr())
                                registry_color[key].Write("shield_sat", int(m.ship_color[key].shield.sat).tostr())
                            end for
                         else
                            upgradescreen(screen,port)
                         end if
                    end if
                end if
            end if
        end if
        'Draw Screen
        index = (rowIndex*2)+colIndex
        screen.Clear(black)      
        screen.DrawObject(160,0,m.bm_background)
        screen.DrawRect(156,0,4,720,white)
        screen.DrawRect(1280-160,0,4,720,white)
        screen.DrawObject(190,20,bm_logo)
        screen.DrawObject(640-267, 150, bm_subtitle)
        screen.DrawObject(640-296,600,bm_romans)
        screen.DrawObject(640-392,640,bm_scripture_1)
        screen.DrawObject(640-407,660,bm_scripture_2)
        if index = 0
            screen.DrawObject(buttons_start_x,buttons_start_y,bm_button_easy_1)
        else 
            screen.DrawObject(buttons_start_x,buttons_start_y,bm_button_easy_0)
        end if
        if index = 1
            screen.DrawObject(buttons_start_x+410,buttons_start_y,bm_button_normal_1)
        else
            screen.DrawObject(buttons_start_x+410,buttons_start_y,bm_button_normal_0)
        end if
        if index = 2
            screen.DrawObject(buttons_start_x,buttons_start_y+126,bm_button_hard_1)
        else
            screen.DrawObject(buttons_start_x,buttons_start_y+126,bm_button_hard_0)
        end if
        if index = 3
            screen.DrawObject(buttons_start_x+410,buttons_start_y+126,bm_button_extreme_1)
        else 
            screen.DrawObject(buttons_start_x+410,buttons_start_y+126,bm_button_extreme_0)
        end if
        if m.paid
            if index = 4 or index = 5
                screen.DrawObject(buttons_start_x+203,buttons_start_y+240,bm_button_hangar_1)
            else 
                screen.DrawObject(buttons_start_x+203,buttons_start_y+240,bm_button_hangar_0)
            end if
        else
            if index = 4 or index = 5
                screen.DrawObject(buttons_start_x+203,buttons_start_y+240,bm_button_upgrade_1)
            else 
                screen.DrawObject(buttons_start_x+203,buttons_start_y+240,bm_button_upgrade_0)
            end if            
        end if
        
        screen.swapbuffers()
    end while
    
End Sub


    
