Function ScoreScreen(screen,port,results,info)
    'Set Variables
    filesystem = CreateObject("roFileSystem")
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
    bm_double_arrow_right = CreateObject("roBitmap", "pkg:/sprites/spr_double_arrow_right.png")
    bm_double_arrow_left = CreateObject("roBitmap", "pkg:/sprites/spr_double_arrow_left.png")
    bm_button_replay_0 = CreateObject("roBitmap", "pkg:/sprites/spr_button_replay_0.png")
    bm_button_replay_1 = CreateObject("roBitmap", "pkg:/sprites/spr_button_replay_1.png")
    bm_button_menu_0 = CreateObject("roBitmap", "pkg:/sprites/spr_button_menu_0.png")
    bm_button_menu_1 = CreateObject("roBitmap", "pkg:/sprites/spr_button_menu_1.png")
    region_background = CreateObject("roRegion", m.bm_background,0,0,590,720)
    
    'Create Sounds
    snd_move = CreateObject("roAudioResource", "navsingle")
    
    'Display ad if applicable
    'print m.ad_timer.TotalMilliseconds()
    if m.paid = false and m.ad_timer.TotalMilliseconds() >= m.ad_interval
        'Start do something to display ads
        adIface = Roku_Ads()
        ' Ad URL has been removed
        adIface.setAdUrl("Your Ad URL Here")
        adIface.setAdExit(false)
        adPods = adIface.getAds()
        shouldPlayContent = adIface.showAds(adPods)
        'End do something to display ads
        m.ad_timer.Mark()
        UpgradeScreen(screen,port)
    end if
    
    'Create Initial Screen
    screen.Clear(black)
    screen.DrawObject(160,0,region_background)
    screen.DrawRect(156,0,4,720,white)
    screen.DrawRect(1280-160,0,4,720,white)
    screen.DrawText("Loading...",460-(font.GetOneLineWidth("Loading...",1000)/2),250,white,font)
    if results.score > 0
        screen.DrawText("Great Job, You Scored",160+70,520,white,font)
    else
        screen.DrawText("Say What!? You Scored",160+60,520,white,font)
    end if
    screen.DrawText(str(results.score)+" Points!",460-(font.GetOneLineWidth(str(results.score)+" Points!",1000)/2),560,white,font)
    screen.DrawObject(160+45,605,bm_button_replay_1)
    screen.DrawObject(160+285,605,bm_button_menu_0)
    screen.swapbuffers()
    'print results.score
    'print results.table
    'print results.difficulty

    if filesystem.Exists("tmp:/promo_image.png")
        filesystem.Delete("tmp:/promo_image.png")
    end if
    'Show Image
    promo_type = "none"
    promoarray = getPromoArray()
    if promoarray <> invalid
        rnd_promo_item = rnd(promoarray.Count())-1
        path = CreateObject("roPath", promoarray[rnd_promo_item].url)
        parts = path.Split()
        if parts.extension = ".png"
            promo_type = "image"
            http = NewHttp(promoarray[rnd_promo_item].url)
            http.Http.GetToFile("tmp:/promo_image.png") 
        end if
        if parts.extension = ".mp4"
            image = getImageWithVideo()
            promo_type = "video"
            http = NewHttp(image.url)
            http.Http.GetToFile("tmp:/promo_image.png") 
            video=CreateObject("roVideoPlayer")
            bitrates = [0]
            qualities = ["HD"]
            streamformat = "mp4"
            url = [promoarray[rnd_promo_item].url]
            videoclip = CreateObject("roAssociativeArray")
            videoclip.StreamBitrates = bitrates
            videoclip.StreamUrls = url
            videoclip.StreamQualities = qualities
            videoclip.StreamFormat = StreamFormat
            if display_mode = "HDTV"
                x = promoarray[rnd_promo_item].x
                y = promoarray[rnd_promo_item].y
                w = promoarray[rnd_promo_item].w
                h = promoarray[rnd_promo_item].h
                targetrect = { x: x, y: y, w: w, h: h }
            else
                'print "SD"
                x = int(promoarray[rnd_promo_item].x*0.56)
                y = int(promoarray[rnd_promo_item].y*0.66)
                w = int(promoarray[rnd_promo_item].w*0.56)
                h = int(promoarray[rnd_promo_item].h*0.66)
                targetrect = { x: x, y: y, w: w, h: h }
            end if
            video.SetMessagePort(port)
            video.SetDestinationRect(targetrect)
            video.addContent(videoclip)
            video.Play()
        end if
    end if
    
    'Get and post scores
    score_array = GetScores(results,m.prefix)
    if score_array <> invalid
        for each key in score_array
            if score_array[key].Count() < 10
                if info <> invalid and results.score > 0
                    if key <> "alltime"
                        url = m.prefix+"publish_score.php?table="+results.table+"_"+key+"&firstname="+UCase(Left(info.firstname, 1))+LCase(Mid(info.firstname,2))+"&lastinitial="+UCase(left(info.lastname,1))+"&score="+mid(str(results.score), 2)
                    else
                        url = m.prefix+"publish_score.php?table="+results.table+"&firstname="+UCase(Left(info.firstname, 1))+LCase(Mid(info.firstname,2))+"&lastinitial="+UCase(left(info.lastname,1))+"&score="+mid(str(results.score), 2)
                    end if
                    http = NewHttpWithAuth(url)
                    http.GetToStringWithRetry() 
                    score_array = GetScores(results,m.prefix)
                end if
            else if results.score > score_array[key][score_array[key].Count()-1].score.toint()
                if info <> invalid
                    if key <> "alltime"
                        url = m.prefix+"publish_score.php?table="+results.table+"_"+key+"&firstname="+UCase(Left(info.firstname, 1))+LCase(Mid(info.firstname,2))+"&lastinitial="+UCase(left(info.lastname,1))+"&score="+mid(str(results.score), 2)
                    else
                        url = m.prefix+"publish_score.php?table="+results.table+"&firstname="+UCase(Left(info.firstname, 1))+LCase(Mid(info.firstname,2))+"&lastinitial="+UCase(left(info.lastname,1))+"&score="+mid(str(results.score), 2)
                    end if
                    http = NewHttpWithAuth(url)
                    http.GetToStringWithRetry() 
                    score_array = GetScores(results,m.prefix)
                end if
            end if
         end for
    end if
    
    'Fill both buffers with the main portion of the screen.
    for a = 0 to 1
        screen.Clear(black)
        screen.DrawObject(160,0,region_background)
        highscore_table_y = 120
        position = 0
        if score_array <> invalid
            for each item in score_array[m.active_score_table]
                position = position +1 
                if position < 10
                    screen.DrawText(str(position)+".   "+item.name,160+50,highscore_table_y,white,small_font)
                else
                
                    screen.DrawText(str(position)+". "+item.name,160+50,highscore_table_y,white,small_font)
                end if
                screen.DrawText(item.score,680-small_font.GetOneLineWidth(item.score,1000) ,highscore_table_y,white,small_font)
                highscore_table_y = highscore_table_y+39
            end for
        end if
        screen.DrawRect(156,0,4,720,white)
        screen.DrawRect(1280-164,0,4,720,white)
        screen.DrawObject(460+120,35,bm_double_arrow_right)
        screen.DrawObject(460-120-64,35,bm_double_arrow_left)
        if m.active_score_table = "alltime"
            screen.DrawText("All Time",460-(font.GetOneLineWidth("All Time",1000)/2),35,white,font)
            screen.DrawRect(460-(font.GetOneLineWidth("All Time",1000)/2),75,font.GetOneLineWidth("All Time",1000),2,white)
        else if m.active_score_table = "daily"
            screen.DrawText("Today",460-(font.GetOneLineWidth("Today",1000)/2),35,white,font)
            screen.DrawRect(460-(font.GetOneLineWidth("Today",1000)/2),75,font.GetOneLineWidth("Today",1000),2,white)
        else if m.active_score_table = "weekly"
            screen.DrawText("This Week",460-(font.GetOneLineWidth("This Week",1000)/2),35,white,font)
            screen.DrawRect(460-(font.GetOneLineWidth("This Week",1000)/2),75,font.GetOneLineWidth("This Week",1000),2,white)
        end if
        screen.DrawText("Highscores - "+difficulty_text,460-(font.GetOneLineWidth("Highscores - "+difficulty_text,1000)/2),75,white,font)
        if results.score > 0
            screen.DrawText("Great Job, You Scored",160+70,520,white,font)
        else
            screen.DrawText("Say What!? You Scored",160+60,520,white,font)
        end if
        screen.DrawText(str(results.score)+" Points!",460-(font.GetOneLineWidth(str(results.score)+" Points!",1000)/2),560,white,font)
        if promo_type = "image"
            if filesystem.Exists("tmp:/promo_image.png")
                dfDrawImage(screen, "tmp:/promo_image.png", promoarray[rnd_promo_item].x, promoarray[rnd_promo_item].y)
            end if
        end if
        if promo_type = "video"
            if filesystem.Exists("tmp:/promo_image.png") and image <> invalid
                dfDrawImage(screen, "tmp:/promo_image.png", image.x, image.y)
            end if
        end if
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
            else if code = 8 'rewind pressed
                snd_move.Trigger(55)
                if m.active_score_table = "alltime"
                    m.active_score_table = "daily"
                else if m.active_score_table = "daily"
                    m.active_score_table = "weekly"
                else if m.active_score_table = "weekly"
                    m.active_score_table = "alltime"
                end if
                for a = 0 to 1
                    screen.Clear(black)
                    screen.DrawObject(160,0,region_background)
                    highscore_table_y = 120
                    position = 0
                    if score_array <> invalid
                        for each item in score_array[m.active_score_table]
                            position = position +1 
                            if position < 10
                                screen.DrawText(str(position)+".   "+item.name,160+50,highscore_table_y,white,small_font)
                            else
                            
                                screen.DrawText(str(position)+". "+item.name,160+50,highscore_table_y,white,small_font)
                            end if
                            screen.DrawText(item.score,680-small_font.GetOneLineWidth(item.score,1000) ,highscore_table_y,white,small_font)
                            highscore_table_y = highscore_table_y+39
                        end for
                    end if
                    screen.DrawRect(156,0,4,720,white)
                    screen.DrawRect(1280-164,0,4,720,white)
                    screen.DrawObject(460+120,35,bm_double_arrow_right)
                    screen.DrawObject(460-120-64,35,bm_double_arrow_left)
                    if m.active_score_table = "alltime"
                        screen.DrawText("All Time",460-(font.GetOneLineWidth("All Time",1000)/2),35,white,font)
                        screen.DrawRect(460-(font.GetOneLineWidth("All Time",1000)/2),75,font.GetOneLineWidth("All Time",1000),2,white)
                    else if m.active_score_table = "daily"
                        screen.DrawText("Today",460-(font.GetOneLineWidth("Today",1000)/2),35,white,font)
                        screen.DrawRect(460-(font.GetOneLineWidth("Today",1000)/2),75,font.GetOneLineWidth("Today",1000),2,white)
                    else if m.active_score_table = "weekly"
                        screen.DrawText("This Week",460-(font.GetOneLineWidth("This Week",1000)/2),35,white,font)
                        screen.DrawRect(460-(font.GetOneLineWidth("This Week",1000)/2),75,font.GetOneLineWidth("This Week",1000),2,white)
                    end if
                    screen.DrawText("Highscores - "+difficulty_text,460-(font.GetOneLineWidth("Highscores - "+difficulty_text,1000)/2),75,white,font)
                    if results.score > 0
                        screen.DrawText("Great Job, You Scored",160+70,520,white,font)
                    else
                        screen.DrawText("Say What!? You Scored",160+60,520,white,font)
                    end if
                    screen.DrawText(str(results.score)+" Points!",460-(font.GetOneLineWidth(str(results.score)+" Points!",1000)/2),560,white,font)
                    if promo_type = "image"
                        if filesystem.Exists("tmp:/promo_image.png")
                            dfDrawImage(screen, "tmp:/promo_image.png", promoarray[rnd_promo_item].x, promoarray[rnd_promo_item].y)
                        end if
                    end if
                    if promo_type = "video"
                        if filesystem.Exists("tmp:/promo_image.png") and image <> invalid
                            dfDrawImage(screen, "tmp:/promo_image.png", image.x, image.y)
                        end if
                    end if
                    screen.DrawRect(160,600,540,120,black2)
                    if index = 0
                        screen.DrawObject(160+45,605,bm_button_replay_1)
                        screen.DrawObject(160+285,605,bm_button_menu_0)
                    else
                        screen.DrawObject(160+45,605,bm_button_replay_0)
                        screen.DrawObject(160+285,605,bm_button_menu_1)
                    end if
                    screen.swapbuffers()
                end for  
            else if code = 9 'fastforward pressed
                snd_move.Trigger(55)
                if m.active_score_table = "alltime"
                    m.active_score_table = "weekly"
                else if m.active_score_table = "weekly"
                    m.active_score_table = "daily"
                else if m.active_score_table = "daily"
                    m.active_score_table = "alltime"
                end if
                for a = 0 to 1
                    screen.Clear(black)
                    screen.DrawObject(160,0,region_background)
                    highscore_table_y = 120
                    position = 0
                    if score_array <> invalid
                        for each item in score_array[m.active_score_table]
                            position = position +1 
                            if position < 10
                                screen.DrawText(str(position)+".   "+item.name,160+50,highscore_table_y,white,small_font)
                            else
                            
                                screen.DrawText(str(position)+". "+item.name,160+50,highscore_table_y,white,small_font)
                            end if
                            screen.DrawText(item.score,680-small_font.GetOneLineWidth(item.score,1000) ,highscore_table_y,white,small_font)
                            highscore_table_y = highscore_table_y+39
                        end for
                    end if
                    screen.DrawRect(156,0,4,720,white)
                    screen.DrawRect(1280-164,0,4,720,white)
                    screen.DrawObject(460+120,35,bm_double_arrow_right)
                    screen.DrawObject(460-120-64,35,bm_double_arrow_left)
                    if m.active_score_table = "alltime"
                        screen.DrawText("All Time",460-(font.GetOneLineWidth("All Time",1000)/2),35,white,font)
                        screen.DrawRect(460-(font.GetOneLineWidth("All Time",1000)/2),75,font.GetOneLineWidth("All Time",1000),2,white)
                    else if m.active_score_table = "daily"
                        screen.DrawText("Today",460-(font.GetOneLineWidth("Today",1000)/2),35,white,font)
                        screen.DrawRect(460-(font.GetOneLineWidth("Today",1000)/2),75,font.GetOneLineWidth("Today",1000),2,white)
                    else if m.active_score_table = "weekly"
                        screen.DrawText("This Week",460-(font.GetOneLineWidth("This Week",1000)/2),35,white,font)
                        screen.DrawRect(460-(font.GetOneLineWidth("This Week",1000)/2),75,font.GetOneLineWidth("This Week",1000),2,white)
                    end if
                    screen.DrawText("Highscores - "+difficulty_text,460-(font.GetOneLineWidth("Highscores - "+difficulty_text,1000)/2),75,white,font)
                    if results.score > 0
                        screen.DrawText("Great Job, You Scored",160+70,520,white,font)
                    else
                        screen.DrawText("Say What!? You Scored",160+60,520,white,font)
                    end if
                    screen.DrawText(str(results.score)+" Points!",460-(font.GetOneLineWidth(str(results.score)+" Points!",1000)/2),560,white,font)
                    if promo_type = "image"
                        if filesystem.Exists("tmp:/promo_image.png")
                            dfDrawImage(screen, "tmp:/promo_image.png", promoarray[rnd_promo_item].x, promoarray[rnd_promo_item].y)
                        end if
                    end if
                    if promo_type = "video"
                        if filesystem.Exists("tmp:/promo_image.png") and image <> invalid
                            dfDrawImage(screen, "tmp:/promo_image.png", image.x, image.y)
                        end if
                    end if
                    screen.DrawRect(160,600,540,120,black2)
                    if index = 0
                        screen.DrawObject(160+45,605,bm_button_replay_1)
                        screen.DrawObject(160+285,605,bm_button_menu_0)
                    else
                        screen.DrawObject(160+45,605,bm_button_replay_0)
                        screen.DrawObject(160+285,605,bm_button_menu_1)
                    end if
                    screen.swapbuffers()
                end for               
            end if
        end if
    'Draw screen
    screen.DrawRect(160,600,540,120,black2)
    if index = 0
        screen.DrawObject(160+45,605,bm_button_replay_1)
        screen.DrawObject(160+285,605,bm_button_menu_0)
    else
        screen.DrawObject(160+45,605,bm_button_replay_0)
        screen.DrawObject(160+285,605,bm_button_menu_1)
    end if
    screen.swapbuffers()
    end while
    
    
