sub tzname() as string
    return CreateObject("roDeviceInfo").getTimeZone()
end sub

Function userWants12HourTimeFormat() as boolean
    di = CreateObject("roDeviceInfo")
    return di.GetClockFormat() = "12h"
End Function

function getNowUTC() as dynamic
    return CreateObject("roDateTime")
end function

function getNowInEasternTime() as dynamic
    return convertUTCToEasternTime(getNowUTC())
end function

function getNowLocal() as dynamic
    dateTime = CreateObject("roDateTime")
    dateTime.ToLocalTime()
    return dateTime
end function

function convertUTCToEasternTime(datetimeUTC) as dynamic  ' roDateTime
    ' If saving time, offset is 4 hours
    savingTime = CreateObject("roDateTime")
    savingTime.FromSeconds(datetimeUTC.AsSeconds() - 4 * 3600)
    if isEasternDaylightSavingTime(savingTime) then return savingTime
    ' If standard time, offset is 5 hours
    standardTime = CreateObject("roDateTime")
    standardTime.FromSeconds(datetimeUTC.AsSeconds() - 5 * 3600)
    return standardTime
end function

function convertEasternTimeToUTC(datetimeEastern) as dynamic ' roDateTime
    oneHour = 3600  ' seconds
    isItDaylightSavingTime = isEasternDaylightSavingTime(datetimeEastern)
    if isItDaylightSavingTime = invalid then
        offset = 4  ' punt - we might be wrong, but we won't blow up. This is the best we can do.
    else if isItDaylightSavingTime then
        offset = 4  ' Daylight Saving Time is 4 hours off
    else
        offset = 5  ' Standard Time is 5 hours off
    end if
    newTime = createObject("roDateTime")
    newTime.FromSeconds(datetimeEastern.AsSeconds() + offset * oneHour)
    return newTime
end function

sub initDateOfSecondSundayInMarch()
    g = GetGlobalAA()
    g.DateOfSecondSundayInMarch = {
        "2023": 12
        "2024": 10
        "2025": 9
        "2026": 8
        "2027": 14
        "2028": 12
        "2029": 11
        "2030": 10
        "2031": 9
        "2032": 14
    }
end sub

function dateOfSecondSundayInMarch(year) as integer
    ' return day of month when the 2nd sunday in march occurs
    g = GetGlobalAA()
    if not g.DoesExist("DateOfSecondSundayInMarch") then
        initDateOfSecondSundayInMarch()
    end if
    return g.DateOfSecondSundayInMarch[year.ToStr()]
end function

sub initDateOfFirstSundayInNovember()
    g = GetGlobalAA()
    g.DateOfFirstSundayInNovember = {
        "2022": 6
        "2023": 5
        "2024": 3
        "2025": 2
        "2026": 1
        "2027": 7
        "2028": 5
        "2029": 4
        "2030": 3
        "2031": 2
    }
end sub

function dateOfFirstSundayInNovember(year) as integer
    ' return day of month when the 1st sunday in november occurs
    g = GetGlobalAA()
    if not g.DoesExist("DateOfFirstSundayInNovember") then
        initDateOfFirstSundayInNovember()
    end if
    return g.DateOfFirstSundayInNovember[year.ToStr()]
end function

