//
//  Yaku.swift
//  Mahjong Scoreboard
//
//  Created by Nathan Davis on 9/9/25.
//

import Foundation

struct Yaku: Identifiable {
    let id = UUID()
    let han: String
    let entries: [String]
}

let yakuList: [Yaku] = [
    Yaku(han: "1 Han (Closed)", entries: [
        "門前自摸 (めんぜんつも) (**Tsumo, Fully Concealed Hand**) - self draw",
        "立直 (リーチ) (**Riichi**) - no pon or chii",
        "一発 (イッパツ) (**Ippatsu**) - win within first rotation after riichi, also can't be interrupted by tile calls",
        "平和 (ピンフ) (**Pinfu**) - all sequences and must end with a two-sided wait",
        "一盃口 (イーペイコー) (**Pure Double Sequence**) - 112233 kind of double sequence"
    ]),
    Yaku(han: "1 Han", entries: [
        "海底撈月 (ハイテイラオユエ) (**Under the Sea**) - Tsumo with the last drawn tile from the wall",
        "河底撈魚 (ホウテイラオユイ) (**Under the River**) - Ron with the last discarded tile",
        "嶺上開花 (リンシャンカイホウ) (**After a Kan**) - win with a tile drawn from the dead wall immediately after calling a Kan",
        "搶槓 (チャンカン) (**Robbing a Kan**) - calling Ron on a tile used to make an Added Kan (加槓). A Closed Kan (暗槓) normally cannot be robbed, except to complete Thirteen Orphans",
        "断幺九 (タンヤオ) (**All Simples**) - winning with no honor or terminal tiles (2-8 number tiles only)",
        "役牌 (やくはい) - a hand with at least one group of dragon, round wind, or seat wind tiles"
    ]),
    Yaku(han: "2 Han", entries: [
        "両立直 (ダブリー) (**Double Riichi**) - declare Riichi with your starting hand before any tiles are called",
        "全帯幺九 (チャンタ) (**Half Outside Hand**) - every sequence, triplet and pair contains at least one terminal tile or honor tiles (-1 Han if open)",
        "三色同順 (サンショクドウジュン) (**Mixed Triple Sequence**) - three sequences with the same numbers across the three suits (-1 Han if open)",
        "一気通貫 (イッキツウカン) (**Pure Straight**) - complete sequence 1–9 (-1 Han if open)",
        "対々 (トイトイ) (**All Triplets**) - all triplets (or quads), no sequences",
        "三暗刻 (サンアンコウ) (**Three Concealed Triplets**) - three sets of triplets (or quads) that were formed without calling any tiles",
        "三色同刻 (サンショクドウコウ) (**Triple Triplets**) - three triplets with the same number in each suit",
        "三槓子 (サンカンツ) (**Three Kans**) - three Kans, may be open",
        "七対子 (チートイツ) (**Seven Pairs**) - seven pairs, closed only",
        "混老頭 (ホンロウトウ) (**All Terminals and Honors**) - nothing but terminals and honors (usually scored with Seven Pairs or All Triplets)",
        "小三元 (ショウサンゲン) (**Little Three Dragons**) - two triplets of dragon tiles plus a pair of the third"
    ]),
    Yaku(han: "3 Han", entries: [
        "混一色 (ホンイーソー) (**Half Flush**) - single suit with honor tiles (-1 Han if open)",
        "純全帯么 (ジュンチャン) (**Fully Outside Hand**) - all sets contain at least one terminal tile (-1 Han if open)",
        "二盃口 (リャンペイコー) (**Twice Pure Double Sequence**) - two sets of Pure Double Sequence in two different suits (doesn't combine with Seven Pairs, closed only)"
    ]),
    Yaku(han: "6 Han", entries: [
        "清一色 (チンイーソー) (**Full Flush**) - one suit of number tiles (-1 Han if open)"
    ]),
    Yaku(han: "Mangan", entries: [
        "流し満貫 (ナガシマンガン) (**Mangan at Draw**) - all your discards were terminals/honors and no one called them (5 Han)"
    ]),
    Yaku(han: "Yakuman", entries: [
        "数え役満 (かぞえやくまん) - if your hand adds up to 13+ Han",
        "国士無双 (コクシムソウ) (**Thirteen Orphans**) - 1 & 9 of each suit, all winds, all dragons, plus one extra of any",
        "四暗刻 (スーアンコウ) (**Four Concealed Triplets**) - four closed triplets (closed only, you can only call the last tile for the pair)",
        "大三元 (ダイサンゲン) (**Big Three Dragons**) - three triplets of all three dragons",
        "小四喜 (ショウスーシー) (**Little Four Winds**) - three triplets/quads of winds plus a pair of the fourth",
        "字一色 (ツーイーソー) (**All Honors**) - nothing but honor tiles",
        "清老頭 (チンロウトウ) (**All Terminals**) - nothing but terminal tiles",
        "緑一色 (リューイーソー) (**All Green**) - only green tiles (23468 bamboo + green dragon)",
        "九連宝燈 (チューレンポートウ) (**Nine Gates**) - 1112345678999 + any one extra in the same suit (closed only)",
        "四槓子 (スーカンツ) (**Four Quads**) - four Kans, open or closed",
        "天和 (テンホー) (**Blessing of Heaven**) - dealer tsumo on the very first draw",
        "地和 (チーホー) (**Blessing of Earth**) - non-dealer tsumo on first draw before any calls"
    ]),
    Yaku(han: "Double Yakuman", entries: [
        "四暗刻単騎（スーアンコータンキ）- Four Concealed Triplets with a single wait (tsumo only)",
        "国士無双十三面待ち（コクシムソウジュウサンメンマチ）- Thirteen-sided wait Thirteen Orphans (tsumo only)",
        "純正九連宝燈 (チューレンキュウメンマチ) - Nine-sided wait Nine Gates (tsumo only)",
        "大四喜 (ダイスーシー) (**Big Four Winds**) - four triplets/quads of all four winds",
        "大七星 (ダイチーシン) - Seven Pairs of all the winds and dragons (tsumo only)",
        
    ])
]

