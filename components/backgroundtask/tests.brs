
#if runTests
sub assert(b, s)
    if not b then throw s
end sub

sub runTheTests()
    testisEDT()
end sub
#endif
