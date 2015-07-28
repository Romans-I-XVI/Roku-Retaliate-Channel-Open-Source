'Linear Tween Function
Function linear_tween(start_pos, finish_pos, currentTime, duration)
    If currentTime > duration Then Return finish_pos
    change = finish_pos - start_pos
    time = currentTime / duration
    Return change * time + start_pos
End Function

Function swap_audio_channel()
    if m.audio_channel = 0
        m.audio_channel = 1
    else
        m.audio_channel = 0
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

Function HSVAtoRGBA(h%,s%,v%,a%) As Integer
   ' Romans_I_XVI port (w/ a few tweaks) of:
   ' http://schinckel.net/2012/01/10/hsv-to-rgb-in-javascript/
   
   h% = h% MOD 360
   
   rgb = [ 0, 0, 0 ]
   if s% = 0 then
      rgb = [v%/100, v%/100, v%/100]
   else
      s = s%/100 : v = v%/100 : h = h%/60 : i = int(h)

      data = [v*(1-s), v*(1-s*(h-i)), v*(1-s*(1-(h-i)))]
      
      if i = 0 then
         rgb = [v, data[2], data[0]]
      else if i = 1 then
         rgb = [data[1], v, data[0]]   
      else if i = 2 then
         rgb = [data[0], v, data[2]]
      else if i = 3 then
         rgb = [data[0], data[1], v]
      else if i = 4 then
         rgb = [data[2], data[0], v]
      else
         rgb = [v, data[0], data[1]]
      end if
   end if

   for c = 0 to rgb.count()-1 : rgb[c] = int(rgb[c] * 255) : end for
   color% = (rgb[0] << 24) + (rgb[1] << 16) + (rgb[2] << 8) + a%

   return color%
End Function

Function get_user_purchases() as boolean
    port = CreateObject("roMessagePort")
    store = CreateObject("roChannelStore")
    store.SetMessagePort(port)
    store.GetPurchases()
    while (true)
        msg = wait(5000, port)
        if (type(msg) = "roChannelStoreEvent")
            if (msg.isRequestSucceeded())
                purchases = msg.GetResponse()
                if purchases.Count() > 0
                    m.paid = true
                end if
                return true
            else if (msg.isRequestFailed())
                return false
                'print "***** Failure: *******"
            end if
        end if
    end while
End Function

Function GetVPSLocation()
    http = NewHttp("http://retaliate-game.com/roku/roku_vps_location.html")
    prefix = http.GetToStringWithRetry() 
    'prefix = Left(prefix, len(prefix)-1)
    prefix = prefix.Trim()
    return prefix
End Function

Function GetAdInterval()
    http = NewHttp("http://retaliate-game.com/roku/roku_ad_interval.html")
    interval = http.GetToStringWithRetry() 
    'interval = Left(interval, len(interval)-1)
    interval = interval.Trim()
    interval = interval.toint()
    return interval
End Function
