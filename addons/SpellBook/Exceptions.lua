-- This set lists spell IDs that cannot be learned by player, so that they are
-- excluded by SpellBook.
spell_exceptions = {
    [31] = true, -- Banish IV
    [40] = true, -- Banishga III
    [34] = true, -- Diaga II
    [35] = true, -- Diaga III
    [358] = true, -- Hastega
    [356] = true, -- Paralyga
    [359] = true, -- Silencega
    [357] = true, -- Slowga
    [361] = true, -- Blindga
    [362] = true, -- Bindga
    [257] = true, -- Curse
    [360] = true, -- Dispelga
    [226] = true, -- Poisonga II
    [256] = true, -- Virus
    [244] = true, -- Meteor II
    [351] = true, -- Dokumori: Ni
    [342] = true, -- Jubaku: Ni
    [349] = true, -- Kurayami: San
    [355] = true, -- Tonko: San
    [416] = true, -- Cactuar Fugue
    [407] = true, -- Chocobo Hum

    -- The following spells have the same name as other spells,
    -- but have different IDs.
    [363] = true, -- Sleepga
    [364] = true, -- Sleepga II
}
