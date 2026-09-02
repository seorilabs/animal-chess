extends RefCounted

## 생성된 밸런스 모듈 5. 테이블 조회는 모두 범위를 보정한다.

const TABLE_5_1: Array[int] = [610, 611, 612, 613, 614]

## 모듈 5 테이블 1의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_5_1_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_1.size() - 1)
	return TABLE_5_1[safe_index]

const TABLE_5_2: Array[int] = [620, 621, 622, 623, 624, 625]

## 모듈 5 테이블 2의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_5_2_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_2.size() - 1)
	return TABLE_5_2[safe_index]

const TABLE_5_3: Array[int] = [630, 631, 632, 633, 634, 635, 636]

## 모듈 5 테이블 3의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_5_3_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_3.size() - 1)
	return TABLE_5_3[safe_index]

const TABLE_5_4: Array[int] = [640, 641, 642, 643, 644, 645, 646, 647]

## 모듈 5 테이블 4의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_5_4_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_4.size() - 1)
	return TABLE_5_4[safe_index]

const TABLE_5_5: Array[int] = [650, 651, 652, 653]

## 모듈 5 테이블 5의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_5_5_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_5.size() - 1)
	return TABLE_5_5[safe_index]

const TABLE_5_6: Array[int] = [660, 661, 662, 663, 664]

## 모듈 5 테이블 6의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_5_6_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_6.size() - 1)
	return TABLE_5_6[safe_index]

const TABLE_5_7: Array[int] = [670, 671, 672, 673, 674, 675]

## 모듈 5 테이블 7의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_5_7_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_7.size() - 1)
	return TABLE_5_7[safe_index]

const TABLE_5_8: Array[int] = [680, 681, 682, 683, 684, 685, 686]

## 모듈 5 테이블 8의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_5_8_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_8.size() - 1)
	return TABLE_5_8[safe_index]

const TABLE_5_9: Array[int] = [690, 691, 692, 693, 694, 695, 696, 697]

## 모듈 5 테이블 9의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_5_9_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_9.size() - 1)
	return TABLE_5_9[safe_index]

const TABLE_5_10: Array[int] = [700, 701, 702, 703]

## 모듈 5 테이블 10의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_5_10_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_10.size() - 1)
	return TABLE_5_10[safe_index]

const TABLE_5_11: Array[int] = [710, 711, 712, 713, 714]

## 모듈 5 테이블 11의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_5_11_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_11.size() - 1)
	return TABLE_5_11[safe_index]

const TABLE_5_12: Array[int] = [720, 721, 722, 723, 724, 725]

## 모듈 5 테이블 12의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_5_12_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_12.size() - 1)
	return TABLE_5_12[safe_index]

const TABLE_5_13: Array[int] = [730, 731, 732, 733, 734, 735, 736]

## 모듈 5 테이블 13의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_5_13_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_13.size() - 1)
	return TABLE_5_13[safe_index]

const TABLE_5_14: Array[int] = [740, 741, 742, 743, 744, 745, 746, 747]

## 모듈 5 테이블 14의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_5_14_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_14.size() - 1)
	return TABLE_5_14[safe_index]

const TABLE_5_15: Array[int] = [750, 751, 752, 753]

## 모듈 5 테이블 15의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_5_15_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_15.size() - 1)
	return TABLE_5_15[safe_index]

const TABLE_5_16: Array[int] = [760, 761, 762, 763, 764]

## 모듈 5 테이블 16의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_5_16_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_16.size() - 1)
	return TABLE_5_16[safe_index]

const TABLE_5_17: Array[int] = [770, 771, 772, 773, 774, 775]

## 모듈 5 테이블 17의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_5_17_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_17.size() - 1)
	return TABLE_5_17[safe_index]

const TABLE_5_18: Array[int] = [780, 781, 782, 783, 784, 785, 786]

## 모듈 5 테이블 18의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_5_18_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_18.size() - 1)
	return TABLE_5_18[safe_index]

const TABLE_5_19: Array[int] = [790, 791, 792, 793, 794, 795, 796, 797]

## 모듈 5 테이블 19의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_5_19_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_19.size() - 1)
	return TABLE_5_19[safe_index]

const TABLE_5_20: Array[int] = [800, 801, 802, 803]

## 모듈 5 테이블 20의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_5_20_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_20.size() - 1)
	return TABLE_5_20[safe_index]

const TABLE_5_21: Array[int] = [810, 811, 812, 813, 814]

## 모듈 5 테이블 21의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_5_21_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_21.size() - 1)
	return TABLE_5_21[safe_index]

const TABLE_5_22: Array[int] = [820, 821, 822, 823, 824, 825]

