
Function GetTextFromItem(item, name) as string
    s = item.GetNamedElements(name).GetHead().GetBody()
    if s = invalid then s = ""
    return s
End Function

Function parseDuration(s)  ' int seconds
    ' Parse hh:mm:ss or mm:ss and return a duration in seconds.
    if Len(s) = 5 then
        s = "00:" + s
    end if
    hours = Val(Mid(s, 1, 2), 10)
    minutes = Val(Mid(s, 4, 2), 10)
    seconds = Val(Mid(s, 7, 2), 10)
    return hours * 3600 + minutes * 60 + seconds
End Function

Function parseProgramStartTime(s)  ' roDateTime
    ' e.g. "07/05/2022T18:40:47"
    '       000000000111111111
    '       123456789012345678
    monthString = Mid(s, 1, 2)
    dayString = Mid(s, 4, 2)
    yearString = Mid(s, 7, 4)
    hourString = Mid(s, 12, 2)
    minuteString = Mid(s, 15, 2)
    secondString = Mid(s, 18, 2)
    dateString = Substitute("{0}-{1}-{2}", yearString, monthString, dayString)
    timeString = Substitute("{0}:{1}:{2}", hourString, minuteString, secondString)
    isoString = Substitute("{0} {1}", dateString, timeString)
    date = CreateObject("roDateTime")
    date.FromISO8601String(isoString)
    return date
End Function

function GetNewSlots() as dynamic
    ' Returns {"previous": invalid | Slot, "slots": Array of Slots}
    ' array of slots might be 0-length, e.g. on errors
    print "GetNewSlots..."
    previous = invalid
    slots = CreateObject("roArray", 0, true)

    transfer = createObject("roUrlTransfer")
    transfer.setUrl("https://theclassicalstation.org/mobile/WCPE_Playlist.XML")
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    body = transfer.GetToString()
    print "Got playlist xml"
    xml = CreateObject("roXMLElement")
    if not xml.Parse(body) then
        print "PARSER ERROR!!!!!!!!!!!!!!!!!!"
        return {"previous": invalid, "slots": slots}
    end if
    items = xml.GetNamedElements("Item") ' roXMLList
    for each item in items
        slot = NewSlot()
        slot["composer"] = GetTextFromItem(item, "composer")
        slot["title"] = GetTextFromItem(item, "title")
        slot["performers"] = GetTextFromItem(item, "performers")
        slot["startTime"] = parseProgramStartTime(GetTextFromItem(item, "startTime"))
        slot["startTimeUTC"] = convertEasternTimeToUTC(slot["startTime"])
        slot["startTimeSeconds"] = slot["startTime"].AsSeconds()
        slot["startTimeSecondsUTC"] = slot["startTimeUTC"].AsSeconds()
        slot["duration"] = parseDuration(GetTextFromItem(item, "runTime"))
        if slot.IsCompleted() then
            previous = slot
        else
            slots.Push(slot)
        end if
    end for
    print "There are ";slots.Count();" uncompleted slots"
    return {"previous": previous, "slots": slots}
end function
