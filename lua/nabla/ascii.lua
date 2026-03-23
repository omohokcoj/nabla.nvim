-- Generated using ntangle.nvim
local to_ascii

local utf8len, utf8char

local combine_brackets

local stack_subsup

local grid_of_exps

local combine_matrix_grid

local unpack_explist

local put_subsup_aside

local put_if_only_sub

local put_if_only_sup


local style = {
	div_high_bar = "‾",
	div_middle_bar = "―",
	div_low_bar = "_",

	left_top_par    = '⎛',
	left_middle_par = '⎜',
	left_bottom_par = '⎝',

	right_top_par    = '⎞',
	right_middle_par = '⎟',
	right_bottom_par = '⎠',

	left_single_par = '(',
	right_single_par = ')',

	comma_sign = ", ", 

	eq_sign = {
		["="] = " = ",
		["<"] = " < ",
		[">"] = " > ",
		[">="] = " ≥ ",
		["<="] = " ≤ ",
		[">>"] = " ≫ ",
		["<<"] = " ≪ ",
		["~="] = " ≈ ",
		["!="] = " ≠ ",
		["=>"] = " → ",

	},

	prefix_minus_sign = "‐",

	root_vert_bar = "│",
	root_bottom = "\\",
	root_upper_left = "┌",
	root_upper = "─",
	root_upper_right = "┐",

	box_upper_left = "┌",
	box_upper = "─",
	box_upper_right = "┐",
	box_vert = "│",
	box_lower_left = "└",
	box_lower = "─",
	box_lower_right = "┘",

	matrix_upper_left = "⎡", 
	matrix_upper_right = "⎤", 
	matrix_vert_left = "⎢",
	matrix_lower_left = "⎣", 
	matrix_lower_right = "⎦", 
	matrix_vert_right = "⎥",
	matrix_single_left = "[",
	matrix_single_right = "]",

	left_top_bra    = '⎧',
	left_middle_bra = '⎨',
	left_other_bra  = '⎥',
	left_bottom_bra = '⎩',

	right_top_bra    = '⎫',
	right_middle_bra = '⎬',
	right_other_bra =  '⎪',
	right_bottom_bra = '⎭',

	left_single_bra = '{',
	right_single_bra = '}',

	vec_arrow = "→",

}

local greek_etc = {
  ["Alpha"] = "Α", ["Beta"] = "Β", ["Gamma"] = "Γ", ["Delta"] = "Δ", ["Epsilon"] = "Ε", ["Zeta"] = "Ζ", ["Eta"] = "Η", ["Theta"] = "Θ", ["Iota"] = "Ι", ["Kappa"] = "Κ", ["Lambda"] = "Λ", ["Mu"] = "Μ", ["Nu"] = "Ν", ["Xi"] = "Ξ", ["Omicron"] = "Ο", ["Pi"] = "Π", ["Rho"] = "Ρ", ["Sigma"] = "Σ", ["Tau"] = "Τ", ["Upsilon"] = "Υ", ["Phi"] = "Φ", ["Chi"] = "Χ", ["Psi"] = "Ψ", ["Omega"] = "Ω",

  ["alpha"] = "α", ["beta"] = "β", ["gamma"] = "γ", ["delta"] = "δ", ["epsilon"] = "ε", ["zeta"] = "ζ", ["eta"] = "η", ["theta"] = "θ", ["iota"] = "ι", ["kappa"] = "κ", ["lambda"] = "λ", ["mu"] = "μ", ["nu"] = "ν", ["xi"] = "ξ", ["omicron"] = "ο", ["pi"] = "π", ["rho"] = "ρ", ["final"] = "ς", ["sigma"] = "σ", ["tau"] = "τ", ["upsilon"] = "υ", ["phi"] = "φ", ["chi"] = "χ", ["psi"] = "ψ", ["omega"] = "ω",

  ["nabla"] = "∇",

}

local special_nums = {
  ["infty"] = "∞",

}

