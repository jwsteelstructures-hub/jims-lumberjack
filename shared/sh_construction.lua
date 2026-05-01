Config.Construction = {}

Config.Construction.PurchasePrice = 3500

Config.Construction.Phases = {
    [1] = { name = "Foundation", cost = 0 },
    [2] = { name = "Framing", cost = 500 },
    [3] = { name = "Walls & Roof", cost = 500 },
    [4] = { name = "Interior & Exterior", cost = 500 }
}

Config.Construction.Imaps = {
    [1] = { -- foundation
        0x1FCA98A6
    },
    [2] = { -- framing
        0x1FCA98A6,
        0xB1B3C3D1
    },
    [3] = { -- walls + roof
        0xF7C6C1B8
    },
    [4] = { -- interior + exterior
        0xD3E3A3F6,
        0xA0F2C4A8,
        0xC5C395C6,
        0x8F5F1E3C
    }
}
