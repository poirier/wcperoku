function Main() as Void
    port = CreateObject("roMessagePort")
    screen = CreateObject("roSGScreen")
    screen.setMessagePort(port)
    scene = screen.CreateScene("TheClassicalStation")
    screen.show()

    while(true)
        msg = wait(0, port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent" then
            if msg.isScreenClosed() then return
        else
            print "Unhandled event type=";msgType
        end if
    end while
end function
