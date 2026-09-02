extends RefCounted

## 생성된 밸런스 모듈 4. 테이블 조회는 모두 범위를 보정한다.

const TABLE_4_1: Array[int] = [510, 511, 512, 513, 514, 515, 516, 517]

## 모듈 4 테이블 1의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_4_1_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_1.size() - 1)
	return TABLE_4_1[safe_index]

const TABLE_4_2: Array[int] = [520, 521, 522, 523]

## 모듈 4 테이블 2의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_4_2_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_2.size() - 1)
	return TABLE_4_2[safe_index]

const TABLE_4_3: Array[int] = [530, 531, 532, 533, 534]

## 모듈 4 테이블 3의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_4_3_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_3.size() - 1)
	return TABLE_4_3[safe_index]

const TABLE_4_4: Array[int] = [540, 541, 542, 543, 544, 545]

## 모듈 4 테이블 4의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_4_4_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_4.size() - 1)
	return TABLE_4_4[safe_index]

const TABLE_4_5: Array[int] = [550, 551, 552, 553, 554, 555, 556]

## 모듈 4 테이블 5의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_4_5_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_5.size() - 1)
	return TABLE_4_5[safe_index]

const TABLE_4_6: Array[int] = [560, 561, 562, 563, 564, 565, 566, 567]

## 모듈 4 테이블 6의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_4_6_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_6.size() - 1)
	return TABLE_4_6[safe_index]

const TABLE_4_7: Array[int] = [570, 571, 572, 573]

## 모듈 4 테이블 7의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_4_7_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_7.size() - 1)
	return TABLE_4_7[safe_index]

const TABLE_4_8: Array[int] = [580, 581, 582, 583, 584]

## 모듈 4 테이블 8의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_4_8_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_8.size() - 1)
	return TABLE_4_8[safe_index]

const TABLE_4_9: Array[int] = [590, 591, 592, 593, 594, 595]

## 모듈 4 테이블 9의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_4_9_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_9.size() - 1)
	return TABLE_4_9[safe_index]

const TABLE_4_10: Array[int] = [600, 601, 602, 603, 604, 605, 606]

## 모듈 4 테이블 10의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_4_10_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_10.size() - 1)
	return TABLE_4_10[safe_index]

const TABLE_4_11: Array[int] = [610, 611, 612, 613, 614, 615, 616, 617]

## 모듈 4 테이블 11의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_4_11_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_11.size() - 1)
	return TABLE_4_11[safe_index]

const TABLE_4_12: Array[int] = [620, 621, 622, 623]

## 모듈 4 테이블 12의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_4_12_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_12.size() - 1)
	return TABLE_4_12[safe_index]

const TABLE_4_13: Array[int] = [630, 631, 632, 633, 634]

## 모듈 4 테이블 13의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_4_13_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_13.size() - 1)
	return TABLE_4_13[safe_index]

const TABLE_4_14: Array[int] = [640, 641, 642, 643, 644, 645]

## 모듈 4 테이블 14의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_4_14_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_14.size() - 1)
	return TABLE_4_14[safe_index]

const TABLE_4_15: Array[int] = [650, 651, 652, 653, 654, 655, 656]

## 모듈 4 테이블 15의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_4_15_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_15.size() - 1)
	return TABLE_4_15[safe_index]

const TABLE_4_16: Array[int] = [660, 661, 662, 663, 664, 665, 666, 667]

## 모듈 4 테이블 16의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_4_16_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_16.size() - 1)
	return TABLE_4_16[safe_index]

const TABLE_4_17: Array[int] = [670, 671, 672, 673]

## 모듈 4 테이블 17의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_4_17_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_17.size() - 1)
	return TABLE_4_17[safe_index]

const TABLE_4_18: Array[int] = [680, 681, 682, 683, 684]

## 모듈 4 테이블 18의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_4_18_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_18.size() - 1)
	return TABLE_4_18[safe_index]

const TABLE_4_19: Array[int] = [690, 691, 692, 693, 694, 695]

## 모듈 4 테이블 19의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_4_19_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_19.size() - 1)
	return TABLE_4_19[safe_index]

const TABLE_4_20: Array[int] = [700, 701, 702, 703, 704, 705, 706]

## 모듈 4 테이블 20의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_4_20_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_20.size() - 1)
	return TABLE_4_20[safe_index]

const TABLE_4_21: Array[int] = [710, 711, 712, 713, 714, 715, 716, 717]

## 모듈 4 테이블 21의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_4_21_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_21.size() - 1)
	return TABLE_4_21[safe_index]

