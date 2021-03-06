
sub setDrawingStyles(node)
    devInfo = CreateObject("roDeviceInfo")
    resolution = devInfo.GetUIResolution()["name"]  ' "SD", "HD", "FHD"

    ' Font sizes on the web page:
    ' heading 14px
    ' title 19px
    ' performers 13px
    ' composer 19px

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

    programfontsize    = {"SD": 24, "HD": 36, "FHD": 56}[resolution]  ' setting above 48-56 doesn't seem to make it appear any bigger
    titlefontsize      = {"SD": 20, "HD": 30, "FHD": 48}[resolution]
    headingfontsize    = {"SD": 16, "HD": 22, "FHD": 35}[resolution]
    performersfontsize = {"SD": 15, "HD": 21, "FHD": 33}[resolution]
    composerfontsize   = titlefontsize

    node.drawingStyles = {
        "program": {
            ' "fontUri": "pkg:/fonts/SourceSerifPro/SourceSerifPro-Regular.ttf"
            "fontUri": "pkg:/font-subsets/SourceSerifPro-Regular-subset.ttf"
            "fontSize": programfontsize
            "color": "#FFFFFFFF"
        }
        "heading": {
            ' "fontUri": "pkg:/fonts/Source_Sans_Pro/SourceSansPro-Regular.ttf"
            "fontUri": "pkg:/font-subsets/SourceSansPro-Regular-subset.ttf"
            "fontSize": headingfontsize
            "color": "#76A2B7FF"
        }
        "title": {
            ' "fontUri": "pkg:/fonts/SourceSerifPro/SourceSerifPro-Regular.ttf"
            "fontUri": "pkg:/font-subsets/SourceSerifPro-Regular-subset.ttf"
            "fontSize": titlefontsize
            "color": "#FFFFFFFF"
        }
        "performers":{
            ' "fontUri": "pkg:/fonts/SourceSerifPro/SourceSerifPro-Italic.ttf"
            "fontUri": "pkg:/font-subsets/SourceSerifPro-Italic-subset.ttf"
            "fontSize": performersfontsize
            "color": "#FFFFFFFF"
        }
        "composer": {
            '"fontUri": "pkg:/fonts/SourceSerifPro/SourceSerifPro-Regular.ttf"
            "fontUri": "pkg:/font-subsets/SourceSerifPro-Regular-subset.ttf"
            "fontSize": composerfontsize
            "color": "#FFFFFFFF"
        }
        "message": {
            "fontUri": "font:LargeSystemFont"
            "color":  "#FFFFFFFF"
        }
        "default": {
            "fontUri": "font:LargeSystemFont"
            "color": "#000000FF"
        }
    }
end sub

sub scaleAndPositionPoster(poster)
    devInfo = CreateObject("roDeviceInfo")
    uires = devInfo.GetUIResolution()
    'resolution = uires["name"]  ' "SD", "HD", "FHD"
    screen_width = uires["width"]
    screen_height = uires["height"]

    margin_w = screen_width / 32
    margin_h = screen_height / 16

    poster_w = screen_width / 4 ' e.g. 320
    poster_x = screen_width - poster_w - margin_w
    poster_y = margin_h
    poster_fields = {
        translation: "[" + poster_x.ToStr() + "," + poster_y.ToStr() + "]"
        width: poster_w
        height: screen_height / 4 ' e.g. 270
    }
    poster.SetFields(poster_fields)
end sub