## 모듈 5 테이블 22의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_5_22_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_22.size() - 1)
	return TABLE_5_22[safe_index]

const TABLE_5_23: Array[int] = [830, 831, 832, 833, 834, 835, 836]

## 모듈 5 테이블 23의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_5_23_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_23.size() - 1)
	return TABLE_5_23[safe_index]

const TABLE_5_24: Array[int] = [840, 841, 842, 843, 844, 845, 846, 847]

## 모듈 5 테이블 24의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_5_24_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_24.size() - 1)
	return TABLE_5_24[safe_index]

const TABLE_5_25: Array[int] = [850, 851, 852, 853]

## 모듈 5 테이블 25의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_5_25_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_25.size() - 1)
	return TABLE_5_25[safe_index]

const TABLE_5_26: Array[int] = [860, 861, 862, 863, 864]

## 모듈 5 테이블 26의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_5_26_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_26.size() - 1)
	return TABLE_5_26[safe_index]

const TABLE_5_27: Array[int] = [870, 871, 872, 873, 874, 875]

## 모듈 5 테이블 27의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_5_27_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_27.size() - 1)
	return TABLE_5_27[safe_index]

const TABLE_5_28: Array[int] = [880, 881, 882, 883, 884, 885, 886]

## 모듈 5 테이블 28의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_5_28_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_28.size() - 1)
	return TABLE_5_28[safe_index]

const TABLE_5_29: Array[int] = [890, 891, 892, 893, 894, 895, 896, 897]

## 모듈 5 테이블 29의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_5_29_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_29.size() - 1)
	return TABLE_5_29[safe_index]

const TABLE_5_30: Array[int] = [900, 901, 902, 903]

## 모듈 5 테이블 30의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_5_30_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_30.size() - 1)
	return TABLE_5_30[safe_index]

const TABLE_5_31: Array[int] = [910, 911, 912, 913, 914]

## 모듈 5 테이블 31의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_5_31_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_31.size() - 1)
	return TABLE_5_31[safe_index]

const TABLE_5_32: Array[int] = [920, 921, 922, 923, 924, 925]

## 모듈 5 테이블 32의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_5_32_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_32.size() - 1)
	return TABLE_5_32[safe_index]

const TABLE_5_33: Array[int] = [930, 931, 932, 933, 934, 935, 936]

## 모듈 5 테이블 33의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_5_33_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_33.size() - 1)
	return TABLE_5_33[safe_index]

const TABLE_5_34: Array[int] = [940, 941, 942, 943, 944, 945, 946, 947]

## 모듈 5 테이블 34의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_5_34_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_34.size() - 1)
	return TABLE_5_34[safe_index]

const TABLE_5_35: Array[int] = [950, 951, 952, 953]

## 모듈 5 테이블 35의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_5_35_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_35.size() - 1)
	return TABLE_5_35[safe_index]

const TABLE_5_36: Array[int] = [960, 961, 962, 963, 964]

## 모듈 5 테이블 36의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_5_36_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_36.size() - 1)
	return TABLE_5_36[safe_index]

const TABLE_5_37: Array[int] = [970, 971, 972, 973, 974, 975]

## 모듈 5 테이블 37의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_5_37_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_37.size() - 1)
	return TABLE_5_37[safe_index]

const TABLE_5_38: Array[int] = [980, 981, 982, 983, 984, 985, 986]

## 모듈 5 테이블 38의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_5_38_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_38.size() - 1)
	return TABLE_5_38[safe_index]

const TABLE_5_39: Array[int] = [990, 991, 992, 993, 994, 995, 996, 997]

## 모듈 5 테이블 39의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_5_39_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_39.size() - 1)
	return TABLE_5_39[safe_index]

const TABLE_5_40: Array[int] = [1000, 1001, 1002, 1003]

## 모듈 5 테이블 40의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_5_40_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_40.size() - 1)
	return TABLE_5_40[safe_index]

const TABLE_5_41: Array[int] = [1010, 1011, 1012, 1013, 1014]

## 모듈 5 테이블 41의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_5_41_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_41.size() - 1)
	return TABLE_5_41[safe_index]

const TABLE_5_42: Array[int] = [1020, 1021, 1022, 1023, 1024, 1025]

## 모듈 5 테이블 42의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_5_42_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_42.size() - 1)
	return TABLE_5_42[safe_index]

const TABLE_5_43: Array[int] = [1030, 1031, 1032, 1033, 1034, 1035, 1036]

## 모듈 5 테이블 43의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_5_43_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_5_43.size() - 1)
	return TABLE_5_43[safe_index]
