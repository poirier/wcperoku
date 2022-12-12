
function setupAudioNode(self) as Dynamic
    audio = createObject("roSGNode", "Audio")
    audiocontent = createObject("RoSGNode", "ContentNode")
    audiocontent.Url = "http://playerservices.streamtheworld.com/api/livestream-redirect/WCPE_FM_ADP.aac"
    audiocontent.Title = "The Classical Station"
    audiocontent.TextOverlayUL = "Upper left"
    audiocontent.IgnoreStreamErrors = true
    ' Failed experiment to get Icecast data with the stream.
    ' (The stream has it, but assuming this was setting the request
    ' header as expected, the Roku doesn't see the data.)
    ' audiocontent.HttpHeaders = ["Icy-MetaData:1"]

    audio.content = audiocontent
    audio.loop = true
    'audio.timedMetaDataSelectionKeys = ["*"]

    audio.observeField("state", "onAudioStateChange")
    'audio.observeField("timedMetaData", "onTimedMetaData")
    self.appendChild(audio)
    audio.control = "play"
    return audio
end function

sub bufferingTimerExpired()
    ' still buffering
    'print "Buffering timer expired"
    if m.audio.state = "buffering" then
        print "We were still (or again) buffering. Restart the audio player."
        m.audio.control = "stop"
        m.audio.control = "none"
        m.audio.control = "play"
    'else
    '    print "Audio state was ";m.audio.state;" so not doing anything."
    end if
end sub

'sub onTimedMetaData()
'    print "on timed meta data"
'    print m.audio.timedMetaData
'end sub

sub onAudioStateChange()
    'print "audio state change to ";m.audio.state
    bufferingTimer = m.bufferingTimer
    if m.audio.state = "buffering" and bufferingTimer.control <> "start" then
        ' start a timer to limit how long we allow buffering to continue
        bufferingTimer.control = "start"
        'print "Started buffering timer"
        ' nothing else to do right now
        return
    end if
    if m.audio.state <> "buffering" and bufferingTimer.control = "start" then
        ' we're not buffering anymore, stop the timer
        bufferingTimer.control = "stop"
        'print "Stopped buffering timer"
    end if
    if (m.audio.state = "error") then
        print "Audio error: ";m.audio.errorMsg
        m.audio.control = "none"
        m.audio.control = "play"
    end if
    ' What to do when the audio stream seems to hang, but the state doesn't change to "error"?
    ' At least once I saw the state change to "buffering" then just sit there. So maybe try
    ' just "hitting play" when the state is buffering?
    'if m.audio.state = "buffering" then
    '    m.audio.control = "play"
    'else if (m.audio.state <> "buffering" and m.audio.state <> "playing" and m.stopped_manually <> true) then
    '    ' It stopped for some reason other than the user hitting "PLAY".
    '    ' Try to start it again.
    '    m.audio.control = "play"
    'end if
end sub
