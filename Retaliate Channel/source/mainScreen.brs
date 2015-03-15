Sub Main() 
    'Perform first run functions if applicable
    http = NewHttp("http://s3.amazonaws.com/roku-retaliate-channel/spr_qr_retaliate_icon.png")
    http.Http.GetToFile("tmp:/spr_qr_retaliate_icon.png") 
    http = NewHttp("http://s3.amazonaws.com/roku-retaliate-channel/snd_background_music.wma")
    http.Http.GetToFile("tmp:/snd_background_music.wma") 
    port=CreateObject("roMessagePort") 
    info = {firstname: ""
            lastname: ""}
    registry = CreateObject("roRegistrySection", "name")
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
    bm_background= CreateObject("roBitmap", "pkg:/sprites/spr_background.png")
    bm_button_easy_0=CreateObject("roBitmap", "pkg:/sprites/spr_button_easy_0.png") 
    bm_button_easy_1=CreateObject("roBitmap", "pkg:/sprites/spr_button_easy_1.png") 
    bm_button_normal_0=CreateObject("roBitmap", "pkg:/sprites/spr_button_normal_0.png") 
    bm_button_normal_1=CreateObject("roBitmap", "pkg:/sprites/spr_button_normal_1.png") 
    bm_button_hard_0=CreateObject("roBitmap", "pkg:/sprites/spr_button_hard_0.png") 
    bm_button_hard_1=CreateObject("roBitmap", "pkg:/sprites/spr_button_hard_1.png") 
    bm_button_extreme_0=CreateObject("roBitmap", "pkg:/sprites/spr_button_extreme_0.png") 
    bm_button_extreme_1=CreateObject("roBitmap", "pkg:/sprites/spr_button_extreme_1.png") 
    bm_button_donate_0=CreateObject("roBitmap", "pkg:/sprites/spr_button_donate_0.png") 
    bm_button_donate_1=CreateObject("roBitmap", "pkg:/sprites/spr_button_donate_1.png") 
    bm_logo=CreateObject("roBitmap", "pkg:/sprites/spr_logo.png") 
    bm_subtitle=CreateObject("roBitmap", "pkg:/sprites/spr_subtitle.png") 
    bm_romans=CreateObject("roBitmap", "pkg:/sprites/spr_romans.png") 
    bm_scripture_1=CreateObject("roBitmap", "pkg:/sprites/spr_scripture_1.png") 
    bm_scripture_2=CreateObject("roBitmap", "pkg:/sprites/spr_scripture_2.png") 
    
    'Create Sounds
    snd_move = CreateObject("roAudioResource", "pkg:/sounds/snd_move.wav")
    
    'Draw initial screen
    screen=CreateObject("roScreen", true, 1280, 720)
    screen.SetPort(port)
    screen.SetAlphaEnable(true)
    screen.Clear(black)
    screen.DrawObject(160,0,bm_background)
    screen.DrawRect(156,0,4,720,white)
    screen.DrawRect(1280-160,0,4,720,white)
    screen.DrawObject(190,20,bm_logo)
    screen.DrawObject(640-267, 150, bm_subtitle)
    screen.DrawObject(buttons_start_x,buttons_start_y,bm_button_easy_1)
    screen.DrawObject(buttons_start_x+410,buttons_start_y,bm_button_normal_0)
    screen.DrawObject(buttons_start_x,buttons_start_y+126,bm_button_hard_0)
    screen.DrawObject(buttons_start_x+410,buttons_start_y+126,bm_button_extreme_0)
    screen.DrawObject(buttons_start_x+203,buttons_start_y+240,bm_button_donate_0)
    screen.DrawObject(640-296,600,bm_romans)
    screen.DrawObject(640-392,640,bm_scripture_1)
    screen.DrawObject(640-407,660,bm_scripture_2)
    screen.swapbuffers()
    
    
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
                    Donate()
                end if
            end if
        end if
        'Draw Screen
        index = (rowIndex*2)+colIndex
        screen.Clear(black)      
        screen.DrawObject(160,0,bm_background)
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
        if index = 4 or index = 5
            screen.DrawObject(buttons_start_x+203,buttons_start_y+240,bm_button_donate_1)
        else 
            screen.DrawObject(buttons_start_x+203,buttons_start_y+240,bm_button_donate_0)
        end if
        screen.swapbuffers()
    end while
    
End Sub

