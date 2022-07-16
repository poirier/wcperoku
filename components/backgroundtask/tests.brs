
#if runTests
sub assert(b, s)
    if not b then throw s
end sub

sub runTheTests()
    testisEasternDaylightSavingTime()
end sub
#endif