function isEasternDaylightSavingTime(datetime)  ' could be boolean, or invalid
    ' Return True if datetime is in DST in Eastern time zone
    ' Return False if it isn't
    ' Return invalid if we cannot tell
    ' Rules:
    ' Daylight Saving Time (DST) in most of the United States starts on the second Sunday in March and ends on the first Sunday in November.
    ' In 2022, Daylight Saving Time began on Sunday, March 13, 2022 at 2:00 A.M. On Saturday night, clocks are set forward
    ' one hour (i.e., losing one hour) to “spring forward.”
    ' In 2022, Daylight Saving Time ends on Sunday, November 6, 2022, at 2:00 A.M. On Saturday night, clocks are set back
    ' one hour (i.e., gaining one hour) to “fall back.”
    year = datetime.GetYear()
    month = datetime.GetMonth()  ' 1=January
    hour = datetime.GetHours()
    minute = datetime.GetMinutes()
    second = datetime.GetSeconds()
    day = datetime.GetDayOfMonth()

    if month > 3 and month < 11 then return true  ' Definitely in DST April-October
    if month < 3 or month > 11 then return false ' Definitely not DST in Jan-Feb or December
    if month = 3 then
        dateOfChange = dateOfSecondSundayInMarch(year)
        if day < dateOfChange then return false
        if day > dateOfChange then return true
        ' we have to look at the time
        if hour < 2 then return false  ' have not turned forward yet
        return true
    end if
    if month = 11 then
        dateOfChange = dateOfFirstSundayInNovember(year)
        if day < dateOfChange then return true
        if day > dateOfChange then return false
        if hour < 1 then return true  ' not 1am yet
        if hour = 2 and (minute > 0 or second > 0) then return false ' got past 2am, dst is over
        ' We're in the 2 hours between 1am and 2am, but we don't know which hour, so
        ' we don't know if the clocks have turned back yet or not.
        return invalid
    end if
    ' unreachable
end function

#if runTests
sub testisEasternDaylightSavingTime()
    utc_time = CreateObject("roDateTime")
    eastern_time = CreateObject("roDateTime")
    ' 2025-03-09 is the start of DST in 2025
    ' we spring forward at 1am standard time, which in UTC is 6am
    ' Test the time just before that (UTC offset 5 hours)
    utc_time.fromISO8601String("2025-03-09 05:59:59")
    eastern_time.FromSeconds(utc_time.AsSeconds() - 5*3600)
    assert(false = isEasternDaylightSavingTime(eastern_time), eastern_time.ToISOString() + " should not be EDT")

    ' test convertEasternTimeToUTC too
    assert(convertEasternTimeToUTC(eastern_time).AsSeconds() = utc_time.AsSeconds(), "eastern time should convert to 5:59 UTC")

    ' now test the time just after that (UTC offset 4 hours)
    utc_time.fromISO8601String("2025-03-09 06:00:01")
    eastern_time.FromSeconds(utc_time.AsSeconds() - 4*3600)
    assert(true = isEasternDaylightSavingTime(eastern_time), eastern_time.ToISOString() + " should be EDT")

    ' 2025-11-02 is the end of DST in 2025
    ' we fall back from "2am EST" to "1am EDT"
    ' which means if all we know is that the time is between 1am and 2am,
    ' we don't know if we're in the hour before we fell back, or the hour after.

    ' First try just before that, definitely . UTC offset 4 hours.
    utc_time.fromISO8601String("2025-11-02 04:59:59")  ' 4:59 UTC
    eastern_time.FromSeconds(utc_time.AsSeconds() - 4*3600)  ' 0:59 Eastern
    assert(true = isEasternDaylightSavingTime(eastern_time), eastern_time.ToISOString() + " should be EDT")

    ' Now during those hours - we can't tell
    utc_time.fromISO8601String("2025-11-02 05:00:01")  ' 5:00:01 UTC - we haven't fallen back
    eastern_time.FromSeconds(utc_time.AsSeconds() - 4*3600)  ' 1:00:01 Eastern - offset is still 4 hours
    assert(invalid = isEasternDaylightSavingTime(eastern_time), eastern_time.ToISOString() + " should be unknown")

    utc_time.fromISO8601String("2025-11-02 06:00:01")  ' 6:00:01 UTC - we HAVE fallen back
    eastern_time.FromSeconds(utc_time.AsSeconds() - 5*3600)  ' 1:00:01 Eastern - offset is now 5 hours - so we get the SAME TIME
    assert(invalid = isEasternDaylightSavingTime(eastern_time), eastern_time.ToISOString() + " should be unknown")

    ' Now after those two hours.
    utc_time.fromISO8601String("2025-11-02 07:00:01")
    eastern_time.FromSeconds(utc_time.AsSeconds() - 5*3600)  ' 2:01 eastern
    assert(false = isEasternDaylightSavingTime(eastern_time), eastern_time.ToISOString() + " should not be EDT")
end sub

#endif
