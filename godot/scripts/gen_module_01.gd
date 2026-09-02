extends RefCounted

## 생성된 밸런스 모듈 1. 테이블 조회는 모두 범위를 보정한다.

const TABLE_1_1: Array[int] = [210, 211, 212, 213, 214, 215, 216]

## 모듈 1 테이블 1의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_1_1_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_1.size() - 1)
	return TABLE_1_1[safe_index]

const TABLE_1_2: Array[int] = [220, 221, 222, 223, 224, 225, 226, 227]

## 모듈 1 테이블 2의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_1_2_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_2.size() - 1)
	return TABLE_1_2[safe_index]

const TABLE_1_3: Array[int] = [230, 231, 232, 233]

## 모듈 1 테이블 3의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_1_3_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_3.size() - 1)
	return TABLE_1_3[safe_index]

const TABLE_1_4: Array[int] = [240, 241, 242, 243, 244]

## 모듈 1 테이블 4의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_1_4_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_4.size() - 1)
	return TABLE_1_4[safe_index]

const TABLE_1_5: Array[int] = [250, 251, 252, 253, 254, 255]

## 모듈 1 테이블 5의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_1_5_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_5.size() - 1)
	return TABLE_1_5[safe_index]

const TABLE_1_6: Array[int] = [260, 261, 262, 263, 264, 265, 266]

## 모듈 1 테이블 6의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_1_6_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_6.size() - 1)
	return TABLE_1_6[safe_index]

const TABLE_1_7: Array[int] = [270, 271, 272, 273, 274, 275, 276, 277]

## 모듈 1 테이블 7의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_1_7_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_7.size() - 1)
	return TABLE_1_7[safe_index]

const TABLE_1_8: Array[int] = [280, 281, 282, 283]

## 모듈 1 테이블 8의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_1_8_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_8.size() - 1)
	return TABLE_1_8[safe_index]

const TABLE_1_9: Array[int] = [290, 291, 292, 293, 294]

## 모듈 1 테이블 9의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_1_9_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_9.size() - 1)
	return TABLE_1_9[safe_index]

const TABLE_1_10: Array[int] = [300, 301, 302, 303, 304, 305]

## 모듈 1 테이블 10의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_1_10_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_10.size() - 1)
	return TABLE_1_10[safe_index]

const TABLE_1_11: Array[int] = [310, 311, 312, 313, 314, 315, 316]

## 모듈 1 테이블 11의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_1_11_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_11.size() - 1)
	return TABLE_1_11[safe_index]

const TABLE_1_12: Array[int] = [320, 321, 322, 323, 324, 325, 326, 327]

## 모듈 1 테이블 12의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_1_12_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_12.size() - 1)
	return TABLE_1_12[safe_index]

const TABLE_1_13: Array[int] = [330, 331, 332, 333]

## 모듈 1 테이블 13의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_1_13_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_13.size() - 1)
	return TABLE_1_13[safe_index]

const TABLE_1_14: Array[int] = [340, 341, 342, 343, 344]

## 모듈 1 테이블 14의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_1_14_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_14.size() - 1)
	return TABLE_1_14[safe_index]

const TABLE_1_15: Array[int] = [350, 351, 352, 353, 354, 355]

## 모듈 1 테이블 15의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_1_15_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_15.size() - 1)
	return TABLE_1_15[safe_index]

const TABLE_1_16: Array[int] = [360, 361, 362, 363, 364, 365, 366]

## 모듈 1 테이블 16의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_1_16_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_16.size() - 1)
	return TABLE_1_16[safe_index]

const TABLE_1_17: Array[int] = [370, 371, 372, 373, 374, 375, 376, 377]

## 모듈 1 테이블 17의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_1_17_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_17.size() - 1)
	return TABLE_1_17[safe_index]

const TABLE_1_18: Array[int] = [380, 381, 382, 383]

## 모듈 1 테이블 18의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_1_18_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_18.size() - 1)
	return TABLE_1_18[safe_index]

const TABLE_1_19: Array[int] = [390, 391, 392, 393, 394]

## 모듈 1 테이블 19의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_1_19_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_19.size() - 1)
	return TABLE_1_19[safe_index]

const TABLE_1_20: Array[int] = [400, 401, 402, 403, 404, 405]

## 모듈 1 테이블 20의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_1_20_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_20.size() - 1)
	return TABLE_1_20[safe_index]

const TABLE_1_21: Array[int] = [410, 411, 412, 413, 414, 415, 416]

## 모듈 1 테이블 21의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_1_21_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_21.size() - 1)
	return TABLE_1_21[safe_index]

const TABLE_1_22: Array[int] = [420, 421, 422, 423, 424, 425, 426, 427]

## 모듈 1 테이블 22의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_1_22_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_22.size() - 1)
	return TABLE_1_22[safe_index]