Function Donate()
    dialog = CreateObject("roMessageDialog")
    port = CreateObject("roMessagePort")
    store = CreateObject("roChannelStore")
    canvas = CreateObject("roImageCanvas")
    di = CreateObject("roDeviceInfo")
    display_mode = di.GetDisplayType()
    display_size = di.GetDisplaySize()
    items = []
    'print display_mode
    if display_mode = "HDTV"
        items.Push({
            url: "pkg:/sprites/spr_background.png"
            TargetRect: {x: 160, y: 0, w: 960, h: 720}
        })
        items.Push({
            url: "pkg:/sprites/spr_button_easy_0.png"
            TargetRect: {x: 235, y: 225, w: 404, h: 148}
        })
        items.Push({
            url: "pkg:/sprites/spr_button_hard_0.png"
            TargetRect: {x: 235, y: 351, w: 404, h: 148}
        })
        items.Push({
            url: "pkg:/sprites/spr_button_normal_0.png"
            TargetRect: {x: 645, y: 225, w: 404, h: 148}
        })
        items.Push({
            url: "pkg:/sprites/spr_button_extreme_0.png"
            TargetRect: {x: 645, y: 351, w: 404, h: 148}
        })
        items.Push({
            url: "pkg:/sprites/spr_button_donate_0.png"
            TargetRect: {x: 438, y: 465, w: 404, h: 148}
        })
        items.Push({
            url: "pkg:/sprites/spr_logo.png"
            TargetRect: {x: 190, y: 20, w: 900, h: 160}
        })
        items.Push({
            url: "pkg:/sprites/spr_subtitle.png"
            TargetRect: {x: 373, y: 150, w: 534, h: 70}
        })
        items.Push({
            url: "pkg:/sprites/spr_romans.png"
            TargetRect: {x: 344, y: 600, w: 592, h: 36}
        })
        items.Push({
            url: "pkg:/sprites/spr_scripture_1.png"
            TargetRect: {x: 248, y: 640, w: 782, h: 24}
        })
        items.Push({
            url: "pkg:/sprites/spr_scripture_2.png"
            TargetRect: {x: 233, y: 660, w: 813, h: 24}
        })
        items.Push({
            url: "pkg:/sprites/spr_line.png"
            TargetRect: {x: 156, y: 0, w: 4, h: 720}
        })
        items.Push({
            url: "pkg:/sprites/spr_line.png"
            TargetRect: {x: 1120, y: 0, w: 4, h: 720}
        })
    else
        items.Push({
            url: "pkg:/sprites/spr_background.png"
            TargetRect: {x: 0, y: 0, w: display_size.w, h: display_size.h}
        })
    end if
    canvas.SetMessagePort(port)
    canvas.SetLayer(0, { Color: "#ff000000", CompositionMode: "Source" })
    canvas.SetLayer(1,items)
    canvas.SetLayer(2, { Color: "#8F000000", CompositionMode: "Source_Over" })
    canvas.show()
    store.SetMessagePort(port)
    dialog.SetMessagePort(port)
    dialog.SetTitle("Donate To The Developer")
    dialog.SetText("I am proud to offer Retaliate completely free, but if you enjoy my work and would like to contribute towards future projects, your donation would be very much appreciated!")
    dialog.EnableOverlay(true) 
    dialog.AddButton(1, "Donate $0.99")
    dialog.AddButton(2, "Donate $ 1.99")
    dialog.AddButton(3, "Donate $4.99")
    dialog.EnableBackButton(true)
    dialog.Show()
    While True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                if dlgMsg.GetIndex() = 1
                    title = "$0.99 Donation"
                    code = "donation1"
                    dialog.Close()
                    exit while
                end if
                if dlgMsg.GetIndex() = 2
                    title = "$1.99 Donation"
                    code = "donation2"
                    index = 2
                    dialog.Close()
                    exit while
                end if
                if dlgMsg.GetIndex() = 3
                    title = "$4.99 Donation"
                    code = "donation3"
                    index = 3
                    dialog.Close()
                    exit while
                end if
            else if dlgMsg.isScreenClosed()
                dialog.Close()
                return -1
            end if
        end if
    end while  
    order = [{
        code: code
        qty: 1
        }]
    val = store.SetOrder(order)
    res = store.DoOrder()
    if (res = true)
        order_status_dialog(true, title)
        'Print "Order Completed Successfully"
    else
        order_status_dialog(false, title)
        'Print "Order Failed"
    end if
End Function

Function order_status_dialog(success as boolean, item as string) as void
    dialog = CreateObject("roMessageDialog")
    port = CreateObject("roMessagePort")
    dialog.SetMessagePort(port)
    if (success = true)
        dialog.SetTitle("Thank You!")
        str = "Your Purchase of '" + item + "' Completed Successfully"
    else
        dialog.SetTitle("Order Failed")
        str = "Your Purchase of '" + item + "' Failed"
    endif
    dialog.SetText(str)
    dialog.EnableOverlay(true) 
    dialog.AddButton(1, "OK")
    dialog.EnableBackButton(true)
    dialog.Show()

    while true
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                if dlgMsg.GetIndex() = 1
                    exit while
                end if
            else if dlgMsg.isScreenClosed()
                exit while
            end if
        end if
    end while
End Function