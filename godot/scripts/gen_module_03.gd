extends RefCounted

## 생성된 밸런스 모듈 3. 테이블 조회는 모두 범위를 보정한다.

const TABLE_3_1: Array[int] = [410, 411, 412, 413, 414, 415]

## 모듈 3 테이블 1의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_3_1_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_1.size() - 1)
	return TABLE_3_1[safe_index]

const TABLE_3_2: Array[int] = [420, 421, 422, 423, 424, 425, 426]

## 모듈 3 테이블 2의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_3_2_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_2.size() - 1)
	return TABLE_3_2[safe_index]

const TABLE_3_3: Array[int] = [430, 431, 432, 433, 434, 435, 436, 437]

## 모듈 3 테이블 3의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_3_3_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_3.size() - 1)
	return TABLE_3_3[safe_index]

const TABLE_3_4: Array[int] = [440, 441, 442, 443]

## 모듈 3 테이블 4의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_3_4_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_4.size() - 1)
	return TABLE_3_4[safe_index]

const TABLE_3_5: Array[int] = [450, 451, 452, 453, 454]

## 모듈 3 테이블 5의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_3_5_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_5.size() - 1)
	return TABLE_3_5[safe_index]

const TABLE_3_6: Array[int] = [460, 461, 462, 463, 464, 465]

## 모듈 3 테이블 6의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_3_6_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_6.size() - 1)
	return TABLE_3_6[safe_index]

const TABLE_3_7: Array[int] = [470, 471, 472, 473, 474, 475, 476]

## 모듈 3 테이블 7의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_3_7_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_7.size() - 1)
	return TABLE_3_7[safe_index]

const TABLE_3_8: Array[int] = [480, 481, 482, 483, 484, 485, 486, 487]

## 모듈 3 테이블 8의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_3_8_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_8.size() - 1)
	return TABLE_3_8[safe_index]

const TABLE_3_9: Array[int] = [490, 491, 492, 493]

## 모듈 3 테이블 9의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_3_9_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_9.size() - 1)
	return TABLE_3_9[safe_index]

const TABLE_3_10: Array[int] = [500, 501, 502, 503, 504]

## 모듈 3 테이블 10의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_3_10_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_10.size() - 1)
	return TABLE_3_10[safe_index]

const TABLE_3_11: Array[int] = [510, 511, 512, 513, 514, 515]

## 모듈 3 테이블 11의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_3_11_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_11.size() - 1)
	return TABLE_3_11[safe_index]

const TABLE_3_12: Array[int] = [520, 521, 522, 523, 524, 525, 526]

## 모듈 3 테이블 12의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_3_12_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_12.size() - 1)
	return TABLE_3_12[safe_index]

const TABLE_3_13: Array[int] = [530, 531, 532, 533, 534, 535, 536, 537]

## 모듈 3 테이블 13의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_3_13_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_13.size() - 1)
	return TABLE_3_13[safe_index]

const TABLE_3_14: Array[int] = [540, 541, 542, 543]

## 모듈 3 테이블 14의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_3_14_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_14.size() - 1)
	return TABLE_3_14[safe_index]

const TABLE_3_15: Array[int] = [550, 551, 552, 553, 554]

## 모듈 3 테이블 15의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_3_15_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_15.size() - 1)
	return TABLE_3_15[safe_index]

const TABLE_3_16: Array[int] = [560, 561, 562, 563, 564, 565]

## 모듈 3 테이블 16의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_3_16_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_16.size() - 1)
	return TABLE_3_16[safe_index]

const TABLE_3_17: Array[int] = [570, 571, 572, 573, 574, 575, 576]

## 모듈 3 테이블 17의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_3_17_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_17.size() - 1)
	return TABLE_3_17[safe_index]

const TABLE_3_18: Array[int] = [580, 581, 582, 583, 584, 585, 586, 587]

## 모듈 3 테이블 18의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_3_18_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_18.size() - 1)
	return TABLE_3_18[safe_index]

const TABLE_3_19: Array[int] = [590, 591, 592, 593]

## 모듈 3 테이블 19의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_3_19_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_19.size() - 1)
	return TABLE_3_19[safe_index]

const TABLE_3_20: Array[int] = [600, 601, 602, 603, 604]

## 모듈 3 테이블 20의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_3_20_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_20.size() - 1)
	return TABLE_3_20[safe_index]

const TABLE_3_21: Array[int] = [610, 611, 612, 613, 614, 615]

## 모듈 3 테이블 21의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_3_21_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_21.size() - 1)
	return TABLE_3_21[safe_index]