local special_syms = {
	["..."] = "…",

	["cdot"] = "∙",
	["approx"] = "≈",
	["simeq"] = "≃",
	["sim"] = "∼",
	["propto"] = "∝",
	["neq"] = "≠",
	["ne"] = "≠",
	["doteq"] = "≐",
	["leq"] = "≤",
	["cong"] = "≅",

		["pm"] = "±",
		["mp"] = "∓",
		["to"] = "→",

	["rightarrow"] = "→",
	["implies"] = "→",
	["leftarrow"] = "⭠",
	["ast"] = "∗",

	["partial"] = "∂",

	["otimes"] = "⊗",
	["oplus"] = "⊕",
	["times"] = "⨯",
	["perp"] = "⟂",
	["circ"] = "∘",
	["langle"] = "⟨",
	["rangle"] = "⟩",
	["dagger"] = "†",
	["intercal"] = "⊺",
	["wedge"] = "∧",
	["vert"] = "|",
	["Vert"] = "‖",
	["C"] = "ℂ",
	["N"] = "ℕ",
	["Q"] = "ℚ",
	["R"] = "ℝ",
	["Z"] = "ℤ",
	["qed"] = "∎",
	["AA"] = "Å",
	["aa"] = "å",
	["ae"] = "æ",
	["AE"] = "Æ",
	["aleph"] = "ℵ",
	["allequal"] = "≌",
	["amalg"] = "⨿",
	["angle"] = "∠",
	["Angle"] = "⦜",
	["approxeq"] = "≊",
	["approxnotequal"] = "≆",
	["aquarius"] = "♒",
	["arccos"] = "arccos",
	["arccot"] = "arccot",
	["arcsin"] = "arcsin",
	["arctan"] = "arctan",
	["aries"] = "♈",
	["arrowwaveright"] = "↜",
	["asymp"] = "≍",
	["backepsilon"] = "϶",
	["backprime"] = "‵",
	["backsimeq"] = "⋍",
	["backsim"] = "∽",
	["backslash"] = "⧵",
	["barwedge"] = "⌅",
	["because"] = "∵",
	["beth"] = "ℶ",
	["between"] = "≬",
	["bigcap"] = "⋂",
	["bigcirc"] = "○",
	["bigcup"] = "⋃",
	["bigtriangledown"] = "▽",
	["bigtriangleup"] = "△",
	["blacklozenge"] = "⧫",
	["blacksquare"] = "■",
	["blacktriangledown"] = "▾",
	["blacktriangleleft"] = "◂",
	["blacktriangleright"] = "▸",
	["blacktriangle"] = "▴",
	["bot"] = "⊥",
	["bowtie"] = "⋈",
	["boxdot"] = "⊡",
	["boxminus"] = "⊟",
	["boxplus"] = "⊞",
	["boxtimes"] = "⊠",
	["Box"] = "□",
	["bullet"] = "∙",
	["bumpeq"] = "≏",
	["Bumpeq"] = "≎",
	["cancer"] = "♋",
	["capricornus"] = "♑",
	["cap"] = "∩",
	["Cap"] = "⋒",
	["circeq"] = "≗",
	["circlearrowleft"] = "↺",
	["circlearrowright"] = "↻",
	["circledast"] = "⊛",
	["circledcirc"] = "⊚",
	["circleddash"] = "⊝",
	["circledS"] = "Ⓢ",
	["clockoint"] = "⨏",
	["clubsuit"] = "♣",
	["clwintegral"] = "∱",
	["Colon"] = "∷",
	["complement"] = "∁",
	["coprod"] = "∐",
	["copyright"] = "©",
	["cosh"] = "cosh",
	["cos"] = "cos",
	["coth"] = "coth",
	["cot"] = "cot",
	["csc"] = "csc",
	["cup"] = "∪",
	["Cup"] = "⋓",
	["curlyeqprec"] = "⋞",
	["curlyeqsucc"] = "⋟",
	["curlyvee"] = "⋎",
	["curlywedge"] = "⋏",
	["curvearrowleft"] = "↶",
	["curvearrowright"] = "↷",
	["daleth"] = "ℸ",
	["dashv"] = "⊣",
	["dblarrowupdown"] = "⇅",
	["ddagger"] = "‡",
	["dh"] = "ð",
	["DH"] = "Ð",
	["diagup"] = "╱",
	["diamondsuit"] = "♢",
	["diamond"] = "⋄",
	["Diamond"] = "◇",
	["digamma"] = "ϝ",
	["Digamma"] = "Ϝ",
	["divideontimes"] = "⋇",
	["div"] = "÷",
	["dj"] = "đ",
	["DJ"] = "Đ",
	["doteqdot"] = "≑",
	["dotplus"] = "∔",
	["DownArrowBar"] = "⤓",
	["downarrow"] = "↓",
	["Downarrow"] = "⇓",
	["DownArrowUpArrow"] = "⇵",
	["downdownarrows"] = "⇊",
	["downharpoonleft"] = "⇃",
	["downharpoonright"] = "⇂",
	["DownLeftRightVector"] = "⥐",
	["DownLeftTeeVector"] = "⥞",
	["DownLeftVectorBar"] = "⥖",
	["DownRightTeeVector"] = "⥟",
	["DownRightVectorBar"] = "⥗",
	["downslopeellipsis"] = "⋱",
	["eighthnote"] = "♪",
	["ell"] = "ℓ",
	["Elolarr"] = "⥀",
	["Elorarr"] = "⥁",
	["ElOr"] = "⩖",
	["Elroang"] = "⦆",
	["Elxsqcup"] = "⨆",
	["Elxuplus"] = "⨄",
	["ElzAnd"] = "⩓",
	["Elzbtdl"] = "ɬ",
	["ElzCint"] = "⨍",
	["Elzcirfb"] = "◒",
	["Elzcirfl"] = "◐",
	["Elzcirfr"] = "◑",
	["Elzclomeg"] = "ɷ",
	["Elzddfnc"] = "⦙",
	["Elzdefas"] = "⧋",
	["Elzdlcorn"] = "⎣",
	["Elzdshfnc"] = "┆",
	["Elzdyogh"] = "ʤ",
	["Elzesh"] = "ʃ",
	["Elzfhr"] = "ɾ",
	["Elzglst"] = "ʔ",
	["Elzhlmrk"] = "ˑ",
	["ElzInf"] = "⨇",
	["Elzinglst"] = "ʖ",
	["Elzinvv"] = "ʌ",
	["Elzinvw"] = "ʍ",
	["ElzLap"] = "⧊",
	["Elzlmrk"] = "ː",
	["Elzlow"] = "˕",
	["Elzlpargt"] = "⦠",
	["Elzltlmr"] = "ɱ",
	["Elzltln"] = "ɲ",
	["Elzminhat"] = "⩟",
	["Elzopeno"] = "ɔ",
	["ElzOr"] = "⩔",
	["Elzpbgam"] = "ɤ",
	["Elzpgamma"] = "ɣ",
	["Elzpscrv"] = "ʋ",
	["Elzpupsil"] = "ʊ",
	["Elzrais"] = "˔",
	["Elzrarrx"] = "⥇",
	["Elzreapos"] = "‛",
	["Elzreglst"] = "ʕ",
	["ElzrLarr"] = "⥄",
	["ElzRlarr"] = "⥂",
	["Elzrl"] = "ɼ",
	["Elzrtld"] = "ɖ",
	["Elzrtll"] = "ɭ",
	["Elzrtln"] = "ɳ",
	["Elzrtlr"] = "ɽ",
	["Elzrtls"] = "ʂ",
	["Elzrtlt"] = "ʈ",
	["Elzrtlz"] = "ʐ",
	["Elzrttrnr"] = "ɻ",
	["Elzrvbull"] = "◘",
	["Elzsblhr"] = "˓",
	["Elzsbrhr"] = "˒",
	["Elzschwa"] = "ə",
	["Elzsqfl"] = "◧",
	["Elzsqfnw"] = "┙",
	["Elzsqfr"] = "◨",
	["Elzsqfse"] = "◪",
	["Elzsqspne"] = "⋥",
	["ElzSup"] = "⨈",
	["Elztdcol"] = "⫶",
	["Elztesh"] = "ʧ",
	["Elztfnc"] = "⦀",
	["ElzThr"] = "⨅",
	["ElzTimes"] = "⨯",
	["Elztrna"] = "ɐ",
	["Elztrnh"] = "ɥ",
	["Elztrnmlr"] = "ɰ",
	["Elztrnm"] = "ɯ",
	["Elztrnrl"] = "ɺ",
	["Elztrnr"] = "ɹ",
	["Elztrnsa"] = "ɒ",
	["Elztrnt"] = "ʇ",
	["Elztrny"] = "ʎ",
	["Elzverti"] = "ˌ",
	["Elzverts"] = "ˈ",
	["Elzvrecto"] = "▯",
	["Elzxh"] = "ħ",
	["Elzxrat"] = "℞",
	["Elzyogh"] = "ʒ",
	["emptyset"] = "∅",
	["eqcirc"] = "≖",
	["eqslantgtr"] = "⪖",
	["eqslantless"] = "⪕",
	["Equal"] = "⩵",
	["equiv"] = "≡",
	["estimates"] = "≙",
	["eth"] = "ð",
	["exists"] = "∃",
	["fallingdotseq"] = "≒",
	["flat"] = "♭",
	["forall"] = "∀",
	["forcesextra"] = "⊨",
	["frown"] = "⌢",
	["gemini"] = "♊",
	["geqq"] = "≧",
	["geqslant"] = "⩾",
	["geq"] = "≥",
	["gets"] = "⟵",
	["ge"] = "≥",
	["gg"] = "≫",
	["gimel"] = "ℷ",
	["gnapprox"] = "⪊",
	["gneqq"] = "≩",
	["gneq"] = "⪈",
	["gnsim"] = "⋧",
	["greaterequivlnt"] = "≳",
	["gtrapprox"] = "⪆",
	["gtrdot"] = "⋗",
	["gtreqless"] = "⋛",
	["gtreqqless"] = "⪌",
	["gtrless"] = "≷",
	["guillemotleft"] = "«",
	["guillemotright"] = "»",
	["guilsinglleft"] = "‹",
	["guilsinglright"] = "›",
	["hbar"] = "ℏ",
	["heartsuit"] = "♡",
	["hermitconjmatrix"] = "⊹",
	["homothetic"] = "∻",
	["hookleftarrow"] = "↩",
	["hookrightarrow"] = "↪",
	["hslash"] = "ℏ",
	["idotsint"] = "∫⋯∫",
	["iff"] = "⟺",
	["image"] = "⊷",
	["imath"] = "ı",
	["Im"] = "ℑ",
	["in"] = "∈",
	["varin"] = "𝛜",
	["jmath"] = "ȷ",
	["Join"] = "⋈",
	["jupiter"] = "♃",
	["Koppa"] = "Ϟ",
	["land"] = "∧",
	["lazysinv"] = "∾",
	["lbrace"] = "{",
	["lceil"] = "⌈",
	["leadsto"] = "↝",
	["leftarrowtail"] = "↢",
	["Leftarrow"] = "⇐",
	["LeftDownTeeVector"] = "⥡",
	["LeftDownVectorBar"] = "⥙",
	["leftharpoondown"] = "↽",
	["leftharpoonup"] = "↼",
	["leftleftarrows"] = "⇇",
	["leftrightarrows"] = "⇆",
	["leftrightarrow"] = "↔",
	["Leftrightarrow"] = "⇔",
	["leftrightharpoons"] = "⇋",
	["leftrightsquigarrow"] = "↭",
	["LeftRightVector"] = "⥎",
	["LeftTeeVector"] = "⥚",
	["leftthreetimes"] = "⋋",
	["LeftTriangleBar"] = "⧏",
	["LeftUpDownVector"] = "⥑",
	["LeftUpTeeVector"] = "⥠",
	["LeftUpVectorBar"] = "⥘",
	["LeftVectorBar"] = "⥒",
	["leo"] = "♌",
	["leqq"] = "≦",
	["leqslant"] = "⩽",
	["lessapprox"] = "⪅",
	["lessdot"] = "⋖",
	["lesseqgtr"] = "⋚",
	["lesseqqgtr"] = "⪋",
	["lessequivlnt"] = "≲",
	["lessgtr"] = "≶",
	["le"] = "≤",
	["lfloor"] = "⌊",
	["lhd"] = "⊲",
	["libra"] = "♎",
	["llcorner"] = "⌞",
	["Lleftarrow"] = "⇚",
	["ll"] = "≪",
	["lmoustache"] = "⎰",
	["lnapprox"] = "⪉",
	["lneqq"] = "≨",
	["lneq"] = "⪇",
	["lnot"] = "¬",
	["lnsim"] = "≴",
	["longleftarrow"] = "⟵",
	["Longleftarrow"] = "⇐",
	["longleftrightarrow"] = "↔",
	["Longleftrightarrow"] = "⇔",
	["longmapsto"] = "⇖",
	["longrightarrow"] = "⟶",
	["Longrightarrow"] = "⇒",
	["looparrowleft"] = "↫",
	["looparrowright"] = "↬",
	["lor"] = "∨",
	["lozenge"] = "◊",
	["lrcorner"] = "⌟",
	["Lsh"] = "↰",
	["ltimes"] = "⋉",
	["l"] = "ł",
	["L"] = "Ł",
	["male"] = "♂",
	["mapsto"] = "↦",
	["measuredangle"] = "∡",
	["mercury"] = "☿",
	["mho"] = "℧",
	["mid"] = "∣",
	["models"] = "⊨",
	["multimap"] = "⊸",
	["natural"] = "♮",
	["nearrow"] = "↗",
	["neg"] = "¬",
	["neptune"] = "♆",
	["NestedGreaterGreater"] = "⪢",
	["NestedLessLess"] = "⪡",
	["nexists"] = "∄",
	["ngeq"] = "≠",
	["ngtr"] = "≯",
	["ng"] = "ŋ",
	["NG"] = "Ŋ",
	["ni"] = "∋",
	["nleftarrow"] = "↚",
	["nLeftarrow"] = "⇍",
	["nleftrightarrow"] = "↮",
	["nLeftrightarrow"] = "⇎",
	["nleq"] = "≰",
	["nless"] = "≮",
	["nmid"] = "∤",
	["notgreaterless"] = "≹",
	["notin"] = "∉",
	["notlessgreater"] = "≸",
	["nparallel"] = "∦",
	["nrightarrow"] = "↛",
	["nRightarrow"] = "⇏",
	["nsubseteq"] = "⊊",
	["nsupseteq"] = "⊋",
	["ntrianglelefteq"] = "⋬",
	["ntriangleleft"] = "⋪",
	["ntrianglerighteq"] = "⋭",
	["ntriangleright"] = "⋫",
	["nvdash"] = "⊬",
	["nvDash"] = "⊭",
	["nVdash"] = "⊮",
	["nVDash"] = "⊯",
	["nwarrow"] = "↖",
	["odot"] = "⊙",
	["oe"] = "œ",
	["OE"] = "Œ",
	["ominus"] = "⊖",
	["openbracketleft"] = "〚",
	["openbracketright"] = "〛",
	["original"] = "⊶",
	["oslash"] = "⊘",
	["o"] = "ø",
	["O"] = "Ø",
	["perspcorrespond"] = "⌆",
	["pisces"] = "♓",
	["pitchfork"] = "⋔",
	["pluto"] = "♇",
	["precapprox"] = "≾",
	["preccurlyeq"] = "≼",
	["precedesnotsimilar"] = "⋨",
	["preceq"] = "≼",
	["precnapprox"] = "⪹",
	["precneqq"] = "⪵",
	["prime"] = "′",
	["P"] = "¶",
	["quarternote"] = "♩",
	["rbrace"] = "}",
	["rceil"] = "⌉",
	["recorder"] = "⌕",
	["Re"] = "ℜ",
	["ReverseUpEquilibrium"] = "⥯",
	["rfloor"] = "⌋",
	["rhd"] = "⊳",
	["rightanglearc"] = "⊾",
	["rightangle"] = "∟",
	["rightarrowtail"] = "↣",
	["Rightarrow"] = "⇒",
	["RightDownTeeVector"] = "⥝",
	["RightDownVectorBar"] = "⥕",
	["rightharpoondown"] = "⇁",
	["rightharpoonup"] = "⇀",
	["rightleftarrows"] = "⇄",
	["rightleftharpoons"] = "⇌",
	["rightmoon"] = "☾",
	["rightrightarrows"] = "⇉",
	["rightsquigarrow"] = "⇝",
	["RightTeeVector"] = "⥛",
	["rightthreetimes"] = "⋌",
	["RightTriangleBar"] = "⧐",
	["RightUpDownVector"] = "⥏",
	["RightUpTeeVector"] = "⥜",
	["RightUpVectorBar"] = "⥔",
	["RightVectorBar"] = "⥓",
	["risingdotseq"] = "≓",
	["rmoustache"] = "⎱",
	["RoundImplies"] = "⥰",
	["Rrightarrow"] = "⇛",
	["Rsh"] = "↱",
	["rtimes"] = "⋊",
	["RuleDelayed"] = "⧴",
	["sagittarius"] = "♐",
	["Sampi"] = "Ϡ",
	["saturn"] = "♄",
	["scorpio"] = "♏",
	["searrow"] = "↘",
	["sec"] = "sec",
	["setminus"] = "∖",
	["sharp"] = "♯",
	["sinh"] = "sinh",
	["sin"] = "sin",
	["smile"] = "⌣",
	["space"] = " ",
	["spadesuit"] = "♠",
	["sphericalangle"] = "∢",
	["sqcap"] = "⊓",
	["sqcup"] = "⊔",
	["sqrint"] = "⨖",
	["sqsubseteq"] = "⊑",
	["sqsubset"] = "⊏",
	["sqsupseteq"] = "⊒",
	["sqsupset"] = "⊐",
	["square"] = "□",
	["ss"] = "ß",
	["starequal"] = "≛",
	["star"] = "⋆",
	["Stigma"] = "Ϛ",
	["S"] = "§",
	["subseteqq"] = "⫅",
	["subseteq"] = "⊆",
	["subsetneqq"] = "⫋",
	["subsetneq"] = "⊊",
	["subset"] = "⊂",
	["Subset"] = "⋐",
	["succapprox"] = "≿",
	["succcurlyeq"] = "≽",
	["succeq"] = "≽",
	["succnapprox"] = "⪺",
	["succneqq"] = "⪶",
	["succnsim"] = "⋩",
	["succ"] = "≻",
	["supseteqq"] = "⫆",
	["supseteq"] = "⊇",
	["supsetneqq"] = "⫌",
	["supsetneq"] = "⊋",
	["supset"] = "⊃",
	["Supset"] = "⋑",
	["surd"] = "√",
	["surfintegral"] = "∯",
	["swarrow"] = "↙",
	["tanh"] = "tanh",
	["tan"] = "tan",
	["taurus"] = "♉",
	["textasciiacute"] = "´",
	["textasciibreve"] = "˘",
	["textasciicaron"] = "ˇ",
	["textasciidieresis"] = "¨",
	["textasciigrave"] = "`",
	["textasciimacron"] = "¯",
	["textasciitilde"] = "~",
	["textbackslash"] = "\\",
	["textbrokenbar"] = "¦",
	["textbullet"] = "•",
	["textcent"] = "¢",
	["textcopyright"] = "©",
	["textcurrency"] = "¤",
	["textdaggerdbl"] = "‡",
	["textdagger"] = "†",
	["textdegree"] = "°",
	["textdollar"] = "$",
	["textdoublepipe"] = "ǂ",
	["textemdash"] = "—",
	["textendash"] = "–",
	["textexclamdown"] = "¡",
	["texthvlig"] = "ƕ",
	["textnrleg"] = "ƞ",
	["textonehalf"] = "½",
	["textonequarter"] = "¼",
	["textordfeminine"] = "ª",
	["textordmasculine"] = "º",
	["textparagraph"] = "¶",
	["textperiodcentered"] = "˙",
	["textpertenthousand"] = "‱",
	["textperthousand"] = "‰",
	["textphi"] = "ɸ",
	["textquestiondown"] = "¿",
	["textquotedblleft"] = "“",
	["textquotedblright"] = "”",
	["textquotesingle"] = "'",
	["textregistered"] = "®",
	["textsection"] = "§",
	["textsterling"] = "£",
	["textTheta"] = "ϴ",
	["texttheta"] = "θ",
	["textthreequarters"] = "¾",
	["texttildelow"] = "˜",
	["texttimes"] = "×",
	["texttrademark"] = "™",
	["textturnk"] = "ʞ",
	["textvartheta"] = "ϑ",
	["textvisiblespace"] = "␣",
	["textyen"] = "¥",
	["therefore"] = "∴",
	["th"] = "þ",
	["TH"] = "Þ",
	["tildetrpl"] = "≋",
	["top"] = "⊤",
	["triangledown"] = "▿",
	["trianglelefteq"] = "⊴",
	["triangleleft"] = "◁",
	["triangleq"] = "≜",
	["trianglerighteq"] = "⊵",
	["triangleright"] = "▷",
	["triangle"] = "△",
	["truestate"] = "⊧",
	["twoheadleftarrow"] = "↞",
	["twoheadrightarrow"] = "↠",
	["ulcorner"] = "⌜",
	["unlhd"] = "⊴",
	["unrhd"] = "⊵",
	["UpArrowBar"] = "⤒",
	["uparrow"] = "↑",
	["Uparrow"] = "⇑",
	["updownarrow"] = "↕",
	["Updownarrow"] = "⇕",
	["UpEquilibrium"] = "⥮",
	["upharpoonleft"] = "↿",
	["upharpoonright"] = "↾",
	["uplus"] = "⊎",
	["upslopeellipsis"] = "⋰",
	["upuparrows"] = "⇈",
	["uranus"] = "♅",
	["urcorner"] = "⌝",
	["varepsilon"] = "ɛ",
	["varkappa"] = "ϰ",
	["varnothing"] = "∅",
	["varphi"] = "φ",
	["varpi"] = "ϖ",
	["varrho"] = "ϱ",
	["varsigma"] = "ς",
	["vartheta"] = "ϑ",
	["vartriangleleft"] = "⊲",
	["vartriangleright"] = "⊳",
	["vartriangle"] = "▵",
	["vdash"] = "⊢",
	["Vdash"] = "⊩",
	["VDash"] = "⊫",
	["veebar"] = "⊻",
	["vee"] = "∨",
	["venus"] = "♀",
	["verymuchgreater"] = "⋙",
	["verymuchless"] = "⋘",
	["virgo"] = "♍",
	["volintegral"] = "∰",
	["Vvdash"] = "⊪",
	["wp"] = "℘",
	["wr"] = "≀",

	["cdots"] = "⋯",
	["vdots"] = "⋮",
	["ddots"] = "⋱",
	["ldots"] = "…",
	["dots"] = "…", -- alias to ldots (for the moment)
}