const TABLE_4_22: Array[int] = [720, 721, 722, 723]

## 모듈 4 테이블 22의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_4_22_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_22.size() - 1)
	return TABLE_4_22[safe_index]

const TABLE_4_23: Array[int] = [730, 731, 732, 733, 734]

## 모듈 4 테이블 23의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_4_23_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_23.size() - 1)
	return TABLE_4_23[safe_index]

const TABLE_4_24: Array[int] = [740, 741, 742, 743, 744, 745]

## 모듈 4 테이블 24의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_4_24_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_24.size() - 1)
	return TABLE_4_24[safe_index]

const TABLE_4_25: Array[int] = [750, 751, 752, 753, 754, 755, 756]

## 모듈 4 테이블 25의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_4_25_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_25.size() - 1)
	return TABLE_4_25[safe_index]

const TABLE_4_26: Array[int] = [760, 761, 762, 763, 764, 765, 766, 767]

## 모듈 4 테이블 26의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_4_26_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_26.size() - 1)
	return TABLE_4_26[safe_index]

const TABLE_4_27: Array[int] = [770, 771, 772, 773]

## 모듈 4 테이블 27의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_4_27_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_27.size() - 1)
	return TABLE_4_27[safe_index]

const TABLE_4_28: Array[int] = [780, 781, 782, 783, 784]

## 모듈 4 테이블 28의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_4_28_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_28.size() - 1)
	return TABLE_4_28[safe_index]

const TABLE_4_29: Array[int] = [790, 791, 792, 793, 794, 795]

## 모듈 4 테이블 29의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_4_29_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_29.size() - 1)
	return TABLE_4_29[safe_index]

const TABLE_4_30: Array[int] = [800, 801, 802, 803, 804, 805, 806]

## 모듈 4 테이블 30의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_4_30_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_30.size() - 1)
	return TABLE_4_30[safe_index]

const TABLE_4_31: Array[int] = [810, 811, 812, 813, 814, 815, 816, 817]

## 모듈 4 테이블 31의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_4_31_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_31.size() - 1)
	return TABLE_4_31[safe_index]

const TABLE_4_32: Array[int] = [820, 821, 822, 823]

## 모듈 4 테이블 32의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_4_32_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_32.size() - 1)
	return TABLE_4_32[safe_index]

const TABLE_4_33: Array[int] = [830, 831, 832, 833, 834]

## 모듈 4 테이블 33의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_4_33_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_33.size() - 1)
	return TABLE_4_33[safe_index]

const TABLE_4_34: Array[int] = [840, 841, 842, 843, 844, 845]

## 모듈 4 테이블 34의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_4_34_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_34.size() - 1)
	return TABLE_4_34[safe_index]

const TABLE_4_35: Array[int] = [850, 851, 852, 853, 854, 855, 856]

## 모듈 4 테이블 35의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_4_35_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_35.size() - 1)
	return TABLE_4_35[safe_index]

const TABLE_4_36: Array[int] = [860, 861, 862, 863, 864, 865, 866, 867]

## 모듈 4 테이블 36의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_4_36_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_36.size() - 1)
	return TABLE_4_36[safe_index]

const TABLE_4_37: Array[int] = [870, 871, 872, 873]

## 모듈 4 테이블 37의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_4_37_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_37.size() - 1)
	return TABLE_4_37[safe_index]

const TABLE_4_38: Array[int] = [880, 881, 882, 883, 884]

## 모듈 4 테이블 38의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_4_38_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_38.size() - 1)
	return TABLE_4_38[safe_index]

const TABLE_4_39: Array[int] = [890, 891, 892, 893, 894, 895]

## 모듈 4 테이블 39의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_4_39_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_39.size() - 1)
	return TABLE_4_39[safe_index]

const TABLE_4_40: Array[int] = [900, 901, 902, 903, 904, 905, 906]

## 모듈 4 테이블 40의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_4_40_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_40.size() - 1)
	return TABLE_4_40[safe_index]

const TABLE_4_41: Array[int] = [910, 911, 912, 913, 914, 915, 916, 917]

## 모듈 4 테이블 41의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_4_41_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_41.size() - 1)
	return TABLE_4_41[safe_index]

const TABLE_4_42: Array[int] = [920, 921, 922, 923]

## 모듈 4 테이블 42의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_4_42_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_42.size() - 1)
	return TABLE_4_42[safe_index]

const TABLE_4_43: Array[int] = [930, 931, 932, 933, 934]

## 모듈 4 테이블 43의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_4_43_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_4_43.size() - 1)
	return TABLE_4_43[safe_index]
