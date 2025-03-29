local _, SetupManager = ...

-- use this for general global settings inside the addon instead of currently implementing them into code - e.g. colors, fonts, etc.
SetupManager.gs = {
    debug = true,
    visual = {
        font = "",
        borderColor = {r = 0, g = 0, b = 0},
        colorStrings = {
            white = "FFFFFFFF",
            red = "fa143a",
            green = "25f737",
            gray = "696969"
        },
        backgroundGradient = {
            first = CreateColor(31/255, 31/255, 31/255, 0.3),
            second = CreateColor(36/255, 36/255, 36/255, 0.3)
        },
        defaultColor = { r =31 / 255, g = 31 / 255, b = 31 / 255, a = 0.85 },
        defaultHighlightColor = { r =41 / 255, g = 41 / 255, b = 41 / 255, a = 0.85 },
        buttonColor = { r = 41 / 255, g = 41 / 255, b = 41 / 255, a = 1 },
    }
}