local grid = {}
function grid:new(w, h, content, t)
	if not content and w and h and w > 0 and h > 0 then
		content = {}
		for y=1,h do
			local row = ""
			for x=1,w do
				row = row .. " "
			end
			table.insert(content, row)
		end
	end

	local o = { 
		w = w or 0, 
		h = h or 0, 
    t = t,
    children = {},
		content = content or {},
		my = 0, -- middle y (might not be h/2, for example fractions with big denominator, etc )

	}
	return setmetatable(o, { 
		__tostring = function(g)
			return table.concat(g.content, "\n")
		end,

		__index = grid,
	})
end

function grid:join_hori(g, top_align)
	local combined = {}

	local num_max = math.max(self.my, g.my)
	local den_max = math.max(self.h - self.my, g.h - g.my)

	local s1, s2
	if not top_align then
		s1 = num_max - self.my
		s2 = num_max - g.my
	else
		s1 = 0
		s2 = 0
	end

	local h 
	if not top_align then
		h = den_max + num_max
	else
		h = math.max(self.h, g.h)
	end


	for y=1,h do
		local r1 = self:get_row(y-s1)
		local r2 = g:get_row(y-s2)

		table.insert(combined, r1 .. r2)

	end

	local c = grid:new(self.w+g.w, h, combined)
	c.my = num_max

  table.insert(c.children, { self, 0, s1 })
  table.insert(c.children, { g, self.w, s2 })

	return c
