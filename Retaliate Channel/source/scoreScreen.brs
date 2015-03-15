Function ScoreScreen(screen,port,results,info)
    'Set Variables
    timer=CreateObject("roTimeSpan")
    black=&h00000000
    black2=&h000000ff
    white=&hffffffff
    arrow_x = 1000
    arrow_move = 1
    index = 0
    font_registry= CreateObject("roFontRegistry")
    difficulty_text = ""
    if results.difficulty = 0
        difficulty_text = "Easy"
        difficulty_text_x = 280
    else if results.difficulty = 1
        difficulty_text = "Normal"
        difficulty_text_x = 260
    else if results.difficulty = 2
        difficulty_text = "Hard"
        difficulty_text_x = 280
    else if results.difficulty = 3
        difficulty_text = "Extreme"
        difficulty_text_x = 240
    end if
    di = CreateObject("roDeviceInfo")
    display_mode = di.GetDisplayType()
    a_word = "For"
    if display_mode = "HDTV"
        a_word = "Retaliate"
    end if
    
    'Create Fonts
    font = font_registry.GetDefaultFont( font_registry.GetDefaultFontSize(), true, false) 
    small_font = font_registry.GetDefaultFont( font_registry.GetDefaultFontSize(), false, false) 
    
    'Create Bitmaps
    bm_background= CreateObject("roBitmap", "pkg:/sprites/spr_background.png")
    bm_google_play= CreateObject("roBitmap", "pkg:/sprites/spr_google_play.png") 
    bm_arrow_right = CreateObject("roBitmap", "pkg:/sprites/spr_arrow_right.png")
    bm_qr_retaliate= CreateObject("roBitmap", "tmp:/spr_qr_retaliate_icon.png")
    bm_qr_twitter= CreateObject("roBitmap", "pkg:/sprites/spr_qr_twitter_icon_small.png")
    bm_qr_facebook= CreateObject("roBitmap", "pkg:/sprites/spr_qr_facebook_icon_small.png")
    bm_qr_youtube= CreateObject("roBitmap", "pkg:/sprites/spr_qr_youtube_icon_small.png")
    bm_button_replay_0 = CreateObject("roBitmap", "pkg:/sprites/spr_button_replay_0.png")
    bm_button_replay_1 = CreateObject("roBitmap", "pkg:/sprites/spr_button_replay_1.png")
    bm_button_menu_0 = CreateObject("roBitmap", "pkg:/sprites/spr_button_menu_0.png")
    bm_button_menu_1 = CreateObject("roBitmap", "pkg:/sprites/spr_button_menu_1.png")
    region_background = CreateObject("roRegion", bm_background,0,0,590,720)
    
    'Create Sounds
    snd_move = CreateObject("roAudioResource", "pkg:/sounds/snd_move.wav")
    
    'Create Initial Screen
    screen.Clear(black)
    screen.DrawObject(160,0,region_background)    
    screen.DrawRect(156,0,4,720,white)
    screen.DrawRect(1280-160,0,4,720,white)
    screen.DrawText("Highscores - "+difficulty_text,460-(font.GetOneLineWidth("Highscores - "+difficulty_text,1000)/2),35,white,font)
    screen.DrawText("Great Job, You Scored",160+70,510,white,font)
    screen.DrawText(str(results.score)+" Points!",460-(font.GetOneLineWidth(str(results.score)+" Points!",1000)/2),560,white,font)
    screen.DrawText("Download "+a_word,755,560,white,small_font) 
    screen.DrawText("Free Now!", 755,610,white,small_font)
    screen.DrawText("Loading Video...", 765,250,white,small_font)
    screen.DrawObject(1000,610,bm_arrow_right) 
    screen.DrawObject(160+45,605,bm_button_replay_1)
    screen.DrawObject(160+285,605,bm_button_menu_0)
    screen.DrawObject(1121,580,bm_qr_retaliate) 
    screen.DrawObject(1121,220,bm_qr_twitter) 
    screen.DrawObject(1121,40,bm_qr_facebook)
    screen.DrawObject(1121,400,bm_qr_youtube)   
    screen.swapbuffers()
    'print results.score
    'print results.table
    'print results.difficulty
    
    'Play Video
    video=CreateObject("roVideoPlayer") 
    bitrates  = [0] 
    promoarray = getPromoArray()
    rndurl = rnd(promoarray.Count())-1
    qualities = ["HD"]
    streamformat = "mp4" 
    url = [promoarray[rndurl]]
    videoclip = CreateObject("roAssociativeArray")
    videoclip.StreamBitrates = bitrates
    videoclip.StreamUrls = url
    videoclip.StreamQualities = qualities
    videoclip.StreamFormat = StreamFormat
    if display_mode = "HDTV"
        targetrect = { x: 760, y: 35, w: 300, h: 500 }
    else
        targetrect = { x: 428, y: 23, w: 168, h: 333 }
    end if
    video.SetMessagePort(port)
    video.SetDestinationRect(targetrect)
    video.addContent(videoclip)
    video.Play()
    
    'Get and post scores
    'Just in case my VPS IP would need to change, I'm getting the location from a file on my website.
    prefix = GetVPSLocation()
    score_array = GetScores(results,prefix)
    if results.score > score_array[score_array.Count()-1].score.toint()
        if info <> invalid
            url = prefix+"publish_score.php?table="+results.table+"&firstname="+UCase(Left(info.firstname, 1))+LCase(Mid(info.firstname,2))+"&lastinitial="+UCase(left(info.lastname,1))+"&score="+mid(str(results.score), 2)
            'Authentication credentials have been removed to prevent open source variants from posting scores.
            http = NewHttpWithAuth(url)
            http.GetToStringWithRetry() 
            score_array = GetScores(results,prefix)
        end if
    end if
    
    'Fill both buffers with the main portion of the screen.
    for a = 0 to 1
        screen.Clear(black)
        screen.DrawObject(160,0,region_background)
        highscore_table_y = 80
        position = 0
        for each item in score_array
            position = position +1 
            if position < 10
                screen.DrawText(str(position)+".   "+item.name,160+50,highscore_table_y,white,small_font)
            else
                screen.DrawText(str(position)+". "+item.name,160+50,highscore_table_y,white,small_font)
            end if
            screen.DrawText(item.score,680-small_font.GetOneLineWidth(item.score,1000) ,highscore_table_y,white,small_font)
            highscore_table_y = highscore_table_y+42
        end for
        screen.DrawRect(156,0,4,720,white)
        screen.DrawRect(1280-164,0,4,720,white)
        screen.DrawText("Highscores - "+difficulty_text,460-(font.GetOneLineWidth("Highscores - "+difficulty_text,1000)/2),35,white,font)
        screen.DrawText("Great Job, You Scored",160+70,510,white,font)
        screen.DrawText(str(results.score)+" Points!",460-(font.GetOneLineWidth(str(results.score)+" Points!",1000)/2),560,white,font)
        screen.DrawText("Download "+a_word,755,560,white,small_font) 
        screen.DrawText("Free Now!", 755,610,white,small_font)
        screen.DrawObject(1121,580,bm_qr_retaliate) 
        screen.DrawObject(1121,220,bm_qr_twitter) 
        screen.DrawObject(1121,40,bm_qr_facebook)
        screen.DrawObject(1121,400,bm_qr_youtube) 
        screen.swapbuffers()
    end for  
    

    while (true)
        msg = wait(1, port) 
        if (type(msg) = "roUniversalControlEvent")
            'print "appRoScreen  index = "; msg.GetInt()
            code = msg.GetInt()
            if code = 0 'back pressed
                snd_move.Trigger(55)
                return false
            else if code = 4 'left pressed
                if index > 0 
                    snd_move.Trigger(55)
                    index = index-1
                end if
            else if code = 5 'right pressed
                if index < 1
                    snd_move.Trigger(55)
                    index = index+1
                end if
            else if code = 7 'replay pressed
                snd_move.Trigger(55)
                return true
            else if code = 6 'select pressed
                snd_move.Trigger(55)
                if index = 0 
                    return true
                else 
                    return false
                    
                end if
            end if
        end if
        
    'Draw screen
    screen.DrawRect(160,600,956,120,black2)
    screen.DrawText("Free Now!", 755,610,white,small_font)
    if index = 0
        screen.DrawObject(160+45,605,bm_button_replay_1)
        screen.DrawObject(160+285,605,bm_button_menu_0)
    else
        screen.DrawObject(160+45,605,bm_button_replay_0)
        screen.DrawObject(160+285,605,bm_button_menu_1)
    end if
    if arrow_move = 1
        arrow_x = linear_tween(980, 1020, timer.TotalMilliseconds(), 500)
        if arrow_x >= 1020
            arrow_move = 0
            timer.Mark()
        end if
    else 
        arrow_x = linear_tween(1020, 980, timer.TotalMilliseconds(), 500)
        if arrow_x <= 980
            arrow_move = 1
            timer.Mark()
        end if
    end if
    screen.DrawObject(arrow_x,610,bm_arrow_right) 
    screen.swapbuffers()
    end while
    
    