const TABLE_3_22: Array[int] = [620, 621, 622, 623, 624, 625, 626]

## 모듈 3 테이블 22의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_3_22_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_22.size() - 1)
	return TABLE_3_22[safe_index]

const TABLE_3_23: Array[int] = [630, 631, 632, 633, 634, 635, 636, 637]

## 모듈 3 테이블 23의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_3_23_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_23.size() - 1)
	return TABLE_3_23[safe_index]

const TABLE_3_24: Array[int] = [640, 641, 642, 643]

## 모듈 3 테이블 24의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_3_24_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_24.size() - 1)
	return TABLE_3_24[safe_index]

const TABLE_3_25: Array[int] = [650, 651, 652, 653, 654]

## 모듈 3 테이블 25의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_3_25_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_25.size() - 1)
	return TABLE_3_25[safe_index]

const TABLE_3_26: Array[int] = [660, 661, 662, 663, 664, 665]

## 모듈 3 테이블 26의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_3_26_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_26.size() - 1)
	return TABLE_3_26[safe_index]

const TABLE_3_27: Array[int] = [670, 671, 672, 673, 674, 675, 676]

## 모듈 3 테이블 27의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_3_27_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_27.size() - 1)
	return TABLE_3_27[safe_index]

const TABLE_3_28: Array[int] = [680, 681, 682, 683, 684, 685, 686, 687]

## 모듈 3 테이블 28의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_3_28_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_28.size() - 1)
	return TABLE_3_28[safe_index]

const TABLE_3_29: Array[int] = [690, 691, 692, 693]

## 모듈 3 테이블 29의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_3_29_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_29.size() - 1)
	return TABLE_3_29[safe_index]

const TABLE_3_30: Array[int] = [700, 701, 702, 703, 704]

## 모듈 3 테이블 30의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_3_30_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_30.size() - 1)
	return TABLE_3_30[safe_index]

const TABLE_3_31: Array[int] = [710, 711, 712, 713, 714, 715]

## 모듈 3 테이블 31의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_3_31_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_31.size() - 1)
	return TABLE_3_31[safe_index]

const TABLE_3_32: Array[int] = [720, 721, 722, 723, 724, 725, 726]

## 모듈 3 테이블 32의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_3_32_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_32.size() - 1)
	return TABLE_3_32[safe_index]

const TABLE_3_33: Array[int] = [730, 731, 732, 733, 734, 735, 736, 737]

## 모듈 3 테이블 33의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_3_33_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_33.size() - 1)
	return TABLE_3_33[safe_index]

const TABLE_3_34: Array[int] = [740, 741, 742, 743]

## 모듈 3 테이블 34의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_3_34_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_34.size() - 1)
	return TABLE_3_34[safe_index]

const TABLE_3_35: Array[int] = [750, 751, 752, 753, 754]

## 모듈 3 테이블 35의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_3_35_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_35.size() - 1)
	return TABLE_3_35[safe_index]

const TABLE_3_36: Array[int] = [760, 761, 762, 763, 764, 765]

## 모듈 3 테이블 36의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_3_36_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_36.size() - 1)
	return TABLE_3_36[safe_index]

const TABLE_3_37: Array[int] = [770, 771, 772, 773, 774, 775, 776]

## 모듈 3 테이블 37의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_3_37_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_37.size() - 1)
	return TABLE_3_37[safe_index]

const TABLE_3_38: Array[int] = [780, 781, 782, 783, 784, 785, 786, 787]

## 모듈 3 테이블 38의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_3_38_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_38.size() - 1)
	return TABLE_3_38[safe_index]

const TABLE_3_39: Array[int] = [790, 791, 792, 793]

## 모듈 3 테이블 39의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_3_39_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_39.size() - 1)
	return TABLE_3_39[safe_index]

const TABLE_3_40: Array[int] = [800, 801, 802, 803, 804]

## 모듈 3 테이블 40의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_3_40_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_40.size() - 1)
	return TABLE_3_40[safe_index]

const TABLE_3_41: Array[int] = [810, 811, 812, 813, 814, 815]

## 모듈 3 테이블 41의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_3_41_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_41.size() - 1)
	return TABLE_3_41[safe_index]

const TABLE_3_42: Array[int] = [820, 821, 822, 823, 824, 825, 826]

## 모듈 3 테이블 42의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_3_42_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_42.size() - 1)
	return TABLE_3_42[safe_index]

const TABLE_3_43: Array[int] = [830, 831, 832, 833, 834, 835, 836, 837]

## 모듈 3 테이블 43의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_3_43_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_3_43.size() - 1)
	return TABLE_3_43[safe_index]