end

function grid:get_row(y)
	if y < 1 or y > self.h then
		local s = ""
		for i=1,self.w do s = s .. " " end
		return s
	end
	return self.content[y]
end

function grid:join_vert(g, align_left)
	local w = math.max(self.w, g.w)
	local h = self.h+g.h
	local combined = {}

	local s1, s2
	if not align_left then
		s1 = math.floor((w-self.w)/2)
		s2 = math.floor((w-g.w)/2)
	else
		s1 = 0
		s2 = 0
	end

	for x=1,w do
		local c1 = self:get_col(x-s1)
		local c2 = g:get_col(x-s2)

		table.insert(combined, c1 .. c2)

	end

	local rows = {}
	for y=1,h do
		local row = ""
		for x=1,w do
			row = row .. utf8char(combined[x], y-1)
		end
		table.insert(rows, row)
	end

	local c = grid:new(w, h, rows)
  table.insert(c.children, { self, s1, 0 })
  table.insert(c.children, { g, s2, self.h })

  return c
end

function grid:get_col(x) 
	local s = ""
	if x < 1 or x > self.w then
		for i=1,self.h do s = s .. " " end
	else
		for y=1,self.h do
			s = s .. utf8char(self.content[y], x-1)
		end
	end
	return s
end

function grid:enclose_paren()
	local left_content = {}
	if self.h == 1 then
		left_content = { style.left_single_par }
	else
		for y=1,self.h do
			if y == 1 then table.insert(left_content, style.left_top_par)
			elseif y == self.h then table.insert(left_content, style.left_bottom_par)
			else table.insert(left_content, style.left_middle_par)
			end
		end
	end

	local left_paren = grid:new(1, self.h, left_content, "par")
	left_paren.my = self.my

	local right_content = {}
	if self.h == 1 then
		right_content = { style.right_single_par }
	else
		for y=1,self.h do
			if y == 1 then table.insert(right_content, style.right_top_par)
			elseif y == self.h then table.insert(right_content, style.right_bottom_par)
			else table.insert(right_content, style.right_middle_par)
			end
		end
	end

	local right_paren = grid:new(1, self.h, right_content, "par")
	right_paren.my = self.my


	local c1 = left_paren:join_hori(self)
	local c2 = c1:join_hori(right_paren)
	return c2
end

function grid:put_paren(exp, parent)
	if exp.priority() < parent.priority() then
		return self:enclose_paren()
	else
		return self
	end
end

function grid:join_super(superscript)
	local spacer = grid:new(self.w, superscript.h)


	local upper = spacer:join_hori(superscript, true)
	local result = upper:join_vert(self, true)
	result.my = self.my + superscript.h
	return result
end

function grid:combine_sub(other)
	local spacer = grid:new(self.w, other.h)




	local lower = spacer:join_hori(other)
	local result = self:join_vert(lower, true)
	result.my = self.my
	return result
end

function grid:join_sub_sup(sub, sup)
	local upper_spacer = grid:new(self.w, sup.h)
	local middle_spacer = grid:new(math.max(sub.w, sup.w), self.h)

	local right = sup:join_vert(middle_spacer, true)
	right = right:join_vert(sub, true)

	local left = upper_spacer:join_vert(self, true)
	local res = left:join_hori(right, true)
	res.my = self.my + sup.h
	return res
end

function grid:enclose_bracket()
	local left_content = {}
	if self.h == 1 then
		left_content = { style.left_single_bra }
	elseif self.h == 2 then
		left_content = { ' ', style.left_single_bra }
	else
		for y=1,self.h do
			if y == 1 then table.insert(left_content, style.left_top_bra)
			elseif y == self.h then table.insert(left_content, style.left_bottom_bra)
			elseif y == math.ceil(self.h/2) then table.insert(left_content, style.left_middle_bra)
	    else
	      table.insert(left_content, style.left_other_bra)
			end
		end
	end

	local left_bra = grid:new(1, self.h, left_content, "bra")
	left_bra.my = self.my

	local right_content = {}
	if self.h == 1 then
		right_content = { style.right_single_bra }
	elseif self.h == 2 then
		right_content = { ' ', style.right_single_bra }
	else
		for y=1,self.h do
			if y == 1 then table.insert(right_content, style.right_top_bra)
			elseif y == self.h then table.insert(right_content, style.right_bottom_bra)
			elseif y == math.ceil(self.h/2) then table.insert(right_content, style.right_middle_bra)
	    else
	      table.insert(right_content, style.right_other_bra)
			end
		end
	end

	local right_bra = grid:new(1, self.h, right_content, "bra")
	right_bra.my = self.my


	local c1 = left_bra:join_hori(self)
	local c2 = c1:join_hori(right_bra)
	return c2
end



local sub_letters = { 
	["+"] = "₊", ["-"] = "₋", ["="] = "₌", ["("] = "₍", [")"] = "₎",
	["a"] = "ₐ", ["e"] = "ₑ", ["o"] = "ₒ", ["x"] = "ₓ", ["ə"] = "ₔ", ["h"] = "ₕ", ["k"] = "ₖ", ["l"] = "ₗ", ["m"] = "ₘ", ["n"] = "ₙ", ["p"] = "ₚ", ["s"] = "ₛ", ["t"] = "ₜ", ["i"] = "ᵢ", ["j"] = "ⱼ", ["r"] = "ᵣ", ["u"] = "ᵤ", ["v"] = "ᵥ",
	["0"] = "₀", ["1"] = "₁", ["2"] = "₂", ["3"] = "₃", ["4"] = "₄", ["5"] = "₅", ["6"] = "₆", ["7"] = "₇", ["8"] = "₈", ["9"] = "₉",
}

local frac_set = {
	[0] = { [3] = "↉" },
	[1] = { [2] = "½", [3] = "⅓", [4] = "¼", [5] = "⅕", [6] = "⅙", [7] = "⅐", [8] = "⅛", [9] = "⅑", [10] = "⅒" },
	[2] = { [3] = "⅔", [4] = "¾", [5] = "⅖" },
	[3] = { [5] = "⅗", [8] = "⅜" },
	[4] = { [5] = "⅘" },
	[5] = { [6] = "⅚", [8] = "⅝" },
	[7] = { [8] = "⅞" },
}

local sup_letters = { 
	["+"] = "⁺", ["-"] = "⁻", ["="] = "⁼", ["("] = "⁽", [")"] = "⁾",
	["n"] = "ⁿ",
	["0"] = "⁰", ["1"] = "¹", ["2"] = "²", ["3"] = "³", ["4"] = "⁴", ["5"] = "⁵", ["6"] = "⁶", ["7"] = "⁷", ["8"] = "⁸", ["9"] = "⁹",
	["i"] = "ⁱ", ["j"] = "ʲ", ["w"] = "ʷ",
  ["T"] = "ᵀ", ["A"] = "ᴬ", ["B"] = "ᴮ", ["D"] = "ᴰ", ["E"] = "ᴱ", ["G"] = "ᴳ", ["H"] = "ᴴ", ["I"] = "ᴵ", ["J"] = "ᴶ", ["K"] = "ᴷ", ["L"] = "ᴸ", ["M"] = "ᴹ", ["N"] = "ᴺ", ["O"] = "ᴼ", ["P"] = "ᴾ", ["R"] = "ᴿ", ["U"] = "ᵁ", ["V"] = "ⱽ", ["W"] = "ᵂ",
  ["∘"] = "°",
}

