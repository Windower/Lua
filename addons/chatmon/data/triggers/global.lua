return {
    { from = S{ "tell" }, notFrom = S{}, match = "*", notMatch = "", sound = "IncomingTell.wav"},
    { from = S{ "emote" }, notFrom = S{}, match = "*", notMatch = "", sound = "IncomingEmote.wav"},
    { from = S{ "invite" }, notFrom = S{}, match = "*", notMatch = "", sound = "PartyInvitation.wav"},
    { from = S{ "examine" }, notFrom = S{}, match = "*", notMatch = "", sound = "IncomingExamine.wav"},
    { from = S{ "say", "shout", "party", "linkshell" }, notFrom = S{}, match = "<name>", notMatch = "", sound = "IncomingTalk.wav"},
}
