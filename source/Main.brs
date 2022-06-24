sub Main()
    print "in showChannelSGScreen"
    'Indicate this is a Roku SceneGraph application'
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    'Create a scene and load /components/theclassicalstation.xml'
    scene = screen.CreateScene("TheClassicalStation")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub

' https://developer.roku.com/docs/references/scenegraph/media-playback-nodes/audio.md
' https://github.com/rokudev/samples/tree/master/media/AudioExample