local mathbb = {
  ["0"] = "𝟘",
  ["1"] = "𝟙",
  ["2"] = "𝟚",
  ["3"] = "𝟛",
  ["4"] = "𝟜",
  ["5"] = "𝟝",
  ["6"] = "𝟞",
  ["7"] = "𝟟",
  ["8"] = "𝟠",
  ["9"] = "𝟡",

  ["A"] = "𝔸",
  ["B"] = "𝔹",
  ["C"] = "ℂ",
  ["D"] = "𝔻",
  ["E"] = "𝔼",
  ["F"] = "𝔽",
  ["G"] = "𝔾",
  ["H"] = "ℍ",
  ["I"] = "𝕀",
  ["J"] = "𝕁",
  ["K"] = "𝕂",
  ["L"] = "𝕃",
  ["M"] = "𝕄",
  ["N"] = "ℕ",
  ["O"] = "𝕆",
  ["P"] = "ℙ",
  ["Q"] = "ℚ",
  ["R"] = "ℝ",
  ["S"] = "𝕊",
  ["T"] = "𝕋",
  ["U"] = "𝕌",
  ["V"] = "𝕍",
  ["W"] = "𝕎",
  ["X"] = "𝕏",
  ["Y"] = "𝕐",
  ["Z"] = "ℤ",
}

local mathcal = {
  ["A"] = "𝒜",
  ["B"] = "ℬ",
  ["C"] = "𝒞",
  ["D"] = "𝒟",
  ["E"] = "ℰ",
  ["F"] = "ℱ",
  ["G"] = "𝒢",
  ["H"] = "ℋ",
  ["I"] = "ℐ",
  ["J"] = "𝒥",
  ["K"] = "𝒦",
  ["L"] = "ℒ",
  ["M"] = "ℳ",
  ["N"] = "𝒩",
  ["O"] = "𝒪",
  ["P"] = "𝒫",
  ["Q"] = "𝒬",
  ["R"] = "ℛ",
  ["S"] = "𝒮",
  ["T"] = "𝒯",
  ["U"] = "𝒰",
  ["V"] = "𝒱",
  ["W"] = "𝒲",
  ["X"] = "𝒳",
  ["Y"] = "𝒴",
  ["Z"] = "𝒵",
}

local plain_functions = {
	["min"] = true,
	["lim"] = true,
	["exp"] = true,
	["log"] = true,
}

function combine_brackets(res)
  local left_content, right_content = {}, {}
  if res.h > 1 then
    for y=1,res.h do
      if y == 1 then
        table.insert(left_content, style.matrix_upper_left)
        table.insert(right_content, style.matrix_upper_right)
      elseif y == res.h then
        table.insert(left_content, style.matrix_lower_left)
        table.insert(right_content, style.matrix_lower_right)
      else
        table.insert(left_content, style.matrix_vert_left)
        table.insert(right_content, style.matrix_vert_right)
      end
    end
  else
    left_content = { style.matrix_single_left }
    right_content = { style.matrix_single_right }
  end

  local leftbracket = grid:new(1, res.h, left_content)
  local rightbracket = grid:new(1, res.h, right_content)

  res = leftbracket:join_hori(res, true)
  res = res:join_hori(rightbracket, true)
  return res
end

function stack_subsup(explist, i, g)
  i = i + 1
  while i <= #explist do
    local exp = explist[i]
    if exp.kind == "subexp" then
      i = i + 1
    	local my = g.my
    	local subgrid = to_ascii({explist[i]}, 1)
    	g = g:join_vert(subgrid)
    	g.my = my
      i = i + 1

    elseif exp.kind == "supexp" then
      i = i + 1
    	local my = g.my
    	local supgrid = to_ascii({explist[i]}, 1)
    	g = supgrid:join_vert(g)
    	g.my = my + supgrid.h
      i = i + 1

    else 
      break
    end

  end
  i = i - 1
  return g, i
end

function grid_of_exps(explist)
  local cellsgrid = {}
  local maxheight = 0
  local i = 1
  local rowgrid = {}
  while i <= #explist do
  	local cell_list = {
  		kind = "explist",
  		exps = {},
  	}

  	while i <= #explist do
  		if explist[i].kind == "symexp" and explist[i].sym == "&" then
  			local cellgrid = to_ascii({cell_list}, 1)
  			table.insert(rowgrid, cellgrid)
  			maxheight = math.max(maxheight, cellgrid.h)
  			i = i+1
  			break

  		elseif explist[i].kind == "funexp" and explist[i].sym == "\\" then
  			local cellgrid = to_ascii({cell_list}, 1)
  			table.insert(rowgrid, cellgrid)
  			maxheight = math.max(maxheight, cellgrid.h)

  			table.insert(cellsgrid, rowgrid)
  			rowgrid = {}
  			i = i+1
  			break

  		else
  			table.insert(cell_list.exps, explist[i])
  			i = i+1
  		end

  		if i > #explist then
  			local cellgrid = to_ascii({cell_list}, 1)
  			table.insert(rowgrid, cellgrid)
  			maxheight = math.max(maxheight, cellgrid.h)

  			table.insert(cellsgrid, rowgrid)
  		end

  	end

  end

  return cellsgrid, maxheight
end

function combine_matrix_grid(cellsgrid, maxheight)
  local res
  local row_heights = {}
  local baselines = {}

  for i=1,#cellsgrid do
    local height_below = 0
    local height_above = 0
    local baseline = 0
    for j=1,#cellsgrid[i] do
      local cell = cellsgrid[i][j]
      height_below = math.max(cell.my, height_below)
      height_above = math.max(cell.h - cell.my - 1, height_above)
      baseline = math.max(baseline, cell.my)
    end
    row_heights[i] = height_below + height_above + 1
    baselines[i] = baseline

  end

  for i=1,#cellsgrid[1] do
    local col 
    for j=1,#cellsgrid do
      local cell = cellsgrid[j][i]
      local sup = baselines[j] - cell.my
      local sdown = row_heights[j] - cell.h - sup
      local up, down
      if sup > 0 then up = grid:new(cell.w, sup) end
      if sdown > 0 then down = grid:new(cell.w, sdown) end

      if up then cell = up:join_vert(cell) end
      if down then cell = cell:join_vert(down) end

      local colspacer = grid:new(1, cell.h)
      colspacer.my = cell.my

      if i < #cellsgrid[1] then
      	cell = cell:join_hori(colspacer)
      end

      if not col then col = cell
      else col = col:join_vert(cell, true) end

    end
    if not res then res = col
    else res = res:join_hori(col, true) end

  end
  return res
end

