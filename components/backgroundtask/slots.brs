Function EndTimeUTCFunction()  ' As roDateTime
    time = CreateObject("roDateTime")
    time.FromSeconds(m.startTimeUTC.AsSeconds() + m.duration)
    return time
End Function

Function HasStartedFunction() as boolean
    return m.StartTimeUTC.AsSeconds() <= getNowUTC().AsSeconds()
End Function

Function FormatStartTimeLocalFunction() as string
    copiedTime = CreateObject("roDateTime")
    copiedTime.FromSeconds(m.startTimeSecondsUTC)
    copiedTime.ToLocalTime()

    h = copiedTime.GetHours()
    m = copiedTime.GetMinutes()
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
    s = h.ToStr() + ":" + ms
    return s + ampm + " (" + tzname() + ")"
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
    }
End function
