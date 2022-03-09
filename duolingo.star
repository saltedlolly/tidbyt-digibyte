"""
Applet: Duolingo 
Summary: Track language study progress
Description: Display Duolingo stats and track your progress towards a daily XP target.
Author: Olly Stedall @saltedlolly
Thanks: @drudge
"""

################################################################################
# IMPORTANT: This app is still a work in progress and is not yet fully working
################################################################################

print(" ---------------------------------------------------------------------------------------------------------------------")

load("render.star", "render")
load("http.star", "http")
load("encoding/base64.star", "base64")
load("encoding/json.star", "json")
load("cache.star", "cache")
load("schema.star", "schema")
load("math.star", "math")
load("time.star", "time")


# 16 x 18
DUOLINGO_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAACXBIWXMAAAsTAAALEwEAmpwYAAABlUlEQVQ4jaWUMXITQRBF399SFccALmKJmKV2RpcgpnwO51wCzagkx8icwqFibmACPsH0jNak3minZ/v3/7+7V7Z5yzO9KRvQ/8e5JAtzykfBjd1ckuNznfcVMBg2r6BsZNjlIz4ki4AQfEqVS0mMoITwSoJhPiQTdXe5tO8wu6UwvHIrLRvTGUitOrBLhXuBbZQnMNxPcU7iZ80B29CmUR6whNG6GgRYu1/RjZxNFI94e3nwhDDffr1DmIc7NZbddTUjZJh68peSLAJNcKkJPb/g5z88HRMKg5GZu8HqbZSYfywRFHJc2nhQ1FAOcNpXqTNqiMJqRhoh33zp0gNnHB73VdOQpKBo2C2Fba6hubVxu5TbyPjGR/MhWzJjAMZcGQZ7hf5o56ojmzFtjnFYdXm7VBA81dTi3bVgKsR02pcWFZxz0bh368Sl5ijXPDrn2shInPfl1txYBYT4XJL7sqh3QeKUqySz/gNseqKHcnP6XTFm+tpE/f2OkZgieb3CYw6EuV6vfmWmutYwkDYgHz+8V9/Kf2R75tl4Ngj0AAAAAElFTkSuQmCC
""")

# 16 x 18
DUOLINGO_ICON_FLY_WING_UP = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAAAXNSR0IArs4c6QAAAdpJREFUOE9tVLFxGzEQ3PtEJThlBS7BrwJIEWDkDqRcchW2FEslKDABSmRMclyBK7Bid+DAf5q9wwP/HiMg/4HD3u7e3Qu4BIDak61VCvoad8LN8Wi5DXrYZGk7Hsvz2Vpto17GjGMK5TKRBdw7p4DXTRIHbb8Vavk9KE/7sINAcUzR/vuQDeS8C1AF9ptc2cnIn3hLy55wKwLVAQ/oTNpdpxhU8aCCY47YVxYzCYJlCnoZMr6I0/42uMi7IvSrKk454hCTRZgHNEcgpm21DdrHXTFUcfvjwp7vP/0BivJTIoNssZaGD60Sgj4mEPCUAl6ef1px1p8/gsz4cqIPpKUkpw3A0IyqH/L95TfNA64+rCFaCjotuQglRGPAyzoWpwSTSQNWKMU6PlgOnlsV2DhqG75IlxjnHPx9ne3SOUcoW8kSoPbE6CfcUM9guZnN+blNheUhsiNLFaaSVimqyXAE9Gv3YGwgYX9AsY9spNp/HsxLFGFyRheLqX7GOF72GZkDlDoOT6rdNYQNVeJrqxGcmYdH1e6mzVAbpsLi75Nod20j4TWp6YHhEeVy2/dZmARN5cxnbj7Izex/PgfV1Ikv0+/CWJNaheqlKN5+vVV3/idhNG6xWIw9i3cSI/hAZ0IAIAAAAABJRU5ErkJggg==
""")