struct YakuTileExample {
    let title: String
    let groups: [String]
    let accessibilityDescription: String
    var isGreen = false

    static func example(for entry: String) -> YakuTileExample? {
        let examples: [(prefix: String, example: YakuTileExample)] = [
            ("全帯幺九", YakuTileExample(
                title: "Example hand",
                groups: ["🀇🀈🀉", "🀟🀠🀡", "🀐🀐🀐", "🀀🀀🀀", "🀆🀆"],
                accessibilityDescription: "1, 2, 3 of characters; 7, 8, 9 of circles; three 1s of bamboo; three East winds; a pair of white dragons."
            )),
            ("対々", YakuTileExample(
                title: "Example hand",
                groups: ["🀈🀈🀈", "🀔🀔🀔", "🀠🀠🀠", "🀄︎🀄︎🀄︎", "🀀🀀"],
                accessibilityDescription: "Triplets of 2 characters, 5 bamboo, 8 circles, and red dragons; a pair of East winds."
            )),
            ("混老頭", YakuTileExample(
                title: "Example hand",
                groups: ["🀇🀇🀇", "🀡🀡🀡", "🀀🀀🀀", "🀅🀅🀅", "🀘🀘"],
                accessibilityDescription: "Triplets of 1 characters, 9 circles, East winds, and green dragons; a pair of 9 bamboo."
            )),
            ("小三元", YakuTileExample(
                title: "Example hand",
                groups: ["🀄︎🀄︎🀄︎", "🀅🀅🀅", "🀆🀆"],
                accessibilityDescription: "Red and green dragon triplets, a white dragon pair, 1, 2, 3 characters, and 4, 5, 6 bamboo."
            )),
            ("混一色", YakuTileExample(
                title: "Example hand",
                groups: ["🀇🀈🀉", "🀊🀋🀌", "🀎🀎🀎", "🀀🀀🀀", "🀆🀆"],
                accessibilityDescription: "1, 2, 3 and 4, 5, 6 characters; three 8 characters; three East winds; a white dragon pair."
            )),
            ("純全帯么", YakuTileExample(
                title: "Example hand",
                groups: ["🀇🀈🀉", "🀖🀗🀘", "🀙🀚🀛", "🀏🀏🀏", "🀡🀡"],
                accessibilityDescription: "1, 2, 3 characters; 7, 8, 9 bamboo; 1, 2, 3 circles; three 9 characters; a pair of 9 circles."
            )),
            ("二盃口", YakuTileExample(
                title: "Example closed hand",
                groups: ["🀇🀈🀉", "🀇🀈🀉", "🀓🀔🀕", "🀓🀔🀕", "🀝🀝"],
                accessibilityDescription: "Two identical 1, 2, 3 character sequences; two identical 4, 5, 6 bamboo sequences; a pair of 5 circles. All concealed."
            )),
            ("清一色", YakuTileExample(
                title: "Example hand",
                groups: ["🀇🀈🀉", "🀉🀊🀋", "🀌🀍🀎", "🀏🀏🀏", "🀋🀋"],
                accessibilityDescription: "1, 2, 3; 3, 4, 5; 6, 7, 8; three 9s; and a pair of 5s, all characters."
            )),
            ("国士無双", YakuTileExample(
                title: "Example completed hand",
                groups: ["🀇🀏", "🀐🀘", "🀙🀡", "🀀🀁🀂🀃", "🀄︎🀅🀆", "🀇"],
                accessibilityDescription: "1 and 9 of each suit, all four winds, all three dragons, plus a second 1 of characters."
            )),
            ("小四喜", YakuTileExample(
                title: "Example hand",
                groups: ["🀀🀀🀀", "🀁🀁🀁", "🀂🀂🀂", "🀃🀃"],
                accessibilityDescription: "East, South, and West wind triplets; a North wind pair; 1, 2, 3 characters."
            )),
            ("字一色", YakuTileExample(
                title: "Example hand",
                groups: ["🀀🀀🀀", "🀁🀁🀁", "🀄︎🀄︎🀄︎", "🀅🀅🀅", "🀆🀆"],
                accessibilityDescription: "East, South, red dragon, and green dragon triplets; a white dragon pair."
            )),
            ("清老頭", YakuTileExample(
                title: "Example hand",
                groups: ["🀇🀇🀇", "🀏🀏🀏", "🀐🀐🀐", "🀡🀡🀡", "🀙🀙"],
                accessibilityDescription: "Triplets of 1 characters, 9 characters, 1 bamboo, and 9 circles; a pair of 1 circles."
            )),
            ("緑一色", YakuTileExample(
                title: "Example hand",
                groups: ["🀑🀒🀓", "🀑🀒🀓", "🀕🀕🀕", "🀗🀗🀗", "🀅🀅"],
                accessibilityDescription: "Two 2, 3, 4 bamboo sequences; triplets of 6 and 8 bamboo; a green dragon pair.",
                isGreen: true
            )),
            ("九連宝燈", YakuTileExample(
                title: "Example completed closed hand",
                groups: ["🀇🀇🀇", "🀈🀉🀊🀋🀌🀍🀎", "🀏🀏🀏", "🀋"],
                accessibilityDescription: "Three 1s, 2 through 8, three 9s, and an extra 5, all characters and concealed."
            )),
            ("四暗刻", YakuTileExample(
                title: "Example hand — all triplets concealed; tsumo",
                groups: ["🀈🀈🀈", "🀔🀔🀔", "🀠🀠🀠", "🀄︎🀄︎🀄︎", "🀀🀀"],
                accessibilityDescription: "Concealed triplets of 2 characters, 5 bamboo, 8 circles, and red dragons; an East wind pair. Win by self draw to complete a triplet."
            )),
            ("国士無双十三面待ち", YakuTileExample(
                title: "13-tile wait — any terminal or honor completes it",
                groups: ["🀇🀏", "🀐🀘", "🀙🀡", "🀀🀁🀂🀃", "🀄︎🀅🀆"],
                accessibilityDescription: "Waiting hand: one of every terminal and honor. Any of these thirteen tiles completes the pair."
            )),
            ("純正九連宝燈", YakuTileExample(
                title: "13-tile closed wait — any 1–9 in this suit",
                groups: ["🀇🀇🀇", "🀈🀉🀊🀋🀌🀍🀎", "🀏🀏🀏"],
                accessibilityDescription: "Waiting hand: three 1s, one each of 2 through 8, and three 9s of characters. Any character tile completes the hand."
            )),
            ("大四喜", YakuTileExample(
                title: "Example hand",
                groups: ["🀀🀀🀀", "🀁🀁🀁", "🀂🀂🀂", "🀃🀃🀃", "🀋🀋"],
                accessibilityDescription: "Triplets of all four winds and a pair of 5 characters."
            )),
            ("大七星", YakuTileExample(
                title: "Example closed hand",
                groups: ["🀀🀀", "🀁🀁", "🀂🀂", "🀃🀃", "🀄︎🀄︎", "🀅🀅", "🀆🀆"],
                accessibilityDescription: "Pairs of East, South, West, North, red dragons, green dragons, and white dragons."
            )),
            ("一盃口", YakuTileExample(
                title: "Example sequences",
                groups: ["🀇🀇🀈🀈🀉🀉 = 🀇🀈🀉 🀇🀈🀉"],
                accessibilityDescription: "Two identical sequences: 1, 2, 3 of characters."
            )),
            ("断幺九", YakuTileExample(
                title: "Example hand",
                groups: ["🀈🀉🀊", "🀓🀔🀕", "🀚🀚🀚", "🀜🀝🀞", "🀖🀖"],
                accessibilityDescription: "2, 3, 4 of characters; 4, 5, 6 of bamboo; three 2s of circles; 4, 5, 6 of circles; a pair of 7s of bamboo. No terminals or honors."
            )),
            ("役牌", YakuTileExample(
                title: "Example dragon triplet",
                groups: ["🀄︎🀄︎🀄︎"],
                accessibilityDescription: "Three red dragons."
            )),
            ("三色同順", YakuTileExample(
                title: "Example sequences",
                groups: ["🀇🀈🀉", "🀐🀑🀒", "🀙🀚🀛"],
                accessibilityDescription: "1, 2, 3 in each of characters, bamboo, and circles."
            )),
            ("一気通貫", YakuTileExample(
                title: "Example sequences",
                groups: ["🀇🀈🀉", "🀊🀋🀌", "🀍🀎🀏"],
                accessibilityDescription: "1, 2, 3; 4, 5, 6; and 7, 8, 9 of characters."
            )),
            ("三色同刻", YakuTileExample(
                title: "Example triplets",
                groups: ["🀈🀈🀈", "🀑🀑🀑", "🀚🀚🀚"],
                accessibilityDescription: "Three 2s in each of characters, bamboo, and circles."
            )),
            ("七対子", YakuTileExample(
                title: "Example hand",
                groups: ["🀇🀇", "🀋🀋", "🀑🀑", "🀕🀕", "🀚🀚", "🀝🀝", "🀆🀆"],
                accessibilityDescription: "Seven distinct pairs: 1 and 5 of characters, 2 and 6 of bamboo, 2 and 5 of circles, and white dragons."
            )),
            ("大三元", YakuTileExample(
                title: "Example dragon triplets",
                groups: ["🀄︎🀄︎🀄︎", "🀅🀅🀅", "🀆🀆🀆"],
                accessibilityDescription: "Three red dragons, three green dragons, and three white dragons."
            ))
        ]
        return examples.first(where: { entry.hasPrefix($0.prefix + " ") || entry.hasPrefix($0.prefix + "（") })?.example
    }
}
