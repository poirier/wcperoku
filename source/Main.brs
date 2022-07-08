function Main() as Void
    port = CreateObject("roMessagePort")

    devInfo = CreateObject("roDeviceInfo")
    devInfo.SetMessagePort(port)
    devInfo.EnableLinkStatusEvent(true)
    devInfo.EnableInternetStatusEvent(true)
    print "GetDisplaySize=";devInfo.GetDisplaySize()
    print "GetVideoMode=";devInfo.GetVideoMode()
    print "GetSupportedGraphicsResolutions=";devInfo.GetSupportedGraphicsResolutions()
    print "GetUIResolution=";devInfo.GetUIResolution()


    screen = CreateObject("roSGScreen")
    ' <Component: roSGScreen> https://developer.roku.com/docs/references/brightscript/components/rosgscreen.md
    ' https://developer.roku.com/docs/references/brightscript/interfaces/ifsgscreen.md

    screen.setMessagePort(port)

    scene = screen.CreateScene("TheClassicalStation")
    ' <Component: roSGNode:TheClassicalStation>
    ' https://developer.roku.com/docs/references/brightscript/components/rosgnode.md

    scene.portarray = [port]

    screen.show()

    scene.signalBeacon("AppLaunchComplete")

    while(true)
        msg = wait(0, port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent" then
            if msg.isScreenClosed() then return
        else if msgType = "roDeviceInfoEvent" then
            print "roDeviceInfoEvent=";msg.GetInfo()
        else
            print "Unhandled event type=";msgType;" msg=";msg
        end if
    end while
end function