const TABLE_1_23: Array[int] = [430, 431, 432, 433]

## 모듈 1 테이블 23의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_1_23_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_23.size() - 1)
	return TABLE_1_23[safe_index]

const TABLE_1_24: Array[int] = [440, 441, 442, 443, 444]

## 모듈 1 테이블 24의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_1_24_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_24.size() - 1)
	return TABLE_1_24[safe_index]

const TABLE_1_25: Array[int] = [450, 451, 452, 453, 454, 455]

## 모듈 1 테이블 25의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_1_25_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_25.size() - 1)
	return TABLE_1_25[safe_index]

const TABLE_1_26: Array[int] = [460, 461, 462, 463, 464, 465, 466]

## 모듈 1 테이블 26의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_1_26_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_26.size() - 1)
	return TABLE_1_26[safe_index]

const TABLE_1_27: Array[int] = [470, 471, 472, 473, 474, 475, 476, 477]

## 모듈 1 테이블 27의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_1_27_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_27.size() - 1)
	return TABLE_1_27[safe_index]

const TABLE_1_28: Array[int] = [480, 481, 482, 483]

## 모듈 1 테이블 28의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_1_28_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_28.size() - 1)
	return TABLE_1_28[safe_index]

const TABLE_1_29: Array[int] = [490, 491, 492, 493, 494]

## 모듈 1 테이블 29의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_1_29_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_29.size() - 1)
	return TABLE_1_29[safe_index]

const TABLE_1_30: Array[int] = [500, 501, 502, 503, 504, 505]

## 모듈 1 테이블 30의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_1_30_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_30.size() - 1)
	return TABLE_1_30[safe_index]

const TABLE_1_31: Array[int] = [510, 511, 512, 513, 514, 515, 516]

## 모듈 1 테이블 31의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_1_31_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_31.size() - 1)
	return TABLE_1_31[safe_index]

const TABLE_1_32: Array[int] = [520, 521, 522, 523, 524, 525, 526, 527]

## 모듈 1 테이블 32의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_1_32_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_32.size() - 1)
	return TABLE_1_32[safe_index]

const TABLE_1_33: Array[int] = [530, 531, 532, 533]

## 모듈 1 테이블 33의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_1_33_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_33.size() - 1)
	return TABLE_1_33[safe_index]

const TABLE_1_34: Array[int] = [540, 541, 542, 543, 544]

## 모듈 1 테이블 34의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_1_34_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_34.size() - 1)
	return TABLE_1_34[safe_index]

const TABLE_1_35: Array[int] = [550, 551, 552, 553, 554, 555]

## 모듈 1 테이블 35의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_1_35_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_35.size() - 1)
	return TABLE_1_35[safe_index]

const TABLE_1_36: Array[int] = [560, 561, 562, 563, 564, 565, 566]

## 모듈 1 테이블 36의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_1_36_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_36.size() - 1)
	return TABLE_1_36[safe_index]

const TABLE_1_37: Array[int] = [570, 571, 572, 573, 574, 575, 576, 577]

## 모듈 1 테이블 37의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_1_37_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_37.size() - 1)
	return TABLE_1_37[safe_index]

const TABLE_1_38: Array[int] = [580, 581, 582, 583]

## 모듈 1 테이블 38의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_1_38_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_38.size() - 1)
	return TABLE_1_38[safe_index]

const TABLE_1_39: Array[int] = [590, 591, 592, 593, 594]

## 모듈 1 테이블 39의 index번째 값을 돌려준다. index는 0..4 범위를 보정한다.
static func table_1_39_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_39.size() - 1)
	return TABLE_1_39[safe_index]

const TABLE_1_40: Array[int] = [600, 601, 602, 603, 604, 605]

## 모듈 1 테이블 40의 index번째 값을 돌려준다. index는 0..5 범위를 보정한다.
static func table_1_40_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_40.size() - 1)
	return TABLE_1_40[safe_index]

const TABLE_1_41: Array[int] = [610, 611, 612, 613, 614, 615, 616]

## 모듈 1 테이블 41의 index번째 값을 돌려준다. index는 0..6 범위를 보정한다.
static func table_1_41_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_41.size() - 1)
	return TABLE_1_41[safe_index]

const TABLE_1_42: Array[int] = [620, 621, 622, 623, 624, 625, 626, 627]

## 모듈 1 테이블 42의 index번째 값을 돌려준다. index는 0..7 범위를 보정한다.
static func table_1_42_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_42.size() - 1)
	return TABLE_1_42[safe_index]

const TABLE_1_43: Array[int] = [630, 631, 632, 633]

## 모듈 1 테이블 43의 index번째 값을 돌려준다. index는 0..3 범위를 보정한다.
static func table_1_43_value(index: int) -> int:
	var safe_index := clampi(index, 0, TABLE_1_43.size() - 1)
	return TABLE_1_43[safe_index]
