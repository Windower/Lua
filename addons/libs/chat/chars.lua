return {
    -- Punctuation
    comma =       string.char(0x81, 0x41),
    period =      string.char(0x81, 0x42),
    colon =       string.char(0x81, 0x46),
    semicolon =   string.char(0x81, 0x47),
    query =       string.char(0x81, 0x48),
    exclamation = string.char(0x81, 0x49),
    macron =      string.char(0x81, 0x50), -- ¯
    zero =        string.char(0x81, 0x5A),
    bar =         string.char(0x81, 0x5B), -- ?
    emdash =      string.char(0x81, 0x5C), -- —
    endash =      string.char(0x81, 0x5D), -- –
    slash =       string.char(0x81, 0x5E),
    bslash =      string.char(0x81, 0x5F),
    cdots =       string.char(0x81, 0x63), -- … centered vertically
    dots =        string.char(0x81, 0x64), -- .. centered vertically

    -- Typography
    tilde =       string.char(0x81, 0x3E), -- ~
    wave =        string.char(0x81, 0x60), -- ?
    ditto =       string.char(0x81, 0x56), -- ?
    amp =         string.char(0x81, 0x95),
    asterisk =    string.char(0x81, 0x96),
    at =          string.char(0x81, 0x97),
    underscore =  string.char(0x81, 0x51),
    dagger =      string.char(0x81, 0xEE), -- †
    ddagger =     string.char(0x81, 0xEF), -- ‡
    parallel =    string.char(0x81, 0x61), -- ||
    pipe =        string.char(0x81, 0x62), -- |
    hash =        string.char(0x81, 0x94),
    section =     string.char(0x81, 0x98), -- §
    ref =         string.char(0x81, 0xA6), -- ?
    post =        string.char(0x81, 0xA7), -- ?
    tie =         string.char(0x81, 0xD1), -- ?
    para =        string.char(0x81, 0xF7), -- ¶

    -- Quotes
    lsquo =       string.char(0x81, 0x65), -- ‘
    rsquo =       string.char(0x81, 0x66), -- ’
    ldquo =       string.char(0x81, 0x67), -- “
    rdquo =       string.char(0x81, 0x68), -- ”

    -- Brackets
    lpar =        string.char(0x81, 0x69), -- (
    rpar =        string.char(0x81, 0x6A), -- )
    ltort =       string.char(0x81, 0x6B), -- ?
    rtort =       string.char(0x81, 0x6C), -- ?
    lbrack =      string.char(0x81, 0x6D), -- [
    rbrack =      string.char(0x81, 0x6E), -- ]
    lbrace =      string.char(0x81, 0x6F), -- {
    rbrace =      string.char(0x81, 0x70), -- }
    lang =        string.char(0x81, 0x71), -- <
    rang =        string.char(0x81, 0x72), -- >
    ldangle =     string.char(0x81, 0x73), -- «
    rdangle =     string.char(0x81, 0x74), -- »
    lcorner =     string.char(0x81, 0x75), -- ?
    rcorner =     string.char(0x81, 0x76), -- ?
    lwcorner =    string.char(0x81, 0x77), -- ?
    rwcorner =    string.char(0x81, 0x78), -- ?
    lblent =      string.char(0x81, 0x79), -- ?
    rblent =      string.char(0x81, 0x7A), -- ?
    laquo =       string.char(0x85, 0x6B), -- «
    raquo =       string.char(0x85, 0x7B), -- »

    -- Math (General)
    plus =        string.char(0x81, 0x7B),
    minus =       string.char(0x81, 0x7C),
    plusminus =   string.char(0x81, 0x7D), -- ±
    times =       string.char(0x81, 0x7E), -- ×
    div =         string.char(0x81, 0x80), -- ÷
    eq =          string.char(0x81, 0x81), -- =
    neq =         string.char(0x81, 0x82), -- ?
    lt =          string.char(0x81, 0x83),
    gt =          string.char(0x81, 0x84),
    leq =         string.char(0x81, 0x85), -- ?
    geq =         string.char(0x81, 0x86), -- ?
    ll =          string.char(0x81, 0xD6), -- «
    gg =          string.char(0x81, 0xD7), -- »
    root =        string.char(0x81, 0xD8), -- v
    inf =         string.char(0x81, 0x87), -- 8
    prop =        string.char(0x81, 0xE5), -- ?
    ninf =        string.char(0x81, 0xD9), -- open infinity in the middle
    nearlyeq =    string.char(0x81, 0xD5), -- ?

    -- Math (Sets)
    ['in'] =      string.char(0x81, 0xAD), -- ?
    subseteq =    string.char(0x81, 0xAE), -- ?
    supseteq =    string.char(0x81, 0xB0), -- ?
    subset =      string.char(0x81, 0xB1), -- ?
    supset =      string.char(0x81, 0xB2), -- ?
    union =       string.char(0x81, 0xB3), -- ?
    intersect =   string.char(0x81, 0xB4), -- n

    -- Math (Analysis)
    nabla =       string.char(0x81, 0xD3), -- ?
    integral =    string.char(0x81, 0xE7), -- ?
    dintegral =   string.char(0x81, 0xE8), -- ??

    -- Math (Logical)
    therefore =   string.char(0x81, 0x88), -- ?
    bc =          string.char(0x81, 0xE6), -- ?
    min =         string.char(0x81, 0xB5), -- ?
    max =         string.char(0x81, 0xB6), -- ?
    neg =         string.char(0x81, 0xB7), -- ¬
    implies =     string.char(0x81, 0xC3), -- ?
    iff =         string.char(0x81, 0xC4), -- ?
    foreach =     string.char(0x81, 0xC5), -- ?
    exists =      string.char(0x81, 0xC6), -- ?
    bot =         string.char(0x81, 0xD0), -- ?
    part =        string.char(0x81, 0xD2), -- ?
    equiv =       string.char(0x81, 0xD4), -- =

    -- Math (Fractions)
    ['1div4'] =   string.char(0x85, 0x7C), -- ¼
    ['1div2'] =   string.char(0x85, 0x7D), -- ½
    ['3div4'] =   string.char(0x85, 0x7E), -- ¾

    -- Math (Geometry)
    degree =      string.char(0x81, 0x8B), -- °
    arcmin =      string.char(0x81, 0x8C), -- '
    arcsec =      string.char(0x81, 0x8D), -- ?
    angle =       string.char(0x81, 0xC7), -- ?
    rangle =      string.char(0x87, 0x98), -- ?
    lrtriangle =  string.char(0x87, 0x99), -- ?

    -- Polygons
    bstar =       string.char(0x81, 0x99), -- ?
    wstar =       string.char(0x81, 0x9A), -- ?
    brhombus =    string.char(0x81, 0x9E), -- black rhombus
    wrhombus =    string.char(0x81, 0x9F), -- white rhombus
    bsquare =     string.char(0x81, 0xA0), -- black square
    wsquare =     string.char(0x81, 0xA1), -- white square
    btriangle =   string.char(0x81, 0xA2), -- black triagle
    wtriangle =   string.char(0x81, 0xA3), -- white triangle
    bustriangle = string.char(0x81, 0xA4), -- black upside triangle
    wustriangle = string.char(0x81, 0xA5), -- white upside triangle

    -- Circles
    bcircle =     string.char(0x81, 0x9B), -- black circle
    wcircle =     string.char(0x81, 0x9C), -- white circle
    circlejot =   string.char(0x81, 0x9D), -- circle in circle

    -- Arrows
    rarr =        string.char(0x81, 0xA8), -- ?
    larr =        string.char(0x81, 0xA9), -- ?
    uarr =        string.char(0x81, 0xAA), -- ?
    darr =        string.char(0x81, 0xAB), -- ?

    -- Financial
    dollar =      string.char(0x81, 0x90), -- $
    cent =        string.char(0x81, 0x91), -- ¢
    pound =       string.char(0x81, 0x92), -- £
    euro =        string.char(0x85, 0x40), -- €
    yen =         string.char(0x85, 0x65), -- ¥

    -- Musical
    sharp =       string.char(0x81, 0xEB), -- ?
    flat =        string.char(0x81, 0xEC), -- ?
    note =        string.char(0x81, 0xED), -- ?

    -- Misc
    male =        string.char(0x81, 0x89), -- ?
    female =      string.char(0x81, 0x8A), -- ?
    percent =     string.char(0x81, 0x93),
    permil =      string.char(0x81, 0xEA), -- ‰
    circle =      string.char(0x81, 0xF8),
    cdegree =     string.char(0x81, 0x8E), -- °C
    tm =          string.char(0x85, 0x59), -- ™
    copy =        string.char(0x85, 0x69), -- ©

    -- Alphanumeric characters (Japanese)
    j0 =           string.char(0x82, 0x4F),
    j1 =           string.char(0x82, 0x50),
    j2 =           string.char(0x82, 0x51),
    j3 =           string.char(0x82, 0x52),
    j4 =           string.char(0x82, 0x53),
    j5 =           string.char(0x82, 0x54),
    j6 =           string.char(0x82, 0x55),
    j7 =           string.char(0x82, 0x56),
    j8 =           string.char(0x82, 0x57),
    j9 =           string.char(0x82, 0x58),
    jA =           string.char(0x82, 0x60),
    jB =           string.char(0x82, 0x61),
    jC =           string.char(0x82, 0x62),
    jD =           string.char(0x82, 0x63),
    jE =           string.char(0x82, 0x64),
    jF =           string.char(0x82, 0x65),
    jG =           string.char(0x82, 0x66),
    jH =           string.char(0x82, 0x67),
    jI =           string.char(0x82, 0x68),
    jJ =           string.char(0x82, 0x69),
    jK =           string.char(0x82, 0x6A),
    jL =           string.char(0x82, 0x6B),
    jM =           string.char(0x82, 0x6C),
    jN =           string.char(0x82, 0x6D),
    jO =           string.char(0x82, 0x6E),
    jP =           string.char(0x82, 0x6F),
    jQ =           string.char(0x82, 0x70),
    jR =           string.char(0x82, 0x71),
    jS =           string.char(0x82, 0x72),
    jT =           string.char(0x82, 0x73),
    jU =           string.char(0x82, 0x74),
    jV =           string.char(0x82, 0x75),
    jW =           string.char(0x82, 0x76),
    jX =           string.char(0x82, 0x77),
    jY =           string.char(0x82, 0x78),
    jZ =           string.char(0x82, 0x79),
    ja =           string.char(0x82, 0x81),
    jb =           string.char(0x82, 0x82),
    jc =           string.char(0x82, 0x83),
    jd =           string.char(0x82, 0x84),
    je =           string.char(0x82, 0x85),
    jf =           string.char(0x82, 0x86),
    jg =           string.char(0x82, 0x87),
    jh =           string.char(0x82, 0x88),
    ji =           string.char(0x82, 0x89),
    jj =           string.char(0x82, 0x8A),
    jk =           string.char(0x82, 0x8B),
    jl =           string.char(0x82, 0x8C),
    jm =           string.char(0x82, 0x8D),
    jn =           string.char(0x82, 0x8E),
    jo =           string.char(0x82, 0x8F),
    jp =           string.char(0x82, 0x90),
    jq =           string.char(0x82, 0x91),
    jr =           string.char(0x82, 0x92),
    js =           string.char(0x82, 0x93),
    jt =           string.char(0x82, 0x94),
    ju =           string.char(0x82, 0x95),
    jv =           string.char(0x82, 0x96),
    jw =           string.char(0x82, 0x97),
    jx =           string.char(0x82, 0x98),
    jy =           string.char(0x82, 0x99),
    jz =           string.char(0x82, 0x9A),

    -- Greek letters
    Alpha =       string.char(0x83, 0x97),
    Beta =        string.char(0x83, 0x98),
    Gamma =       string.char(0x83, 0x99),
    Delta =       string.char(0x83, 0x9A),
    Epsilon =     string.char(0x83, 0x9B),
    Zeta =        string.char(0x83, 0x9C),
    Eta =         string.char(0x83, 0x9D),
    Theta =       string.char(0x83, 0x9E),
    Iota =        string.char(0x83, 0xA7),
    Kappa =       string.char(0x83, 0xA8),
    Lambda =      string.char(0x83, 0xA9),
    Mu =          string.char(0x83, 0xAA),
    Nu =          string.char(0x83, 0xAB),
    Xi =          string.char(0x83, 0xAC),
    Omicron =     string.char(0x83, 0xAD),
    Pi =          string.char(0x83, 0xAE),
    Rho =         string.char(0x83, 0xAF),
    Sigma =       string.char(0x83, 0xB0),
    Tau =         string.char(0x83, 0xB1),
    Upsilon =     string.char(0x83, 0xB2),
    Phi =         string.char(0x83, 0xB3),
    Chi =         string.char(0x83, 0xB4),
    Psi =         string.char(0x83, 0xB5),
    Omega =       string.char(0x83, 0xB6),
    alpha =       string.char(0x83, 0xB7),
    beta =        string.char(0x83, 0xB8),
    gamma =       string.char(0x83, 0xB9),
    delta =       string.char(0x83, 0xBA),
    epsilon =     string.char(0x83, 0xBB),
    zeta =        string.char(0x83, 0xBC),
    eta =         string.char(0x83, 0xBD),
    theta =       string.char(0x83, 0xBE),
    iota =        string.char(0x83, 0xC7),
    kappa =       string.char(0x83, 0xC8),
    lambda =      string.char(0x83, 0xC9),
    mu =          string.char(0x83, 0xCA),
    nu =          string.char(0x83, 0xCB),
    xi =          string.char(0x83, 0xCC),
    omicron =     string.char(0x83, 0xCD),
    pi =          string.char(0x83, 0xCE),
    rho =         string.char(0x83, 0xCF),
    sigma =       string.char(0x83, 0xD0),
    tau =         string.char(0x83, 0xD1),
    upsilon =     string.char(0x83, 0xD2),
    phi =         string.char(0x83, 0xD3),
    chi =         string.char(0x83, 0xD4),
    psi =         string.char(0x83, 0xD5),
    omega =       string.char(0x83, 0xD6),

    -- lines
    hline =       string.char(0x84, 0x92), -- -
    vline =       string.char(0x84, 0x93), -- ¦
    tl =          string.char(0x84, 0x94), -- +
    tr =          string.char(0x84, 0x95), -- +
    br =          string.char(0x84, 0x96), -- +
    bl =          string.char(0x84, 0x97), -- +
    left =        string.char(0x84, 0x98), -- +
    top =         string.char(0x84, 0x99), -- -
    right =       string.char(0x84, 0x9A), -- ¦
    bottom =      string.char(0x84, 0x9B), -- -
    middle =      string.char(0x84, 0x9C), -- +
    bhline =      string.char(0x84, 0xAA), -- -
    bvline =      string.char(0x84, 0xAB), -- ¦
    btl =         string.char(0x84, 0xAB), -- +
    btr =         string.char(0x84, 0xAC), -- +
    bbr =         string.char(0x84, 0xAD), -- +
    bbl =         string.char(0x84, 0xAE), -- +
    bleft =       string.char(0x84, 0xB0), -- +
    btop =        string.char(0x84, 0xB1), -- -
    bright =      string.char(0x84, 0xB2), -- ¦
    bbottom =     string.char(0x84, 0xB3), -- -
    bmiddle =     string.char(0x84, 0xB4), -- +

    -- sup numbers 1-4
    sup0 =        string.char(0x85, 0x7A),
    sup1 =        string.char(0x85, 0x79),
    sup2 =        string.char(0x85, 0x72),
    sup3 =        string.char(0x85, 0x73),

    -- circled numbers 1-20
    circle1 =     string.char(0x87, 0x40),
    circle2 =     string.char(0x87, 0x41),
    circle3 =     string.char(0x87, 0x42),
    circle4 =     string.char(0x87, 0x43),
    circle5 =     string.char(0x87, 0x44),
    circle6 =     string.char(0x87, 0x45),
    circle7 =     string.char(0x87, 0x46),
    circle8 =     string.char(0x87, 0x47),
    circle9 =     string.char(0x87, 0x48),
    circle10 =    string.char(0x87, 0x49),
    circle11 =    string.char(0x87, 0x4A),
    circle12 =    string.char(0x87, 0x4B),
    circle13 =    string.char(0x87, 0x4C),
    circle14 =    string.char(0x87, 0x4D),
    circle15 =    string.char(0x87, 0x4E),
    circle16 =    string.char(0x87, 0x4F),
    circle17 =    string.char(0x87, 0x50),
    circle18 =    string.char(0x87, 0x51),
    circle19 =    string.char(0x87, 0x52),
    circle20 =    string.char(0x87, 0x53),

    -- roman numerals 1-10
    roman1 =      string.char(0x87, 0x54),
    roman2 =      string.char(0x87, 0x55),
    roman3 =      string.char(0x87, 0x56),
    roman4 =      string.char(0x87, 0x57),
    roman5 =      string.char(0x87, 0x58),
    roman6 =      string.char(0x87, 0x59),
    roman7 =      string.char(0x87, 0x5A),
    roman8 =      string.char(0x87, 0x5B),
    roman9 =      string.char(0x87, 0x5C),
    roman10 =     string.char(0x87, 0x5D),

    -- abbreviations
    mm =          string.char(0x87, 0x6F),
    cm =          string.char(0x87, 0x70),
    km =          string.char(0x87, 0x71),
    mg =          string.char(0x87, 0x72),
    kg =          string.char(0x87, 0x73),
    cc =          string.char(0x87, 0x74),
    m2 =          string.char(0x87, 0x75),
    no =          string.char(0x87, 0x82),
    kk =          string.char(0x87, 0x83),
    tel =         string.char(0x87, 0x84),
}
