sub configureLabelFields()
    devInfo = CreateObject("roDeviceInfo")
    resolution = devInfo.GetUIResolution()["name"]  ' "SD", "HD", "FHD"

    ' FHD = 1920 x 1080
    ' HD =  1280 x 720
    ' SD =  720 x 480

    uires = devInfo.GetUIResolution()
    width = uires.width - 50

    ' Font sizes on the web page (https://theclassicalstation.org):
    '   heading 14px
    '   title 19px
    '   performers 13px
    '   composer 19px

    ' by experimenting, on a FHD screen, a size of 48 looks good
    ' for the title and composer.
    ' if heading is 14/19 of title size, that's (14/19)*48 = 35
    ' if performers is 13/19 of title size, that gives us
    ' (13/19)*48 = 33

    ' For HD, title/composer look good at 30, giving
    ' heading = 30*14/19 = 22
    ' performer = 30*13/19 = 21

    ' I haven't found an SD device to try this on, so just
    ' took a guess at sizes.

    sans = "pkg:/font-subsets/SourceSansPro-Regular-subset.ttf"
    serif = "pkg:/font-subsets/SourceSerifPro-Regular-subset.ttf"
    serifItalic = "pkg:/font-subsets/SourceSerifPro-Italic-subset.ttf"

    propsByFieldType = {
        "Heading": {
            "fontfields": {
                "size": {"SD": 16, "HD": 22, "FHD": 35}[resolution],
                "uri": sans,
            },
            "color": "#76A2B7FF"
        },
        "Title": {
            "fontfields": {
                "size": {"SD": 20, "HD": 30, "FHD": 48}[resolution],
                "uri": serif,
            },
            "color": "#FFFFFFFF"
        },
        "Performers": {
            "fontfields": {
                "size": {"SD": 15, "HD": 21, "FHD": 33}[resolution],
                "uri": serifItalic,
            },
            "color": "#FFFFFFFF"
        },
        "Composer": {
            "fontfields": {
                "size": {"SD": 20, "HD": 30, "FHD": 48}[resolution],
                "uri": serif,
            },
            "color": "#FFFFFFFF"
        },
        "Program": {
            "fontfields": {
                "size": {"SD": 24, "HD": 36, "FHD": 48}[resolution],  ' setting above 48-56 doesn't seem to make it appear any bigger
                "uri": serif,
            },
            "color": "#FFFFFFFF"
        }
    }

    for each labelType in ["Heading", "Title", "Performers", "Composer"]
        fontnode = CreateObject("roSGNode", "Font")
        fontnode.SetFields(propsByFieldType[labelType]["fontfields"])
        color = propsByFieldType[labelType]["color"]
        for each labelTime in ["justPlayed", "nowPlaying", "comingUp"]
            nodeName = labelTime + labelType
            labelNode = m.top.FindNode(nodeName)
            labelNode.setFields({
                "font": fontnode,
                "width": width,
                "color": color,
                "wrap": true
            })
        end for
    end for

    labelType = "Program"
    fontnode = CreateObject("roSGNode", "Font")
    fontnode.SetFields(propsByFieldType[labelType]["fontfields"])
    color = propsByFieldType[labelType]["color"]
    m.top.FindNode("ProgramLabel").SetFields({"font": fontnode, "width": width, "color": color, "wrap": true})

    websiteNode = m.top.FindNode("website")
    websiteNode.font = "font:SmallestSystemFont"
    websiteNode.color = "#FFFFFFFF"
    websiteNode.vertAlign = "bottom"
    y = uires["height"] - 30
    websiteNode.translation = "[50," + y.toStr() + "]"
    websiteNode.text = "https://theclassicalstation.org"
end sub
