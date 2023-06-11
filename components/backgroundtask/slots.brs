Function EndTimeUTCFunction()  ' As roDateTime
    time = CreateObject("roDateTime")
    time.FromSeconds(m.startTimeUTC.AsSeconds() + m.duration)
    return time
End Function

Function HasStartedFunction() as boolean
    return m.StartTimeUTC.AsSeconds() <= getNowUTC().AsSeconds()
End Function


Function FormatSomeTimeLocalFunction(timeSecondsUTC, includeTimeZone) as string
    copiedTime = CreateObject("roDateTime")
    copiedTime.FromSeconds(timeSecondsUTC)
    copiedTime.ToLocalTime()
    h = copiedTime.GetHours()
    m = copiedTime.GetMinutes()
    secs = copiedTime.GetSeconds()
    ampm = ""

    if userWants12HourTimeFormat() then
        if h = 0 then
            h = 12
            ampm = " AM"
        else if h < 12 then
            ampm = " AM"
        else if h = 12
            ampm = " PM"
        else
            ampm = " PM"
            h = h - 12
        end if
    end if

    ms = m.ToStr()
    if m < 10 then ms = "0" + ms

    if secs < 10 then
      secs = "0" + secs.ToStr()
    else
      secs = secs.ToStr()
    endif
    ' s = h.ToStr() + ":" + ms + ":" + secs
    s = h.ToStr() + ":" + ms
    if includeTimeZone then
      return s + ampm + " (" + tzname() + ")"
    else
      return s + ampm
    end if
End Function

Function FormatEndTimeLocalFunction(includeTimeZone) as string
    return FormatSomeTimeLocalFunction(m.startTimeSecondsUTC + m.duration, includeTimeZone)
End function

Function FormatStartTimeLocalFunction(includeTimeZone) as string
    return FormatSomeTimeLocalFunction(m.startTimeSecondsUTC, includeTimeZone)
end function

Function IsCompletedFunction() as boolean
    return m.EndTimeUTC().AsSeconds() < getNowUTC().AsSeconds()
End Function

Function NewSlot()
    return {
        EndTimeUTC: EndTimeUTCFunction
        IsCompleted: IsCompletedFunction
        HasStarted: HasStartedFunction
        FormatStartTimeLocal: FormatStartTimeLocalFunction
        FormatEndTimeLocal: FormatEndTimeLocalFunction
    }
End function