# 16 x 18
DUOLINGO_ICON_FLY_WING_DOWN = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAACXBIWXMAAAsTAAALEwEAmpwYAAABoUlEQVQ4jW2TTW7bMBCFvycY6CGy8Ql6hNbZOzWZS7R7nyPbNrmEKMHZx0IPUvgg9euCP6JRDyCCA828mXmPI9tUk8TTGI3MKc4CI8DAfgwWAtDpObWcDXdsF2Y8BudkA2IXJ5YUciFW6KFP3I/BKKc8xlRSYRcS1THYHcRNB0LsQuIosA1xAMNxAPuKDuJjivSj3XTgMnXjpVYtvpX9mvwfByqBLx4Ac/z9CQwvXwRSA81FrgAMkpDEtym60SNYpgg/H/CvB5Y5IIwMktmn0KTbFP1w+blMsVQBP/4pRT9zTnl2tHZaFWkaW4UcV5aVaVCGsYVU5rc5xaQNXYAK8GNIWLBMIct4mDB5LGNU2JSE9mO05CyMV4ZVnNyt6qQdQOGgSeI+IOd8PUwALHO4AeptOD0nVXFPcVLmIlc+z4HzHNsDMOY9zj2KNu6g/SYPMWmfgjPb5CPvEO9x1vXVPnStqN/GQeLvmzx8t9prl9uzu77i4Qd6GuPag+32VWG1Knzn5OZ+swvQFVS/c+vy1OR270e4XC7NuTdCte12qxrzD6wF41KmxN1hAAAAAElFTkSuQmCC
""")

DUOLINGO_ICON_CRY = base64.decode("""
UklGRnYLAABXRUJQVlA4WAoAAAASAAAADwAAEQAAQU5JTQYAAAD/////AABBTk1GBAEAAAAAAAAAAA8AABEAAGQAAAJWUDhM6wAAAC8PQAQQF4GmkaTMKXlLaMYFLSqoOBtoGknKXPUlwQQ2EIF/KxzbSJLi9HnknwUm4eBhISmFd+c/QGrw/29rWo6bUGgkzNreXOypcDpCoBQKIaw7BEQhUALivqUQtBggNpKkSJp75obZnmX038vZfbKgKqL/E5D+ZdYqlysfikqe40J97IIjJc7KOGFGy17OZL7dd+3dfR9nZXrn4wM55ZNo2iVe3j7GwbySIAhldkSVS1DDIU32SiWPPWToEbkyzw2LQRheNeZfMvfihawU9mlkoSSpJMFBa0pCrgA8vya8POFy31Yc236QCQAAQU5NRkoAAAACAAAEAAAFAAAHAABkAAAAVlA4TDEAAAAvBcABEB8gEEj2p9kwDSEBmbJANYFAgPB/okWDl/mPwNXioLBt2zbEjO5G9D/QwMcGAEFOTUZIAAAAAgAABAAABQAABgAAZAAAAFZQOEwvAAAALwWAARAfIBBI8qfZcA2BABmiRAGBAMF/gBZ38x9A/UNBYdu2bYgZ3Y3of/hoYAMAQU5NRkYAAAACAAAEAAAFAAAHAABkAAAAVlA4TC4AAAAvBcABEB8gEEjC2X5dIQHBP/+/aAIBMkSRFfMfwJ3qQGHbtm2IGd2N6H+g8YENQU5NRj4AAAAEAAAFAAABAAACAABkAAAAVlA4TCUAAAAvAYAAEBcwrwKBFGeywQKBJH+BXaab/4BXg4K2bVjYv0X0Px4BAEFOTUY+AAAABAAABQAAAQAAAwAAZAAAAFZQOEwmAAAALwHAABAXIBBI8rdZcA6BbHL/JZLlGM5/wNlBQds2LOzfIvofCB5BTk1GTAAAAAIAAAQAAAUAAAYAAGQAAABWUDhMNAAAAC8FgAEQHyAQSPIHm2UkIQGZskA1AYEARf8XhS+2zH8A7RseFLRt5OT2ev6Mn0NE/9P5HtBBTk1GSgAAAAIAAAQAAAUAAAcAAGQAAABWUDhMMQAAAC8FwAEQHyAQIPifUahDSECmRA+sIBAg/Bd48qJh/gNQfemgsG3bNsSM7kb0P2iAjw0AQU5NRkwAAAACAAAEAAAFAAAGAABkAAAAVlA4TDMAAAAvBYABEB8gECD4j5FoQ0BC+F8+ueCRQCDFIa7x/AewVnxQ0LaRk9vr+TN+DhH9TwceXwMAQU5NRkgAAAACAAAEAAAFAAAHAABkAAAAVlA4TC8AAAAvBcABEB8gECDsqJdoQyyYDDB/mC6BQIozmuX5D1AfHihs27YNMaO7Ef0PGh9gAwBBTk1GOAAAAAIAAAUAAAEAAAIAAGQAAABWUDhMIAAAAC8BgAAQFyAQSPKXGXGNMRnU+Q/oDwratmFh/xbR/3gEQU5NRn4AAAABAAAFAAAKAAAFAABkAAACVlA4TGYAAAAvCkABEG9AkG3T+8vccBoG2Ubq+R/UcbzMkwlDTEKv/kXMf0A1CBNfBWLwBG5wAzYBACbZ5SuyBMuwAMpvLw1cXr94NQO8ZIBoEf2P+H66C60yFT2rv3DzLPhVn0D+6nABJEs2CABBTk1G+gAAAAAAAAAAAA8AABEAAGQAAAJWUDhM4QAAAC8PQAQQ/4AWkiT1Krw/2MdP8dlooGkkKXMVNSboUINTDOAAS8cokqRIyenfBgbwwpMnFthj5j/At4cSSAYhEN7ZCEPh7u6Pw1yCNRCCMJAE5dxp4bqChkkMDiJJUqQ9xqfZoWf/Og8eFPRE9H8C0l96XrhsWR2ZvOONbEPLGEC8JkMfXTRDRWvUtRFNRMUrLP0RtzvQO69cm5ILnIZabUEM4ieyG3jhwshsoKvbIpMPlVMdxL5Q86uKXknZFle1C3UVTCIWOelZIyQo0QKAIfQqaefjlfB8bx2m+TBOB0yRAABBTk1GSgAAAAIAAAQAAAUAAAcAAGQAAABWUDhMMQAAAC8FwAEQHyAQSPan2TANIQGZskA1gUCA8H+iRYOX+Y/A1eKgsG3bNsSM7kb0P9DAxwYAQU5NRrYAAAABAAADAAALAAAJAABkAAACVlA4TJ0AAAAvC0ACEMeAmJEk1ZicP8ZJnMr9WkNRI0lR7Y8bCWhEIQ6wtGoiSZGaCP960HIh6Qn45z/At4ckEAZB4Ls3LXiWs9uvTZk6xRr4goAgWcAHhm0jKc7NM8PMYkT/A9zWdV3WdTLA9+c5r+fZA5bLaMNQx9xFM9p9v1Fl4Way+phRYhxTcJ5o0RXZ3sm2yq7kNrHcXWh1tztBAn95pwMBAEFOTUZGAAAAAgAABAAABQAABwAAZAAAAFZQOEwuAAAALwXAARAfIBBIwtl+XSEBwT//v2gCATJEkRXzH8Cd6kBh27ZtiBndjeh/oPGBDUFOTUa4AAAAAQAAAwAACwAACQAAZAAAAlZQOEyfAAAALwtAAhC/gKhtG7lM9hx/CEfijsk9S0NNJElR3/GkpIRYRCEOsHSK2kZyvK/jD+WgHIhKoc9/gG8fioIQCAq+c5ME1zKr+ifbPb1Z8AkKgoIvEcCwbSTFyb1n/lmaieh/GPZt29Ztm2nM432v+32PInudOIbOJQQSfB4viZWkU0KXHHXOhX8GK1QdGR+C6lBjn6HMdAuPiEwYzEzK6DQzAEFOTUY+AAAABAAABQAAAQAAAwAAZAAAAFZQOEwmAAAALwHAABAXIBBI8rdZcA6BbHL/JZLlGM5/wNlBQds2LOzfIvofCB5BTk1GuAAAAAEAAAMAAAsAAAkAAGQAAAJWUDhMnwAAAC8LQAIQv4CQjSTNCBzD+WOcxDM8xWioiSQp6g2PN0YmBpGAJjWRJEVNhH9jrwAyQgz88x+Ab4+AQBACvruR4Vl2D3Oav5JqYnUCXyAIBMHgsI0kRZrju8fhyT/r7oj+h9h5APuBNQR5ffi8yGskdP/Ggr63agsQb/o0YzLgQZpOu829wrbVYqqhlVSraK1WO9dfJ+BSTvKfJiTQzFIIBgBBTk1GaAAAAAIAAAMAAAYAAAkAAGQAAABWUDhMUAAAAC8GQAIQT0AgQFEvbDeWG2batnG/QiiJ8Wc3EQhQ6P8Bm4wxgfkPCKFkP4VDFjuzhYOiSHKiScL5QwKSkIAEJMQ7l4WI/mezbuwRmF75OecCQU5NRsAAAAABAAADAAALAAAJAABkAAACVlA4TKcAAAAvC0ACEN+AqG0bJUhGaZgPxUG514UGmkaSMlc9VLjABv5NcWoiSZFmM/zLIMIUFyLgvp3/AIgK/39HqLjZZHOWt1szuok1BAJYQCEU2VdgAgEkgFmBA7dtHDmevV5sJ5k+uxH9D+M67le73Udaxv58no/PZ9dMtJmvt87uYuY3WUqVskb+SkpEVWE9R2UfzOqq8HDQU3CBa1ARUcyLu0fQaGZS+D/MDABBTk1GSAAAAAIAAAQAAAUAAAcAAGQAAABWUDhMLwAAAC8FwAEQHyAQIOyol2hDLJgMMH+YLoFAijOa5fkPUB8eKGzbtg0xo7sR/Q8aH2ADAEFOTUa+AAAAAQAAAwAACwAACQAAZAAAAlZQOEylAAAALwtAAhDXgKaRpMwpocUNnlHxTug4G0ojSYr6+CwWSSjkHxSrJpKkaDY7/06wgAMyFCDinfkPoDLw/3eVBlNbaO3lnW7fadaggAoCQiHReQ0KKBAFlAQcRpLbtmlIzv4AgMqK6H8EjulxL/Njywif3+/r+f2eHVnLnu8Pr1VEJhJjNJntzJEkqjnQ/62xbsgW+yeroGSJhWMDbY/QkGQjgAjSKkc0AEFOTUY+AAAAAgAABQAAAQAAAwAAZAAAAFZQOEwmAAAALwHAABAXIBBI8rdZcA4BSeJ/aEBvB3X+A84OCtq2YWH/FtH/QPBSSUZG+AAAAFdFQlBWUDhM6wAAAC8PQAQQF4GmkaTMKXlLaMYFLSqoOBtoGknKXPUlwQQ2EIF/KxzbSJLi9HnknwUm4eBhISmFd+c/QGrw/29rWo6bUGgkzNreXOypcDpCoBQKIaw7BEQhUALivqUQtBggNpKkSJp75obZnmX038vZfbKgKqL/E5D+ZdYqlysfikqe40J97IIjJc7KOGFGy17OZL7dd+3dfR9nZXrn4wM55ZNo2iVe3j7GwbySIAhldkSVS1DDIU32SiWPPWToEbkyzw2LQRheNeZfMvfihawU9mlkoSSpJMFBa0pCrgA8vya8POFy31Yc236QCQAA
""")


# Streak Icon Flame Gold 7x8
STREAK_ICON_GOLD = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHCAYAAADEUlfTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE4GlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNy4xLWMwMDAgNzkuZWRhMmIzZmFjLCAyMDIxLzExLzE3LTE3OjIzOjE5ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgMjMuMSAoTWFjaW50b3NoKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjItMDItMjBUMTc6NDU6MjRaIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMi0wMy0wOVQxODoxMToxNVoiIHhtcDpNZXRhZGF0YURhdGU9IjIwMjItMDMtMDlUMTg6MTE6MTVaIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDowZGZjMTU2Yy1mMTlkLTQ5NjItOGFjZS04ZTExYzc3MTRlMmEiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MGRmYzE1NmMtZjE5ZC00OTYyLThhY2UtOGUxMWM3NzE0ZTJhIiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6MGRmYzE1NmMtZjE5ZC00OTYyLThhY2UtOGUxMWM3NzE0ZTJhIj4gPHhtcE1NOkhpc3Rvcnk+IDxyZGY6U2VxPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY3JlYXRlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDowZGZjMTU2Yy1mMTlkLTQ5NjItOGFjZS04ZTExYzc3MTRlMmEiIHN0RXZ0OndoZW49IjIwMjItMDItMjBUMTc6NDU6MjRaIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjMuMSAoTWFjaW50b3NoKSIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz7IM7HhAAAAY0lEQVQImVXMwQ2DQAwF0flIESklzaUaTmw32wMHUgqKxOTgBSm+2c8aVABUzhUBMvaJMfanGNT6gEIVIrwe0GevWmGbZP8Sggm0eGMqjED24z/LJhjyKchWGJUk+EZHJUvdf996OJzBUg9UAAAAAElFTkSuQmCC
""")