End Function

Function GetScores(results,prefix)
    score_array = CreateObject("roArray",10,true)
    url = prefix+"get_score.php?table="+results.table
    http = NewHttp(url)
    rsp = http.GetToStringWithRetry() 
    xml=CreateObject("roXMLElement")
    if not xml.Parse(rsp) then
        print "Can't parse feed"
    endif
    scoretable = []
    'print xml.GetName()
    'print xml.GetBody()
    'print xml.GetChildElements()
    childelements = xml.GetChildElements()
    for each item in childelements
        o = CreateObject("roAssociativeArray")
        o.name = item.name.GetText()
        o.score = item.score.GetText()
        'Print o.name
        'print o.score
        score_array.Push(o)
    next
    return score_array
End Function

Function getPromoArray()
    promoarray = CreateObject("roArray",100,true)
    http = NewHttp("http://s3.amazonaws.com/roku-retaliate-channel/promovideos.xml")
    rsp = http.GetToStringWithRetry() 
    xml=CreateObject("roXMLElement")
    if not xml.Parse(rsp) then
         print "Can't parse feed"
    endif
    'print xml.GetName()
    'print xml.GetBody()
    'print xml.GetChildElements()
    childelements = xml.GetChildElements()
    for each video in childelements
        promoarray.push(video@URL)
    end for
    return promoarray
End Function

Function GetVPSLocation()
    http = NewHttp("http://retaliate-game.com/roku_vps_location.html")
    prefix = http.GetToStringWithRetry() 
    prefix = Left(prefix, len(prefix)-1)
    return prefix
End Function

