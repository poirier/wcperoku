Function GetTextFromItem(item, name) as string
    s = item.GetNamedElements(name).GetHead().GetBody()
    if s = invalid then s = ""
    return s
End Function

function dateToURL(date)
    ' Return URL of the given date's playlist in XML
    s = date.ToISOString()
    ' "2021-03-25T18:53:03+0000"
    y4 = Mid(s, 1, 4)
    y2 = Mid(s, 3, 2)
    m = Mid(s, 6, 2)
    d = Mid(s, 9, 2)
    ' https://theclassicalstation.org/wp-content/uploads/2022/07/07_13_22_PL.xml
    return "https://theclassicalstation.org/wp-content/uploads/" + y4 + "/" + m + "/" + m + "_" + d + "_" + y2 + "_PL.xml"
end function

function urlsToTryDownloading()
    ' URLs for today's and tomorrow's playlists
    now = CreateObject("roDateTime")
    url1 = dateToURL(now)
    now.FromSeconds(now.AsSeconds() + 24 * 3600)
    url2 = dateToURL(now)

    return [url1, url2]
end function

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

sub downloadURLandAddToSlots(url, slots)
    transfer = createObject("roUrlTransfer")
    print "URL=";url
    'transfer.setUrl("https://theclassicalstation.org/mobile/WCPE_Playlist.XML")
    transfer.setUrl(url)
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    ' It'd be simpler to use GetToString(), but that loses the return status.
    returnCode = transfer.GetToFile("tmp:/playlist.xml")
    print "Fetch returned " + returnCode.ToStr()
    if returnCode <> 200 then
        return
    end if
    body = ReadASCIIFile("tmp:/playlist.xml")  ' handles UTF-8 too, not just ASCII
    CreateObject("roFileSystem").Delete("tmp:/playlist.xml")

    print "Length of XML is " + body.Len().ToStr()

    print "Got playlist xml from " + url
    xml = CreateObject("roXMLElement")
    if not xml.Parse(body) then
        print "PARSER ERROR!!!!!!!!!!!!!!!!!!"
        return
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
        slots.Push(slot)
    end for
end sub

function GetNewSlots() as dynamic
    ' Returns {"previous": invalid | Slot, "slots": Array of Slots}
    ' array of slots might be 0-length, e.g. on errors
    print "GetNewSlots..."
    slots = CreateObject("roArray", 0, true)
    for each url in urlsToTryDownloading()
        downloadURLandAddToSlots(url, slots)
    end for

    print "There are ";slots.Count();" slots"
    return slots
end function
