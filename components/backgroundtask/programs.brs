sub init_program_list()
    ' Set things up for figuring out current program name
    filechars = ReadASCIIFile("pkg:/components/backgroundtask/programs.json")
    data = parseJSON(filechars)
    'for each programdata in data
    '    print programdata
    'end for
    m.programdata = data
end sub

function h_colon_mm_as_minutes(s)
    ' Given a string like '1:30' or '01:30', return 90
    colon_position = s.InStr(":")  ' 0-based (-1 if not there, but in this case should always be there)
    hour_string = s.Left(colon_position)
    minutes_string = s.Right(2)
    return 60*Val(hour_string) + Val(minutes_string)
end function

function current_program_name() as String
    ' Return name of program currently playing or ""
    data = m.programdata
    'print "TYPE of self.programdata=";type(m.programdata)
    if data = invalid then return ""

    now = getNowInEasternTime()
    day_of_week = now.GetDayOfWeek().ToStr()  ' 0 = Sunday etc
    week_number = (1 + (now.GetDayofMonth() \ 7)).ToStr()  ' so 1 = first sunday, 2 = second, etc

    minutes_past_midnight = now.GetHours() * 60 + now.GetMinutes()
    'print "NOW=";now.ToISOString();" DAY OF WEEK=";day_of_week
    for each programdata in data
        if programdata.days.InStr(day_of_week) <> -1 then
            'print "DAY MATCHES"
            if (not programdata.DoesExist("weeks")) or (programdata.weeks.InStr(week_number) <> -1) then
                start_minutes_past_midnight = h_colon_mm_as_minutes(programdata.starttime)
                'print "WEEK MATCHES. CONSIDERING ";programdata;"NOW in min past midnight=";minutes_past_midnight
                if start_minutes_past_midnight <= minutes_past_midnight then
                    end_minutes_past_midnight = start_minutes_past_midnight + programdata.duration - 1
                    'print "PAST START TIME. starts at=";start_minutes_past_midnight
                    if minutes_past_midnight < end_minutes_past_midnight then
                        'print "BEFORE END TIME. Ends at="end_minutes_past_midnight
                        return programdata.title
                    else
                        'print "Has already ended. Ends at="end_minutes_past_midnight
                    end if
                else
                    'print "Has not started. starts at=";start_minutes_past_midnight
                end if
            else
                'print "WEEK does not match"
            end if
        else
            'print "DAY does not match"
        end if
    end for

    return ""
end function
