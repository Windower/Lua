return {
    [1] = {id="1",long="Weapon Skill Damage",short="WS Damage",check="%d+%su",
    init="%d: Reduce your foe's HP by %a*%s*%a*%s*%d+ using a single weapon skill.",
    eval="%d: You have reduced your foe's HP by %a*%s*%a*%s*%d+ using a single weapon skill.",
    fail="%d: You have failed to reduce your foe's HP by %a*%s*%a*%s*%d+ using a single weapon skill."},
    [2] = {id="2",long="Magic Burst Damage",short="MB Damage",check="%d+%su",
    init="%d: Reduce your foe's HP by %a*%s*%a*%s*%d+ using a single magic burst.",
    eval="%d: You have reduced your foe's HP by %a*%s*%a*%s*%d+ using a single magic burst.",
    fail="%d: You have failed to reduce your foe's HP by %a*%s*%a*%s*%d+ using a single magic burst."},
    [3] = {id="3",long="Non-MB Nuke Damage",short="Non-MB Nuke",check="%d+%su",
    init="%d: Reduce your foe's HP by %a*%s*%a*%s*%d+ using a single magic attack without performing a magic burst.",
    eval="%d: You have reduced your foe's HP by %a*%s*%a*%s*%d+ using a single magic attack without performing a magic burst.",
    fail="%d: You have failed to reduce your foe's HP by %a*%s*%a*%s*%d+ using a single magic attack without performing a magic burst."},
    [4] = {id="4",long="Auto-attack Damage",short="Melee Round",check="%d+%si",
    init="%d: Reduce your foe's HP by %a*%s*%a*%s*%d+ in a single auto%-attack.",
    eval="%d: You have reduced your foe's HP by %a*%s*%a*%s*%d+ in a single auto%-attack.",
    fail="%d: You have failed to reduce your foe's HP by %a*%s*%a*%s*%d+ in a single auto%-attack."},
    [5] = {id="5",long="Kills",short="Kills",check="%d+%sf",
    init="%d: Vanquish %d+ %a+.",
    eval="%d: You have vanquished %d+ %a+.",
    fail="%d: You have failed to vanquish %d+ %a+."},
    [6] = {id="6",long="Critical Hits",short="Critical Hits",check="%d+%sc",
    init="%d: Deal %d+ critical %a+ to your foes.",
    eval="%d: You have dealt %d+ critical %a+ to your foes.",
    fail="%d: You have failed to deal %d+ critical %a+ to your foes."},
    [7] = {id="7",long="Abilities",short="Abilities",check="%d+%sa",
    init="%d: Use %d+ %a+ on your foes.",
    eval="%d: You have used %d+ %a+ on your foes.",
    fail="%d: You have failed to use %d+ %a+ on your foes."},
    [8] = {id="8",long="Spells",short="Spells",check="%d+%ss",
    init="%d: Cast %d+ %a+ on your foes.",
    eval="%d: You have cast %d+ %a+ on your foes.",
    fail="%d: You have failed to cast %d+ %a+ on your foes."},
    [9] = {id="9",long="Magic Bursts",short="Magic Bursts",check="%d+%sm",
    init="%d: Perform %d+ magic %a+ on your foes.",
    eval="%d: You have performed %d+ magic %a+ on your foes.",
    fail="%d: You have failed to perform %d+ magic %a+ on your foes."},
    [10] = {id="10",long="Consecutive SCs",short="Skillchains",check="%d+%ss",
    init="%d: Execute %d+ %a+ using weapon %a+ on your foes!",
    eval="%d: You have executed %d+ %a+ using weapon %a+ on your foes!",
    fail="%d: You have failed to execute %d+ %a+ using weapon %a+ on your foes!"},
    [11] = {id="11",long="All Weapon Skills",short="All WS",check="%d+%sw",
    init="%d: Use %d+ weapon %a+ on your foes.",
    eval="%d: You have used %d+ weapon %a+ on your foes.",
    fail="%d: You have failed to use %d+ weapon %a+ on your foes."},
    [12] = {id="12",long="Physical Weapon Skills",short="Physical WS",check="%d+%sp",
    init="%d: Use %d+ physical weapon %a+ on your foes.",
    eval="%d: You have used %d+ physical weapon %a+ on your foes.",
    fail="%d: You have failed to use %d+ physical weapon %a+ on your foes."},
    [13] = {id="13",long="Magical Weapon Skills",short="Magic WS",check="%d+%se",
    init="%d: Use %d+ elemental weapon %a+ on your foes.",
    eval="%d: You have used %d+ elemental weapon %a+ on your foes.",
    fail="%d: You have failed to use %d+ elemental weapon %a+ on your foes."},
    [14] = {id="14",long="Heals for 500 HP",short="500 HP Cures",check="%d+%st",
    init="%d: Restore at least 500 HP %d+ %a+.",
    eval="%d: You have restored at least 500 HP %d+ %a+.",
    fail="%d: You have failed to restore at least 500 HP %d+ %a+."}
} 