End Function

Function GetScores(results,prefix)
    score_array = { daily: [], weekly: [], alltime: [] }
    for each key in score_array
        if key <> "alltime"
            url = prefix+"get_score.php?table="+results.table+"_"+key
        else
            url = prefix+"get_score.php?table="+results.table
        end if
        http = NewHttp(url)
        rsp = http.GetToStringWithRetry() 
        xml=CreateObject("roXMLElement")
        if xml.Parse(rsp)
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
                score_array[key].Push(o)
            next
        end if
    end for
    return score_array
End Function

Function getPromoArray()
    promoarray = CreateObject("roArray",100,true)
    http = NewHttp("http://retaliate-game.com/roku/promoitems.xml")
    rsp = http.GetToStringWithRetry() 
    'print rsp
    xml=CreateObject("roXMLElement")
    if not xml.Parse(rsp) then
         return invalid
    else
        childelements = xml.GetChildElements()
        for each item in childelements
            x = item@x
            y = item@y
            w = item@w
            h = item@h
            x = x.toint()
            y = y.toint()
            w = w.toint()
            h = h.toint()
            promoarray.push({url: item@URL, x: x, y: y, w: w, h: h} )
        end for
        return promoarray
    end if
    'print xml.GetName()
    'print xml.GetBody()
    'print xml.GetChildElements()
    
    'print promoarray
End Function

Function getImageWithVideo()
    http = NewHttp("http://retaliate-game.com/roku/image_with_video.xml")
    rsp = http.GetToStringWithRetry() 
    'print rsp
    xml=CreateObject("roXMLElement")
    if not xml.Parse(rsp) then
         return invalid
    else
        childelements = xml.GetChildElements()
        for each item in childelements
            x = item@x
            y = item@y
            x = x.toint()
            y = y.toint()
            image = {url: item@URL, x: x, y: y}
        end for
        return image
    end if
    'print xml.GetName()
    'print xml.GetBody()
    'print xml.GetChildElements()
End Function



