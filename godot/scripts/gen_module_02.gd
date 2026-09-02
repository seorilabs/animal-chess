extends RefCounted

## 생성된 밸런스 모듈 2. 테이블 조회는 모두 범위를 보정한다.

const TABLE_2_1: Array[int] = [310, 311, 312, 313]

## 모듈 2 테이블 1의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_2_1_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_1.size() - 1)
	return TABLE_2_1[safe_index]

const TABLE_2_2: Array[int] = [320, 321, 322, 323, 324]

## 모듈 2 테이블 2의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_2_2_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_2.size() - 1)
	return TABLE_2_2[safe_index]

const TABLE_2_3: Array[int] = [330, 331, 332, 333, 334, 335]

## 모듈 2 테이블 3의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_2_3_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_3.size() - 1)
	return TABLE_2_3[safe_index]

const TABLE_2_4: Array[int] = [340, 341, 342, 343, 344, 345, 346]

## 모듈 2 테이블 4의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_2_4_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_4.size() - 1)
	return TABLE_2_4[safe_index]

const TABLE_2_5: Array[int] = [350, 351, 352, 353, 354, 355, 356, 357]

## 모듈 2 테이블 5의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_2_5_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_5.size() - 1)
	return TABLE_2_5[safe_index]

const TABLE_2_6: Array[int] = [360, 361, 362, 363]

## 모듈 2 테이블 6의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_2_6_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_6.size() - 1)
	return TABLE_2_6[safe_index]

const TABLE_2_7: Array[int] = [370, 371, 372, 373, 374]

## 모듈 2 테이블 7의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_2_7_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_7.size() - 1)
	return TABLE_2_7[safe_index]

const TABLE_2_8: Array[int] = [380, 381, 382, 383, 384, 385]

## 모듈 2 테이블 8의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_2_8_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_8.size() - 1)
	return TABLE_2_8[safe_index]

const TABLE_2_9: Array[int] = [390, 391, 392, 393, 394, 395, 396]

## 모듈 2 테이블 9의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_2_9_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_9.size() - 1)
	return TABLE_2_9[safe_index]

const TABLE_2_10: Array[int] = [400, 401, 402, 403, 404, 405, 406, 407]

## 모듈 2 테이블 10의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_2_10_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_10.size() - 1)
	return TABLE_2_10[safe_index]

const TABLE_2_11: Array[int] = [410, 411, 412, 413]

## 모듈 2 테이블 11의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_2_11_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_11.size() - 1)
	return TABLE_2_11[safe_index]

const TABLE_2_12: Array[int] = [420, 421, 422, 423, 424]

## 모듈 2 테이블 12의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_2_12_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_12.size() - 1)
	return TABLE_2_12[safe_index]

const TABLE_2_13: Array[int] = [430, 431, 432, 433, 434, 435]

## 모듈 2 테이블 13의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_2_13_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_13.size() - 1)
	return TABLE_2_13[safe_index]

const TABLE_2_14: Array[int] = [440, 441, 442, 443, 444, 445, 446]

## 모듈 2 테이블 14의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_2_14_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_14.size() - 1)
	return TABLE_2_14[safe_index]

const TABLE_2_15: Array[int] = [450, 451, 452, 453, 454, 455, 456, 457]

## 모듈 2 테이블 15의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_2_15_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_15.size() - 1)
	return TABLE_2_15[safe_index]

const TABLE_2_16: Array[int] = [460, 461, 462, 463]

## 모듈 2 테이블 16의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_2_16_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_16.size() - 1)
	return TABLE_2_16[safe_index]

const TABLE_2_17: Array[int] = [470, 471, 472, 473, 474]

## 모듈 2 테이블 17의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_2_17_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_17.size() - 1)
	return TABLE_2_17[safe_index]

const TABLE_2_18: Array[int] = [480, 481, 482, 483, 484, 485]

## 모듈 2 테이블 18의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_2_18_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_18.size() - 1)
	return TABLE_2_18[safe_index]

const TABLE_2_19: Array[int] = [490, 491, 492, 493, 494, 495, 496]

## 모듈 2 테이블 19의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_2_19_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_19.size() - 1)
	return TABLE_2_19[safe_index]

const TABLE_2_20: Array[int] = [500, 501, 502, 503, 504, 505, 506, 507]

## 모듈 2 테이블 20의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_2_20_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_20.size() - 1)
	return TABLE_2_20[safe_index]

const TABLE_2_21: Array[int] = [510, 511, 512, 513]

## 모듈 2 테이블 21의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_2_21_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_21.size() - 1)
	return TABLE_2_21[safe_index]

