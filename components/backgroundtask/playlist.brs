Function GetTextFromItem(item, name) as string
    ' item: roXMLElement
    ' name: string
    s = item.GetNamedElements(name).GetHead().GetBody()
    if s = invalid then s = ""
    return s
End Function

function dateToURL(date)
    ' Return URL of the given date's playlist in XML
    ' Should look like https://theclassicalstation.org/MM_DD_YY_PL
    s = date.ToISOString()
    ' "2021-03-25T18:53:03+0000"
    y2 = Mid(s, 3, 2)  ' e.g. "21"
    m = Mid(s, 6, 2)  ' e.g. "03"
    d = Mid(s, 9, 2)  ' e.g. "25"
    return "https://theclassicalstation.org/" + m + "_" + d + "_" + y2 + "_PL"
end function

function urlsToTryDownloading()
    ' return ["https://theclassicalstation.org/mobile/WCPE_Playlist.XML"]

    ' URLs for today's and tomorrow's playlists
    now = getNowInEasternTime()
    url1 = dateToURL(now)
    now.FromSeconds(now.AsSeconds() + 24 * 3600)
    url2 = dateToURL(now)

    return [url1, "https://theclassicalstation.org/mobile/WCPE_Playlist.XML", url2]
end function

Function parseDuration(s)  ' integer seconds
    ' Parse hh:mm:ss or mm:ss and return a duration in seconds.
    if Len(s) = 5 then
        s = "00:" + s
    end if
    hours = Val(Mid(s, 1, 2), 10)
    minutes = Val(Mid(s, 4, 2), 10)
    seconds = Val(Mid(s, 7, 2), 10)
    return hours * 3600 + minutes * 60 + seconds
End Function

Function parseProgramStartTime(s)  ' roDateTime, in Eastern time
    ' The start time in the playlist XML looks like the following:
    ' e.g. "07/05/2022T18:40:47"
    '       000000000111111111
    '       123456789012345678
    ' We know it's always in Eastern time.
    ' Parse it and return an roDateTime object that represents that time
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

function downloadURLandAddToSlots(url, slots)  ' returns TRUE if url downloaded and added to slots
    transfer = createObject("roUrlTransfer")
    'print "Fetching URL=";url
    transfer.setUrl(url)
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    ' It'd be simpler to use GetToString(), but that loses the return status.
    returnCode = transfer.GetToFile("tmp:/playlist.xml")
    if returnCode <> 200 then
        print "Fetching " + url + " returned " + returnCode.ToStr()
        return false
    end if
    body = ReadASCIIFile("tmp:/playlist.xml")  ' handles UTF-8 too, not just ASCII
    CreateObject("roFileSystem").Delete("tmp:/playlist.xml")

    'print "Length of XML is " + body.Len().ToStr()
    'print "Got playlist xml from " + url
    xml = CreateObject("roXMLElement")
    if not xml.Parse(body) then
        print "PARSER ERROR!!!!!!!!!!!!!!!!!!"
        return false
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
    return true
end function

function GetNewSlots() as dynamic
    ' Returns {"previous": invalid | Slot, "slots": Array of Slots}
    ' array of slots might be 0-length, e.g. on errors
    'print "GetNewSlots..."
    slots = CreateObject("roArray", 0, true)
    for each url in urlsToTryDownloading()
        if downloadURLandAddToSlots(url, slots) then
          exit for
        end if
    end for

    ' SortBy(fieldName as String, flags as String = "") as Void
    ' Description
    ' Performs a stable sort of an array of associative arrays by value of a common field.
    slots.SortBy("startTimeSecondsUTC")

    'print "There are ";slots.Count();" slots"
    return slots
end function