# Streak Icon Flame Grey 7x8
STREAK_ICON_GREY = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHCAYAAADEUlfTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAWklEQVQImVXOwQ3AIAxD0W/2YB42IYvAUIxDFnEPLVXr27OlKNgGwDa99xuPy8Gc06c8Kd+i1soYw8cFICKcmUhCEhHhd/wmM/9n996/4Vi2kURr7f1krSXbXLJqNT5ffLfKAAAAAElFTkSuQmCC
""")

# XP Icon  7x7
XP_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHCAYAAADEUlfTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAUklEQVQImWWOQRKAIAwDk/5K3yov1CcU1gMgztBbukkbA1oTQzRLUuxAtq0fXAl7XQop4Dm+dGYBhgOsdp8CBAZMZhGw/6z18ty4t+3AxjBZ0wuaEDIIXi0mQgAAAABJRU5ErkJggg==
""")

# Crown Icon  9x7
CROWN_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAkAAAAGCAYAAAARx7TFAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAYElEQVQImWWNwQ3DIAADzygjtMvA/MkuhR24PqgUovrhh235UNllr49AXWavEpij6cTZmwBzVFUKgAE/1bxOSAhib/L7LAAh+L7YOWuRe+RfHRIgKz8AYmA0iCgLdx/xBe0JOsNPUxB6AAAAAElFTkSuQmCC
""")


# Set applet defaults
DEFAULT_USERNAME = "saltedlolly"
DEFAULT_DAILY_XP_TARGET = "100"
DEFAULT_TIMEZONE = "Europe/London"
DEFAULT_DISPLAY_VIEW = "Today"
DEFAULT_NICKNAME = "Olly"
DEFAULT_SHOW_NICKNAME = False

DISPLAY_VIEW_LIST = {
    "Today": "today",
    "Week": "week",
}

def get_schema():

    displayoptions = [
        schema.Option(display = displayv, value = displayv)
        for displayv in DISPLAY_VIEW_LIST
    ]

    return schema.Schema(
    version = "1",
    fields = [
        schema.Text(
            id = "duolingo_username",
            name = "Username",
            desc = "Enter a Duolingo username.",
            icon = "user",
            default = DEFAULT_USERNAME,
        ),
        schema.Dropdown(
            id = "display_view",
            name = "Display",
            desc = "Choose Today or Week view.",
            icon = "rectangle-wide",
            default = displayoptions[0].value,
            options = displayoptions,
        ),
        schema.Text(
            id = "xp_target",
            name = "Daily XP target",
            desc = "Enter a daily XP goal. Resets at midnight.",
            icon = "trophy",
            default = DEFAULT_DAILY_XP_TARGET,
        ),
        schema.Text(
            id = "nickname",
            name = "Nickname",
            desc = "Display on Tidbyt to identify the user. Max 5 letters.",
            icon = "user",
            default = DEFAULT_NICKNAME,
        ),
        schema.Toggle(
            id = "display_nickname_toggle",
            name = "Display Nickname?",
            desc = "Toggle displaying user nickname.",
            icon = "toggle-on",
            default = DEFAULT_SHOW_NICKNAME,
        ),
    ],
)

def main(config):

    # Get Schema variables
    duolingo_username = config.get("duolingo_username", DEFAULT_USERNAME)
    display_view = DISPLAY_VIEW_LIST.get(config.get("display_view"), DEFAULT_DISPLAY_VIEW)
    xp_target = config.get("xp_target", DEFAULT_DAILY_XP_TARGET)
    nickname = config.get("nickname", DEFAULT_NICKNAME)
    display_nickname_toggle = config.bool("display_nickname_toggle", DEFAULT_SHOW_NICKNAME)

    # Setup user cache keys
    duolingo_cache_key_username = "duolingo_%s" % duolingo_username
    duolingo_cache_key_userid = "%s_userid" % duolingo_cache_key_username
    duolingo_cache_key_xpsummary_json = "%s_xpsummary_json" % duolingo_cache_key_username
    duolingo_cache_key_main_json = "%s_main_json" % duolingo_cache_key_username
    duolingo_cache_key_saveddate = "%s_saveddate" % duolingo_cache_key_username
    duolingo_cache_key_totalxp_daystart = "%s_totalxp_daystart" % duolingo_cache_key_username
    duolingo_cache_key_streak_daystart = "%s_streak_daystart" % duolingo_cache_key_username

    # Get Cache variables
    duolingo_userid_cached = cache.get(duolingo_cache_key_userid)
    duolingo_xpsummary_json_cached = cache.get(duolingo_cache_key_xpsummary_json)
    duolingo_main_json_cached = cache.get(duolingo_cache_key_main_json)
    duolingo_saveddate_cached = cache.get(duolingo_cache_key_saveddate)
    duolingo_totalxp_daystart_cached = cache.get(duolingo_cache_key_totalxp_daystart)
    duolingo_streak_daystart_cached = cache.get(duolingo_cache_key_streak_daystart)

    # Get time and location variables
    timezone = config.get("timezone", DEFAULT_TIMEZONE)

    #Setup main query url
    duolingo_main_query_url_prefix = "https://www.duolingo.com/2017-06-30/users?username="
    if duolingo_username != None:
        duolingo_main_query_url =  duolingo_main_query_url_prefix + duolingo_username


    # !!!!!!!!!! TROUBLESHOOTING !!!!! USED DURING TESTING - WILL RESET THE CACHED USERID TO FORCE TO A NEW QUERY
#    duolingo_userid_cached = None
#    duolingo_saveddate_cached = None


    # IMPORTANT NOTE: There are two queries that need to be made to duolingo.com
    # The main query is made the first time the script runs each day (to update the daily xptotal)
    # The xpsummary query is made every 15 minutes (to get the running xp count, and live status)


    # FIRST LOOKUP CURRENT DUOLINGO USERID (OR RETRIEVE FROM CACHE)
    # If the userid for the provided username is not yet known, send a query to duolingo.com to retrieve it
    # Thereafter the userid for the associated username is cached for 7 days, and the timer is updated on each run
    # i.e. So as long as that username continues to be used in the app, the userid will remain cached


    # Check a username has been provided (i.e. field is not blank)
    if duolingo_username != None:
        # Check if the userId is already known, otherwise perform a query to look it up
        if duolingo_userid_cached == None:
            do_duolingo_main_query = True
        else:
            do_duolingo_main_query = False
            duolingo_userid = duolingo_userid_cached
            print("Cached userId for username " + duolingo_username + ": " + duolingo_userid)
            # update userid cache timer
            cache.set(duolingo_cache_key_userid, duolingo_userid, ttl_seconds=604800)
            display_error_msg = False
#    else:
#        print("Error! No Duolingo username provided.")
#        display_error_msg = True
#        error_message_1 = "username"
#        error_message_2 = "is blank"

    # Lookup userId from supplied username (if not already found in cache)
    if do_duolingo_main_query == True:
        print("Querying duolingo.com for userId...")
        duolingo_main_query = http.get(duolingo_main_query_url)
        if duolingo_main_query.status_code != 200:
            if duolingo_main_query.status_code == 422:
                print("Error! No Duolingo username provided.")
                display_error_msg = True
                error_message_1 = "username"
                error_message_2 = "is blank"
                duolingo_userid = None
            else:
                print("Duolingo query failed with status %d", duolingo_main_query.status_code)
                display_error_msg = True
                error_message_1 = "check"
                error_message_1 = "connection"
                duolingo_userid = None
        else:
            # display an error message if the username is unrecognised
            duolingo_main_json = duolingo_main_query.json()
            if duolingo_main_json["users"] == []:
                print("Error! Unrecognised username.")
                display_error_msg = True
                error_message_1 = "invalid"
                error_message_2 = "username"
                duolingo_userid = None
            else:
                duolingo_userid = int(duolingo_main_json["users"][0]["id"])
                if duolingo_userid != None:
                    print("Success! userId for username \"" + str(duolingo_username) + "\": " + str(duolingo_userid))
                    cache.set(duolingo_cache_key_userid, str(duolingo_userid), ttl_seconds=604800)
                    display_error_msg = False
                else:
                    # Show error if username not found
                    print("userId not found.")
                    display_error_msg = True
                    error_message_1 = "username"
                    error_message_2 = "not found"

    


    # If we know the userId then next we'll lookup the progress data for that user (either from duolingo or from cache)
    if duolingo_userid != None:

        # LOOKUP DUOLINGO XP SUMMARY JSON DATA
        # The XP summary is updated every 15 minutes

        # Example Query: https://www.duolingo.com/2017-06-30/users/xp_summaries?startDate=2022-02-24&endDate=2022-02-24&Europe/London

        # Setup xp summary query URL
        duolingo_xpsummary_query_1 = "https://www.duolingo.com/2017-06-30/users/"
        duolingo_xpsummary_query_2 = "/xp_summaries?startDate="
        duolingo_xpsummary_query_3 = "&endDate="
        duolingo_xpsummary_query_4 = "&timezone="


        # Get today's date
        now = time.now().in_location(timezone)
        date_now = now.format("2006-01-02").upper()


        # Get the date 6 days ago
        six_days_ago = now - time.parse_duration("144h") 
        startDate = six_days_ago.format("2006-01-02").upper()

        # Set end date variable (today)
        endDate = date_now

        print("Today's Date: " + str(endDate) + "   Date 6 days ago: " + str(startDate))

        DUOLINGO_XP_QUERY_URL = duolingo_xpsummary_query_1 + str(duolingo_userid) + duolingo_xpsummary_query_2 + startDate + duolingo_xpsummary_query_3 + endDate + duolingo_xpsummary_query_4 + timezone

        if duolingo_xpsummary_json_cached != None:
            duolingo_xpsummary_json = json.decode(duolingo_xpsummary_json_cached)
            print("XP summary data retrieved from cache.")
            live_xp_data = False
        else:
            print("Querying duolingo.com for XP summary data.")
            xpsummary_query = http.get(DUOLINGO_XP_QUERY_URL)
            if xpsummary_query.status_code != 200:
                print("XP summary query failed with status %d", xpsummary_query.status_code)
                display_error_msg = True
                error_message_1 = "check"
                error_message_2 = "connection"
                live_xp_data = None
            else:
                display_error_msg = False
                duolingo_xpsummary_json = xpsummary_query.json()
                live_xp_data = True
                # Show error if username was not recognised
                print("XP summary data retrieved from duolingo.com")
                cache.set(duolingo_cache_key_xpsummary_json, json.encode(duolingo_xpsummary_json), ttl_seconds=900)

        # Work out whther today's data is being returned or not (by checking the number of days in string)
        days_returned = len(duolingo_xpsummary_json["summaries"])
        print("Days returned: " + str(days_returned))

        # Setup dummy data for today
        today_dummy_data = { "gainedXp": 0, "streakExtended": False }

        # Insert today's dummy data into JSON variable
        if days_returned == 6:
            duolingo_xpsummary_json["summaries"].insert(0, today_dummy_data)

        # Now we get today's daily XP count from the xpsummary_query_json variable (which updates with live data every 15 mins)
        # We'll need this below, to calculate the total XP earned
        duolingo_xptoday = duolingo_xpsummary_json["summaries"][0]["gainedXp"]

        # If the current XP score is null convert to integer zero
        if str(duolingo_xptoday) == "null":
            duolingo_xptoday = 0
        else:
            duolingo_xptoday = int(duolingo_xptoday)


        # Get current streak status
        is_streak_extended = bool(duolingo_xpsummary_json["summaries"][0]["streakExtended"])


        # LOOKUP DUOLINGO MAIN JSON DATA AT START OF DAY
        # The is run daily to calculate what the user's totalXP was at the start of the day
        # It runs whenever it detects that the date has changed from the previous time it was run
        # It also requires live XP data to be available (rather than cached data)

        # Run this if today's date has changed and live data has just been retried (or this is the first time running)
        if (duolingo_saveddate_cached != date_now) and (live_xp_data == True):
            print("New day detected!")

            # First we are going to get the totalXp score at the start of the day 
            # (we will use this to calculate the running XP total throughout the day)
            if do_duolingo_main_query == True:
                duolingo_totalxp = int(duolingo_main_json["users"][0]["totalXp"])
                duolingo_streak = int(duolingo_main_json["users"][0]["streak"])
            else:
                # Setup userid query URL
                print("Querying duolingo.com for current totalXp...")
                duolingo_main_query = http.get(duolingo_main_query_url)
                if duolingo_main_query.status_code != 200:
                    print("Duolingo query failed with status %d", duolingo_main_query.status_code)
                    display_error_msg = True
                    error_message = "Error: Duolingo query failed. Check internet connectivity."
                else:
                    duolingo_main_json = duolingo_main_query.json()
                    duolingo_totalxp = int(duolingo_main_json["users"][0]["totalXp"])
                    
                    # Show error if totalxp was not found
                    if duolingo_totalxp == "":
                        print("totalXp query failed with status %d", duolingo_main_query.status_code)
                        display_error_msg = True
                        error_message_1 = "totalXp"
                        error_message_2 = "not found"
                    else:
                        display_error_msg = False
                        print("Queried totalXp for username \"" + str(duolingo_username) + "\": " + str(duolingo_totalxp))
 #                       cache.set(duolingo_cache_key_totalxp, str(duolingo_totalxp), ttl_seconds=86400)

                    # Get current streak
                    duolingo_streak = int(duolingo_main_json["users"][0]["streak"])
                    
                    # Show error if totalxp was not found
                    if duolingo_streak == "":
                        print("Streak query failed with status %d", duolingo_main_query.status_code)
                        display_error_msg = True
                        error_message_1 = "streak"
                        error_message_2 = "not found"
                    else:
                        display_error_msg = False
                        print("Queried Streak for username \"" + str(duolingo_username) + "\": " + str(duolingo_totalxp))
 #                      cache.set(duolingo_cache_key_totalxp, str(duolingo_totalxp), ttl_seconds=86400)


            # Now we subtract the daily XP count from the total count to find out the XP count at the start of the day
            # (this is saved in the cache so we don't have to continue do the main json query throughout the day - we can calculate the)
            # running live total by adding the XP at start of day to the current daily count from the XP Summary query.)
            duolingo_totalxp_daystart = int(duolingo_totalxp) - int(duolingo_xptoday)

            print("XP Count at Start of Day: " + str(duolingo_totalxp_daystart))

            # Store start-of-day XP count in cache (for 24hrs)
            cache.set(duolingo_cache_key_totalxp_daystart, str(duolingo_totalxp_daystart), ttl_seconds=86400)


            # Now we cache the Streak at the start of the day, and store it in the cache
            if is_streak_extended == True:
                duolingo_streak_daystart = int(duolingo_streak) - 1
            else:
                duolingo_streak_daystart = int(duolingo_streak)

            print("Streak at Start of Day: " + str(duolingo_streak_daystart))

            # Store start-of-day XP count in cache (for 24hrs)
            cache.set(duolingo_cache_key_streak_daystart, str(duolingo_streak_daystart), ttl_seconds=86400)

            # Finally update the cache with the new date so this won't run again until tomorrow (stored for 24 hours)
            cache.set(duolingo_cache_key_saveddate, str(date_now), ttl_seconds=86400)



        # Set variables for current state
        if live_xp_data == True:
            print("---- CURRENT DATA: LIVE ----- ")
        elif live_xp_data == False:
            print("---- CURRENT DATA: CACHED ----- ")
        elif live_xp_data == None:
            print("---- CURRENT DATA: UNAVAILABLE ----- ")

        # Use cached value for Total XP at day start if live value is not available
        if duolingo_totalxp_daystart_cached != None:
            duolingo_totalxp_daystart = str(duolingo_totalxp_daystart_cached)

        # Calculate current total XP
        duolingo_totalxp_now = int(duolingo_totalxp_daystart) + int(duolingo_xptoday)
        print("Today's XP: " + str(duolingo_xptoday) + "  Total XP (at day start): " + str(duolingo_totalxp_daystart) + "   TOTAL XP: " + str(duolingo_totalxp_now))

        # Use cached value for Streak at day start if live value is not available
        if duolingo_streak_daystart_cached != None:
            duolingo_streak_daystart = str(duolingo_streak_daystart_cached)

        # Calculate current Streak, based on whther it has already been extended today
        if is_streak_extended == True:
            duolingo_streak_now = int(duolingo_streak_daystart) + 1
        else:
            duolingo_streak_now = int(duolingo_streak_daystart)

        print("Streak: " + str(duolingo_streak_now) + "   Streak Extended?: " + str(is_streak_extended))



        # Deduce what streak icon to display on day view

        if is_streak_extended == False:
            streak_icon = STREAK_ICON_GREY
        elif is_streak_extended == True:
            streak_icon = STREAK_ICON_GOLD



    # DISPLAY ERROR MESSAGES
    # If the data queries failed in any way, then show an error on the Tidbyt

    if display_error_msg == True:
        print("Displaying Error message on Tidbyt...")

        display_output = render.Box(
            render.Row(
                expanded = True,
                main_align = "space_evenly",
                cross_align = "center",
                children = [
                    render.Image(src = DUOLINGO_ICON_CRY),

                    # Column to hold pricing text evenly distrubuted accross 1-3 rows
                    render.Column(
                        main_align = "space_evenly",
                        expanded = True,
                        children = [
                            render.Text("ERROR:", font = "CG-pixel-3x5-mono", color = "#FF0000"),
                            render.Text("%s" % error_message_1, font = "tom-thumb"),
                            render.Text("%s" % error_message_2, font = "tom-thumb"),
                        ],
                    ),
                ],
            ),
        )

    # DISPLAY DAY VIEW
    # Setup day view layout

    if display_error_msg == False and display_view == "Today":
        print("Displaying Day View on Tidbyt...")  


        # Setup nickname display, if needed
        if display_nickname_toggle == True:
            nickname_today_view = render.Row(
                main_align = "space_evenly",
                expanded = False,
                children = [
                    render.Text(str(nickname), font = "tom-thumb"),
                ],
            )
        else:
            nickname_today_view = None

        display_output = render.Box(
            render.Row(
                expanded = True,
                main_align = "space_evenly",
                cross_align = "center",
                children = [
                    render.Column(
                        main_align = "space_evenly",
                        expanded = True,
                        children = [
                            nickname_today_view,
                            render.Row(
                                main_align = "space_evenly",
                                expanded = False,
                                children = [
                                    render.Image(src = streak_icon),
                                    render.Text(str(duolingo_streak_now), font = "tom-thumb"),
                                ],
                            ),
                            render.Row(
                                main_align = "space_evenly",
                                expanded = False,
                                children = [
                                    render.Image(src = XP_ICON),
                                    render.Text(str(duolingo_xptoday) + "xp", font = "tom-thumb"),
                                ],
                            ),
                        ],
                    ),

                    # Column to hold pricing text evenly distrubuted accross 1-3 rows
                    render.Column(
                        main_align = "space_evenly",
                        expanded = True,
                        children = [
                            render.Image(src = DUOLINGO_ICON),
#                            render.Text(str(duolingo_xptoday) + " xp", font = "tom-thumb"),
                        ],
                    ),
                ],
            ),
        )

    return render.Root(
        child = display_output,
    )