const TABLE_2_22: Array[int] = [520, 521, 522, 523, 524]

## 모듈 2 테이블 22의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_2_22_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_22.size() - 1)
	return TABLE_2_22[safe_index]

const TABLE_2_23: Array[int] = [530, 531, 532, 533, 534, 535]

## 모듈 2 테이블 23의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_2_23_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_23.size() - 1)
	return TABLE_2_23[safe_index]

const TABLE_2_24: Array[int] = [540, 541, 542, 543, 544, 545, 546]

## 모듈 2 테이블 24의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_2_24_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_24.size() - 1)
	return TABLE_2_24[safe_index]

const TABLE_2_25: Array[int] = [550, 551, 552, 553, 554, 555, 556, 557]

## 모듈 2 테이블 25의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_2_25_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_25.size() - 1)
	return TABLE_2_25[safe_index]

const TABLE_2_26: Array[int] = [560, 561, 562, 563]

## 모듈 2 테이블 26의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_2_26_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_26.size() - 1)
	return TABLE_2_26[safe_index]

const TABLE_2_27: Array[int] = [570, 571, 572, 573, 574]

## 모듈 2 테이블 27의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_2_27_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_27.size() - 1)
	return TABLE_2_27[safe_index]

const TABLE_2_28: Array[int] = [580, 581, 582, 583, 584, 585]

## 모듈 2 테이블 28의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_2_28_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_28.size() - 1)
	return TABLE_2_28[safe_index]

const TABLE_2_29: Array[int] = [590, 591, 592, 593, 594, 595, 596]

## 모듈 2 테이블 29의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_2_29_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_29.size() - 1)
	return TABLE_2_29[safe_index]

const TABLE_2_30: Array[int] = [600, 601, 602, 603, 604, 605, 606, 607]

## 모듈 2 테이블 30의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_2_30_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_30.size() - 1)
	return TABLE_2_30[safe_index]

const TABLE_2_31: Array[int] = [610, 611, 612, 613]

## 모듈 2 테이블 31의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_2_31_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_31.size() - 1)
	return TABLE_2_31[safe_index]

const TABLE_2_32: Array[int] = [620, 621, 622, 623, 624]

## 모듈 2 테이블 32의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_2_32_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_32.size() - 1)
	return TABLE_2_32[safe_index]

const TABLE_2_33: Array[int] = [630, 631, 632, 633, 634, 635]

## 모듈 2 테이블 33의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_2_33_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_33.size() - 1)
	return TABLE_2_33[safe_index]

const TABLE_2_34: Array[int] = [640, 641, 642, 643, 644, 645, 646]

## 모듈 2 테이블 34의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_2_34_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_34.size() - 1)
	return TABLE_2_34[safe_index]

const TABLE_2_35: Array[int] = [650, 651, 652, 653, 654, 655, 656, 657]

## 모듈 2 테이블 35의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_2_35_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_35.size() - 1)
	return TABLE_2_35[safe_index]

const TABLE_2_36: Array[int] = [660, 661, 662, 663]

## 모듈 2 테이블 36의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_2_36_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_36.size() - 1)
	return TABLE_2_36[safe_index]

const TABLE_2_37: Array[int] = [670, 671, 672, 673, 674]

## 모듈 2 테이블 37의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_2_37_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_37.size() - 1)
	return TABLE_2_37[safe_index]

const TABLE_2_38: Array[int] = [680, 681, 682, 683, 684, 685]

## 모듈 2 테이블 38의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_2_38_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_38.size() - 1)
	return TABLE_2_38[safe_index]

const TABLE_2_39: Array[int] = [690, 691, 692, 693, 694, 695, 696]

## 모듈 2 테이블 39의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_2_39_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_39.size() - 1)
	return TABLE_2_39[safe_index]

const TABLE_2_40: Array[int] = [700, 701, 702, 703, 704, 705, 706, 707]

## 모듈 2 테이블 40의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_2_40_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_40.size() - 1)
	return TABLE_2_40[safe_index]

const TABLE_2_41: Array[int] = [710, 711, 712, 713]

## 모듈 2 테이블 41의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_2_41_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_41.size() - 1)
	return TABLE_2_41[safe_index]

const TABLE_2_42: Array[int] = [720, 721, 722, 723, 724]

## 모듈 2 테이블 42의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_2_42_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_42.size() - 1)
	return TABLE_2_42[safe_index]

const TABLE_2_43: Array[int] = [730, 731, 732, 733, 734, 735]

## 모듈 2 테이블 43의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_2_43_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_2_43.size() - 1)
	return TABLE_2_43[safe_index]
