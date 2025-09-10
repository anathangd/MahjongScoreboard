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
        "搶槓 (チャンカン) (**Robbing a Kan**) - calling Ron on another player's Kan (when you have a Tenpai for Thirteen Orphans, you can call on a Closed Kan)",
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