function unpack_explist(exp)
  while exp.kind == "explist" do
    assert(#exp.exps == 1, "explist must be length 1")
    exp = exp.exps[1]
  end
  return exp
end

function put_subsup_aside(g, sub, sup)
  if sub and sup then 
  	local subscript = ""
    -- sub and sup are exchanged to
    -- make the most compact expression
  	local subexps = sup.exps
    local sub_t
  	if #subexps == 1 and subexps[1].kind == "numexp" or (subexps[1].kind == "symexp" and string.match(subexps[1].sym, "^%d+$")) then
  	  sub_t = "num"
  	elseif subexps[1].kind == "symexp" and string.match(subexps[1].sym, "^%a+$") then
  	  sub_t = "var"
  	else
  	  sub_t = "sym"
  	end

  	for _, exp in ipairs(subexps) do
  		if exp.kind == "numexp" and math.floor(exp.num) == exp.num then
  			local num = exp.num
  			if num == 0 then
  				subscript = subscript .. sub_letters["0"]
  			else
  				if num < 0 then
  					subscript = "₋" .. subscript
  					num = math.abs(num)
  				end
  				local num_subscript = ""
  				while num ~= 0 do
  					num_subscript = sub_letters[tostring(num%10)] .. num_subscript 
  					num = math.floor(num / 10)
  				end
  				subscript = subscript .. num_subscript 
  			end

  		elseif exp.kind == "symexp" then
  			if sub_letters[exp.sym] and not exp.sub and not exp.sup then
  				subscript = subscript .. sub_letters[exp.sym]
  			else
  				subscript = nil
  				break
  			end

  		else
  			subscript = nil
  			break
  		end
  	end


  	local superscript = ""
  	local supexps = sub.exps
    local sup_t
  	if #supexps == 1 and supexps[1].kind == "numexp" or (supexps[1].kind == "symexp" and string.match(supexps[1].sym, "^%d+$")) then
  	  sup_t = "num"
  	elseif supexps[1].kind == "symexp" and string.match(supexps[1].sym, "^%a+$") then
  	  sup_t = "var"
  	else
  	  sup_t = "sym"
  	end

  	for _, exp in ipairs(supexps) do
  		if exp.kind == "numexp" and math.floor(exp.num) == exp.num then
  			local num = exp.num
  			if num == 0 then
  				superscript = superscript .. sub_letters["0"]
  			else
  				if num < 0 then
  					superscript = "₋" .. superscript
  					num = math.abs(num)
  				end
  				local num_superscript = ""
  				while num ~= 0 do
  					num_superscript = sup_letters[tostring(num%10)] .. num_superscript 
  					num = math.floor(num / 10)
  				end
  				superscript = superscript .. num_superscript 
  			end

  		elseif exp.kind == "symexp" then
  			if sup_letters[exp.sym] and not exp.sub and not exp.sup then
  				superscript = superscript .. sup_letters[exp.sym]
  			else
  				superscript = nil
  				break
  			end

  		else
  			superscript = nil
  			break
  		end
  	end


  	if subscript and superscript then
  		local sup_g = grid:new(utf8len(subscript), 1, { subscript }, sub_t)
  		local sub_g = grid:new(utf8len(superscript), 1, { superscript }, sup_t)
  		g = g:join_sub_sup(sub_g, sup_g)
  	else
  		local subgrid = to_ascii({sub}, 1)
  		local supgrid = to_ascii({sup}, 1)
  		g = g:join_sub_sup(subgrid, supgrid)
  	end

  end

  return g
end

function put_if_only_sub(g, sub, sup)
  if sub and not sup then 
  	local subscript = ""
  	local subexps = sub.exps
    local sub_t
  	if #subexps == 1 and subexps[1].kind == "numexp" or (subexps[1].kind == "symexp" and string.match(subexps[1].sym, "^%d+$")) then
  	  sub_t = "num"
  	elseif subexps[1].kind == "symexp" and string.match(subexps[1].sym, "^%a+$") then
  	  sub_t = "var"
  	else
  	  sub_t = "sym"
  	end

  	for _, exp in ipairs(subexps) do
  		if exp.kind == "numexp" and math.floor(exp.num) == exp.num then
  			local num = exp.num
  			if num == 0 then
  				subscript = subscript .. sub_letters["0"]
  			else
  				if num < 0 then
  					subscript = "₋" .. subscript
  					num = math.abs(num)
  				end
  				local num_subscript = ""
  				while num ~= 0 do
  					num_subscript = sub_letters[tostring(num%10)] .. num_subscript 
  					num = math.floor(num / 10)
  				end
  				subscript = subscript .. num_subscript 
  			end

  		elseif exp.kind == "symexp" then
  			if sub_letters[exp.sym] and not exp.sub and not exp.sup then
  				subscript = subscript .. sub_letters[exp.sym]
  			else
  				subscript = nil
  				break
  			end

  		else
  			subscript = nil
  			break
  		end
  	end

  	if subscript and string.len(subscript) > 0 then
  		local sub_g = grid:new(utf8len(subscript), 1, { subscript }, sub_t)
  		g = g:join_hori(sub_g)

  	else
  		local subgrid
  		local frac_exps = sub.exps
  		local frac_exp
  		if #frac_exps == 1  then
  			local exp = frac_exps[1]
			if exp.kind == "funexp" and (exp.sym == "frac" or exp.sym == "dfrac" or exp.sym == "tfrac") then
  				assert(#exp.args == 2, "frac must have 2 arguments")
  				local numerator = exp.args[1].exps
  				local denominator = exp.args[2].exps
  				if #numerator == 1 and numerator[1].kind == "numexp" and 
  					#denominator == 1 and denominator[1].kind == "numexp" then
  					local A = numerator[1].num
  					local B = denominator[1].num
  					if frac_set[A] and frac_set[A][B] then
  						frac_exp = grid:new(1, 1, { frac_set[A][B] })
  					else
  						local num_str = ""
  						local den_str = ""
  						if math.floor(A) == A then
  							local s = tostring(A)
  							for i=1,string.len(s) do
  								num_str = num_str .. sup_letters[string.sub(s, i, i)]
  							end
  						end

  						if math.floor(B) == B then
  							local s = tostring(B)
  							for i=1,string.len(s) do
  								den_str = den_str .. sub_letters[string.sub(s, i, i)]
  							end
  						end

  						if string.len(num_str) > 0 and string.len(den_str) > 0 then
  							local frac_str = num_str .. "⁄" .. den_str
  							frac_exp = grid:new(utf8len(frac_str), 1, { frac_str })
  						end
  					end
  				end

  			end
  		end

  		if not frac_exp then
  			subgrid = to_ascii({sub}, 1)
  		else
  			subgrid = frac_exp
  		end
  		g = g:combine_sub(subgrid)

  	end
  end

  return g
end


function put_if_only_sup(g, sub, sup)
  if sup and not sub then 
  	local superscript = ""
  	local supexps = sup.exps
    local sup_t
  	if #supexps == 1 and supexps[1].kind == "numexp" or (supexps[1].kind == "symexp" and string.match(supexps[1].sym, "^%d+$")) then
  	  sup_t = "num"
  	elseif supexps[1].kind == "symexp" and string.match(supexps[1].sym, "^%a+$") then
  	  sup_t = "var"
  	else
  	  sup_t = "sym"
  	end

  	for _, exp in ipairs(supexps) do
  		if exp.kind == "numexp" and math.floor(exp.num) == exp.num then
  			local num = exp.num
  			if num == 0 then
  				superscript = superscript .. sub_letters["0"]
  			else
  				if num < 0 then
  					superscript = "₋" .. superscript
  					num = math.abs(num)
  				end
  				local num_superscript = ""
  				while num ~= 0 do
  					num_superscript = sup_letters[tostring(num%10)] .. num_superscript 
  					num = math.floor(num / 10)
  				end
  				superscript = superscript .. num_superscript 
  			end

  		elseif exp.kind == "symexp" then
  			if sup_letters[exp.sym] and not exp.sub and not exp.sup then
  				superscript = superscript .. sup_letters[exp.sym]
  			else
  				superscript = nil
  				break
  			end

  		elseif exp.kind == "funexp" then
  			local sym_char = special_syms[exp.sym] or special_nums[exp.sym] or greek_etc[exp.sym]
  			if sym_char and sup_letters[sym_char] and not exp.sub and not exp.sup then
  				superscript = superscript .. sup_letters[sym_char]
  			else
  				superscript = nil
  				break
  			end

  		else
  			superscript = nil
  			break
  		end
  	end

  	if superscript and string.len(superscript) > 0 then
  		local sup_g = grid:new(utf8len(superscript), 1, { superscript }, sup_t)
  		g = g:join_hori(sup_g, true)

  	else
  		local supgrid = to_ascii({sup}, 1)
  		local frac_exps = sup.exps
  		local frac_exp
  		if #frac_exps == 1  then
  			local exp = frac_exps[1]
			if exp.kind == "funexp" and (exp.sym == "frac" or exp.sym == "dfrac" or exp.sym == "tfrac") then
  				assert(#exp.args == 2, "frac must have 2 arguments")
  				local numerator = exp.args[1].exps
  				local denominator = exp.args[2].exps
  				if #numerator == 1 and numerator[1].kind == "numexp" and 
  					#denominator == 1 and denominator[1].kind == "numexp" then
  					local A = numerator[1].num
  					local B = denominator[1].num
  					if frac_set[A] and frac_set[A][B] then
  						frac_exp = grid:new(1, 1, { frac_set[A][B] })
  					else
  						local num_str = ""
  						local den_str = ""
  						if math.floor(A) == A then
  							local s = tostring(A)
  							for i=1,string.len(s) do
  								num_str = num_str .. sup_letters[string.sub(s, i, i)]
  							end
  						end

  						if math.floor(B) == B then
  							local s = tostring(B)
  							for i=1,string.len(s) do
  								den_str = den_str .. sub_letters[string.sub(s, i, i)]
  							end
  						end

  						if string.len(num_str) > 0 and string.len(den_str) > 0 then
  							local frac_str = num_str .. "⁄" .. den_str
  							frac_exp = grid:new(utf8len(frac_str), 1, { frac_str })
  						end
  					end
  				end

  			end
  		end

  		if not frac_exp then
  			supgrid = to_ascii({sup}, 1)
  		else
  			supgrid = frac_exp
  		end
  		g = g:join_super(supgrid)
  	end
  end

  return g
end

function to_ascii(explist, exp_i)
  local gs = {}
  while exp_i <= #explist do
    local exp = explist[exp_i]
    local g
    if exp.kind == "numexp" then
    	local numstr = exp.str or tostring(exp.num)
    	g = grid:new(string.len(numstr), 1, { numstr }, "num")

    elseif exp.kind == "symexp" then
    	local sym =  exp.sym
    	if not exp.is_text then
    		-- Check if first character is a word character (letter/digit in any script) using vim.fn.charclass
    		-- charclass: 0=whitespace, 1=punctuation, 2=word char
    		local first_char = vim.fn.strcharpart(sym, 0, 1)
    		local is_word_char = vim.fn.charclass(first_char) == 2
    		local is_space_only = string.match(sym, "^%s+$")
    		local is_excluded = sym == "/" or sym == special_syms["partial"] or sym == "[" or sym == "]" or sym == "'" or sym == "|" or sym == "." or sym == "," or sym == special_syms["Vert"] or sym == "$" or sym == "#"
    		local is_leading_minus = (exp_i == 1 and sym == "-")
    		if not is_word_char and not is_space_only and not is_excluded and not is_leading_minus then
    			sym = " " .. sym .. " "
    		end
    	end

    	g = grid:new(utf8len(sym), 1, { sym }, "sym")


    elseif exp.kind == "explist" then
      g = to_ascii(exp.exps, 1)

    elseif exp.kind == "funexp" then
    	local name = exp.sym
	if name == "frac" or name == "dfrac" or name == "tfrac" then
    		local leftgrid = to_ascii({explist[exp_i+1]}, 1)
    		local rightgrid = to_ascii({explist[exp_i+2]}, 1)
    		exp_i = exp_i + 2

    		local bar = ""
    		local w = math.max(leftgrid.w, rightgrid.w)
    		for x=1,w do
    			bar = bar .. style.div_middle_bar
    		end


    		local opgrid = grid:new(w, 1, { bar })

    		local c1 = leftgrid:join_vert(opgrid)
    		local c2 = c1:join_vert(rightgrid)
    		c2.my = leftgrid.h

    		g = c2


    	elseif special_syms[name] or special_nums[name] or greek_etc[name] then
    		local sym = special_syms[name] or special_nums[name] or greek_etc[name]
    	  local t
    	  if special_syms[name] then
    	    t = "sym"
    	  	local is_space_only = string.match(sym, "^%s+$")
    	  	local is_excluded = sym == "/" or sym == special_syms["partial"] or sym == "[" or sym == "]" or sym == "'" or sym == "|" or sym == "." or sym == "," or sym == special_syms["Vert"]
    	  	local is_leading_minus = (exp_i == 1 and sym == "-")
    	  	if not is_space_only and not is_excluded and not is_leading_minus then
    	  		sym = " " .. sym .. " "
    	  	end

    	  elseif special_nums[name] then
    	    t = "num"
    	  elseif greek_etc[name] then
    	    t = "var"
    	  end

    		g = grid:new(utf8len(sym), 1, { sym }, t)


    	elseif name == "sqrt" then
    		local toroot = to_ascii({explist[exp_i+1]}, 1)
    	  exp_i = exp_i + 1

    		local left_content = {}
    		for y=1,toroot.h do 
    			if y < toroot.h then
    				table.insert(left_content, " " .. style.root_vert_bar)
    			else
    				table.insert(left_content, style.root_bottom .. style.root_vert_bar)
    			end
    		end

    		local left_root = grid:new(2, toroot.h, left_content, "sym")
    		left_root.my = toroot.my

    		local up_str = " " .. style.root_upper_left
    		for x=1,toroot.w do
    			up_str = up_str .. style.root_upper
    		end
    		up_str = up_str .. style.root_upper_right

    		local top_root = grid:new(toroot.w+2, 1, { up_str }, "sym")


    		local res = left_root:join_hori(toroot)
    		res = top_root:join_vert(res)
    		res.my = top_root.h + toroot.my
    	  g = res

    	elseif name == "int" then
    		g = grid:new(1, 1, { "∫" }, "sym")
    	  g, exp_i = stack_subsup(explist, exp_i, g)
    		local col_spacer = grid:new(1, 1, { " " })
    		if g then
    		  g = g:join_hori(col_spacer)
    		end


    	elseif name == "iint" then
    		g = grid:new(1, 1, { "∬" }, "sym")

    	  g, exp_i = stack_subsup(explist, exp_i, g)
    		local col_spacer = grid:new(1, 1, { " " })
    		if g then
    		  g = g:join_hori(col_spacer)
    		end


    	elseif name == "iiint" then
    		g = grid:new(1, 1, { "∭" }, "sym")

    	  g, exp_i = stack_subsup(explist, exp_i, g)
    		local col_spacer = grid:new(1, 1, { " " })
    		if g then
    		  g = g:join_hori(col_spacer)
    		end


    	elseif name == "oint" then
    		g = grid:new(1, 1, { "∮" }, "sym")

    	  g, exp_i = stack_subsup(explist, exp_i, g)
    		local col_spacer = grid:new(1, 1, { " " })
    		if g then
    		  g = g:join_hori(col_spacer)
    		end


    	elseif name == "oiint" then
    		g = grid:new(1, 1, { "∯" }, "sym")

    	  g, exp_i = stack_subsup(explist, exp_i, g)
    		local col_spacer = grid:new(1, 1, { " " })
    		if g then
    		  g = g:join_hori(col_spacer)
    		end


    	elseif name == "oiiint" then
    		g = grid:new(1, 1, { "∰" }, "sym")

    	  g, exp_i = stack_subsup(explist, exp_i, g)
    		local col_spacer = grid:new(1, 1, { " " })
    		if g then
    		  g = g:join_hori(col_spacer)
    		end


    	elseif name == "sum" then
    		g = grid:new(1, 1, { "∑" }, "sym")

    	  g, exp_i = stack_subsup(explist, exp_i, g)
    		local col_spacer = grid:new(1, 1, { " " })
    		if g then
    		  g = g:join_hori(col_spacer)
    		end


    	elseif name == "prod" then
    		g = grid:new(1, 1, { "∏" }, "sym")

    	  g, exp_i = stack_subsup(explist, exp_i, g)
    		local col_spacer = grid:new(1, 1, { " " })
    		if g then
    		  g = g:join_hori(col_spacer)
    		end


    	elseif name == "lim" then
    	  g = grid:new(3, 1, { "lim" }, "op")

    	  g, exp_i = stack_subsup(explist, exp_i, g)
    		local col_spacer = grid:new(1, 1, { " " })
    		if g then
    		  g = g:join_hori(col_spacer)
    		end

    	elseif name == "max" then
    	  g = grid:new(3, 1, { "max" }, "op")

    	  g, exp_i = stack_subsup(explist, exp_i, g)
    		local col_spacer = grid:new(1, 1, { " " })
    		if g then
    		  g = g:join_hori(col_spacer)
    		end

    	elseif name == "min" then
    	  g = grid:new(3, 1, { "min" }, "op")

    	  g, exp_i = stack_subsup(explist, exp_i, g)
    		local col_spacer = grid:new(1, 1, { " " })
    		if g then
    		  g = g:join_hori(col_spacer)
    		end


    	elseif name == "bar" then
    	  local ingrid = to_ascii({explist[exp_i+1]}, 1)
    	  exp_i = exp_i + 1
    	  local bars = {}

    	  local h = ingrid.h

    	  for y=1,h do
    	    table.insert(bars, style.root_vert_bar)
    	  end

    	  local left_bar = grid:new(1, h, bars)
    	  local right_bar = grid:new(1, h, bars)

    	  local  c1 = left_bar:join_hori(ingrid, true)
    	  local  c2 = c1:join_hori(right_bar, true)
    		g = c2


    	elseif name == "boxed" then
    	  local ingrid = to_ascii({explist[exp_i+1]}, 1)
    	  exp_i = exp_i + 1

    	  local left_bars = {}
    	  local right_bars = {}

    	  for y=1, ingrid.h do
    	    table.insert(left_bars, style.box_vert)
    	    table.insert(right_bars, style.box_vert)
    	  end

    	  local left_border = grid:new(1, ingrid.h, left_bars)
    	  local right_border = grid:new(1, ingrid.h, right_bars)

    	  local center = left_border:join_hori(ingrid, true)
    	  center = center:join_hori(right_border, true)

          local w = center.w
          local top_str = style.box_upper_left
          local bot_str = style.box_lower_left
          
          for x=1, w-2 do
            top_str = top_str .. style.box_upper
            bot_str = bot_str .. style.box_lower
          end
          top_str = top_str .. style.box_upper_right
          bot_str = bot_str .. style.box_lower_right
          
          local top_border = grid:new(w, 1, { top_str })
          local bot_border = grid:new(w, 1, { bot_str })
          
          local res = top_border:join_vert(center)
          res = res:join_vert(bot_border)
          
          res.my = top_border.h + ingrid.my
          g = res


    	elseif name == "dddot" then
    	  local belowgrid = to_ascii({explist[exp_i+1]}, 1)
    	  exp_i = exp_i + 1
    	  local dot = grid:new(1, 1, { "…" })
    	  g = dot:join_vert(belowgrid)
    	  g.my = belowgrid.my + 1
    	elseif name == "ddot" then
    	  local belowgrid = to_ascii({explist[exp_i+1]}, 1)
    	  exp_i = exp_i + 1
    	  local dot = grid:new(1, 1, { "‥" })
    	  g = dot:join_vert(belowgrid)
    	  g.my = belowgrid.my + 1
    	elseif name == "dot" then
    	  local belowgrid = to_ascii({explist[exp_i+1]}, 1)
    	  exp_i = exp_i + 1
    	  local dot = grid:new(1, 1, { "." })
    	  g = dot:join_vert(belowgrid)
    	  g.my = belowgrid.my + 1
    	elseif name == "hat" then
    	  local belowgrid = to_ascii({explist[exp_i+1]}, 1)
    	  exp_i = exp_i + 1
    	  local hat = grid:new(1, 1, { "^" })
    	  g = hat:join_vert(belowgrid)
    	  g.my = belowgrid.my + 1
    	elseif name == "mathbb" then
    	  local sym = unpack_explist(explist[exp_i+1])
    	  exp_i = exp_i + 1
    		assert(sym.kind == "symexp" or sym.kind == "numexp", "mathbb must have 1 arguments")

    	  local sym = tostring(sym.sym or sym.num)
    		local cell = ""
    		for i=1,#sym do
    			assert(mathbb[sym:sub(i,i)], "mathbb " .. sym:sub(i,i) .. " symbol not found")
    			cell = cell .. mathbb[sym:sub(i,i)]
    		end
    		g = grid:new(#sym, 1, {cell})
    	elseif name == "mathbf" then
    	  local sym = unpack_explist(explist[exp_i+1])
    		g = to_ascii({explist[exp_i+1]}, 1)
    	  exp_i = exp_i + 1
    	elseif name == "mathcal" then
    	  local sym = unpack_explist(explist[exp_i+1])
    		-- assert(sym.kind == "symexp", "mathcal must have 1 arguments")
    		if sym.kind == "symexp" then
    			sym = sym.sym

    			local cell = ""
    			for i=1,#sym do
    				assert(mathcal[sym:sub(i,i)], "mathcal " .. sym:sub(i,i) .. " symbol not found")
    				cell = cell .. mathcal[sym:sub(i,i)]
    			end
    			g = grid:new(#sym, 1, {cell})
    		elseif sym.kind == "funexp" then
    			g = to_ascii({explist[exp_i+1]}, 1)
    		else
    			assert(false, "mathcal")
    		end

    		exp_i = exp_i + 1
    	elseif name == "boldsymbol" then
    	  local sym = unpack_explist(explist[exp_i+1])
    		g = to_ascii({explist[exp_i+1]}, 1)
    		exp_i = exp_i + 1

    	elseif plain_functions[name] then
    		g = grid:new(#name, 1, {name})
    	elseif name == "overline" then
    	  local belowgrid = to_ascii({explist[exp_i+1]}, 1)
    	  exp_i = exp_i + 1

    	  local bar = ""
    	  local w = belowgrid.w
    	  for x=1,w do
    	  	bar = bar .. style.div_low_bar
    	  end
    	  local overline = grid:new(w, 1, { bar })
    	  g = overline:join_vert(belowgrid)
    	  g.my = belowgrid.my + 1

    	elseif name == "vec" then
    	  local belowgrid = to_ascii({explist[exp_i+1]}, 1)
    	  exp_i = exp_i + 1
    	  local txt = ""
    	  local w = belowgrid.w
    	  for x=1,w-1 do
    	  	txt = txt .. style.div_middle_bar
    	  end
    	  txt = txt .. style.vec_arrow

    	  local arrow = grid:new(w, 1, {txt})
    	  g = arrow:join_vert(belowgrid)
    	  g.my = belowgrid.my + 1

      elseif name == "{" then
        local inside_bra = {}
        while exp_i+1 <= #explist do
          if explist[exp_i+1].kind == "funexp" and explist[exp_i+1].sym == "}" then
            break
          end
          table.insert(inside_bra, explist[exp_i+1])
          exp_i = exp_i + 1
        end

        assert(explist[exp_i+1] and explist[exp_i+1].kind == "funexp" and explist[exp_i+1].sym == "}", "No matching closing bracket")

      	g = to_ascii(inside_bra, 1):enclose_bracket()
      	exp_i = exp_i + 1

    	else
    		g = grid:new(utf8len("\\" .. name), 1, { "\\" .. name })
    	end


    elseif exp.kind == "parexp" then
    	g = to_ascii({exp.exp}, 1):enclose_paren()

    elseif exp.kind == "blockexp" then
      local sym = unpack_explist(exp.first)
      exp_i = exp_i + 1
      local name = sym.sym
      if name == "matrix" then
        local cellsgrid, maxheight = grid_of_exps(exp.content.exps)
        local res = combine_matrix_grid(cellsgrid, maxheight)

        res.my = math.floor(res.h/2)
        g = res

      elseif name == "align" or name == "aligned" then
        local cellsgrid, maxheight = grid_of_exps(exp.content.exps)
        local res = combine_matrix_grid(cellsgrid, maxheight)
        res.my = math.floor(res.h/2)
        g = res
      elseif name == "pmatrix" then
        local cellsgrid, maxheight = grid_of_exps(exp.content.exps)
        local res = combine_matrix_grid(cellsgrid, maxheight)
        res.my = math.floor(res.h/2)
        g = res:enclose_paren()

      elseif name == "bmatrix" then
        local cellsgrid, maxheight = grid_of_exps(exp.content.exps)
        local res = combine_matrix_grid(cellsgrid, maxheight)
        res = combine_brackets(res)

        res.my = math.floor(res.h/2)
        g = res

      else
        error("Unknown block expression " .. name)
      end


    elseif exp.kind == "supexp" or exp.kind == "subexp" then
      assert(#gs >= 1, "No expression preceding '^'")
      local sub, sup
      while exp_i <= #explist do
        if explist[exp_i].kind == "subexp" then
          sub = explist[exp_i+1]
          exp_i = exp_i + 2
        elseif explist[exp_i].kind == "supexp" then
          sup = explist[exp_i+1]
          exp_i = exp_i + 2
        else
          break
        end
      end
      exp_i = exp_i - 1

      if sup and sup.kind ~= "explist" then
    		if sup.kind == "funexp" and explist[exp_i+1] and explist[exp_i+1].kind == "explist" then
    			sup = {
    				kind = "explist",
    				exps = { sup, explist[exp_i+1] },
    			}
    			exp_i = exp_i + 1

    		else
    			sup = {
    				kind = "explist",
    				exps = { sup },
    			}
    		end
      end

      if sub and sub.kind ~= "explist" then
    		if sub.kind == "funexp" and explist[exp_i+1] and explist[exp_i+1].kind == "explist" then
    			sub = {
    				kind = "explist",
    				exps = { sub, explist[exp_i+1] },
    			}
    			exp_i = exp_i + 1

    		else
    			sub = {
    				kind = "explist",
    				exps = { sub },
    			}
    		end
      end

      local last_g = gs[#gs]
      last_g = put_subsup_aside(last_g, sub, sup)
      last_g = put_if_only_sub(last_g, sub, sup)
      last_g = put_if_only_sup(last_g, sub, sup)
      gs[#gs] = last_g

    elseif exp.kind == "chosexp" then
      -- same thing as frac without the bar
      local leftgrid = to_ascii({exp.left}, 1)
      local rightgrid = to_ascii({exp.right}, 1)
      
    	local bar = ""
    	local w = math.max(leftgrid.w, rightgrid.w)
    	for x=1,w do
    		bar = bar .. " "
    	end

    	local opgrid = grid:new(w, 1, { bar })

    	local c1 = leftgrid:join_vert(opgrid)
    	local c2 = c1:join_vert(rightgrid)
    	c2.my = leftgrid.h


      g = c2:enclose_paren()

    elseif exp.kind == "braexp" then
    	g = to_ascii({exp.exp}, 1)
      g = combine_brackets(g)
    else
      assert(false, "Unrecognized token")
    end

    table.insert(gs, g)
    exp_i = exp_i + 1
  end
  local concat_g = grid:new()
  for _, g in ipairs(gs) do
    if g then
      concat_g = concat_g:join_hori(g)
    end
  end

	return concat_g
end

function utf8len(str)
	return vim.str_utfindex(str)
end

function utf8char(str, i)
	if i >= utf8len(str) or i < 0 then return nil end
	local s1 = vim.str_byteindex(str, i)
	local s2 = vim.str_byteindex(str, i+1)
	return string.sub(str, s1+1, s2)
end


return {
to_ascii = to_ascii,

}

