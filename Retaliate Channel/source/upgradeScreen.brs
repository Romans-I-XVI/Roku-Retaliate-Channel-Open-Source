Function UpgradeScreen(screen,port)

   'Set Variables
    buttons_y = 225
    buttons_x = 210  
    black=&h000000FF
    white=&hffffffff
    Index = 0
    
    
    'Create Bitmaps
    bm_background_graphic = CreateObject("roBitmap", "pkg:/sprites/spr_background_graphic.jpg")
    bm_button_yes_0 = CreateObject("roBitmap", "pkg:/sprites/spr_button_yes_0.png")
    bm_button_yes_1 = CreateObject("roBitmap", "pkg:/sprites/spr_button_yes_1.png")
    bm_button_no_0 = CreateObject("roBitmap", "pkg:/sprites/spr_button_no_0.png")
    bm_button_no_1 = CreateObject("roBitmap", "pkg:/sprites/spr_button_no_1.png")
    
    'Create Sounds
    snd_move = CreateObject("roAudioResource", "navsingle")
    
    'Draw initial screen
    
    screen.Clear(black)
    screen.DrawObject(0,0,bm_background_graphic)
    screen.swapbuffers()
    screen.Clear(black)
    screen.DrawObject(0,0,bm_background_graphic)
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
                if index > 0
                    snd_move.Trigger(55)
                    index = index - 1
                end if
            else if code = 5 'right pressed
                if index < 1
                    snd_move.Trigger(55)
                    index = index + 1
                end if
            else if code = 6 'select pressed
                if Index = 0
                    success = upgrade()
                    if success = true
                        exit while
                    end if
                else
                    exit while
                end if
            end if
        end if
        
        
        'Draw Screen
        screen.Clear(black)
        
        screen.DrawObject(0,0,bm_background_graphic)
        
        if index = 0
            screen.DrawObject(640-404+50,555,bm_button_yes_1)
        else
            screen.DrawObject(640-404+50,555,bm_button_yes_0)        
        end if
        if index = 1
            screen.DrawObject(640-50,555,bm_button_no_1)
        else
            screen.DrawObject(640-50,555,bm_button_no_0)        
        end if
        
        screen.swapbuffers()
    end while


End Function

Function UpgradeScreenCanvas()
    canvas = CreateObject("roImageCanvas")
    port = CreateObject("roMessagePort")
    background = []
    items = []
    selectedIndex = 0      

    canvas.SetMessagePort(port)
    canvasRect = canvas.GetCanvasRect()
    'onOK(2)
    'stop
    background.Push({
        url: "pkg:/sprites/spr_background.png"
        TargetRect: {x: 0, y: 0}
    })
    items.Push({
        url: "pkg:/sprites/spr_button_yes_1.png"
        TargetRect: {x: 286, y: 555}
    })
    items.Push({
        url: "pkg:/sprites/spr_button_no_0.png"
        TargetRect: {x: 590, y: 555}
    })    
    canvas.SetLayer(0, { Color: "#00000000", CompositionMode: "Source" })
    canvas.SetLayer(1, background)
    canvas.SetLayer(2,items)
    canvas.Show()
End Function

Function upgrade()
    port = CreateObject("roMessagePort")
    store = CreateObject("roChannelStore")
    store.SetMessagePort(port)
    canvas = CreateObject("roImageCanvas")
    di = CreateObject("roDeviceInfo")
    display_mode = di.GetDisplayType()
    display_size = di.GetDisplaySize()
    items = []
    'print display_mode
    if display_mode = "HDTV"
        items.Push({
            url: "pkg:/sprites/spr_background_graphic.jpg"
            TargetRect: {x: 0, y: 0, w: 1280, h: 720}
        })   
        items.Push({
            url: "pkg:/sprites/spr_button_yes_1.png"
            TargetRect: {x: 286, y: 555}
        })
        items.Push({
            url: "pkg:/sprites/spr_button_no_0.png"
            TargetRect: {x: 590, y: 555}
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
    order = [{
        code: "retaliateupgrade"
        qty: 1
    }]
    val = store.SetOrder(order)
    res = store.DoOrder()
    if (res = true)
        order_status_dialog(true, "Upgrade")
        'Print "Order Completed Successfully"
        m.paid = true
        return true
    else
        order_status_dialog(false, "Upgrade")
        'Print "Order Failed"
        return false
    endif
End Function