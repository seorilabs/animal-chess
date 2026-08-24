# 픽셀 동물전장 아트 스타일 가이드

기획서 §23(서식지 색), §25(대표 기물 시각 설계), §26(픽셀 아트 규격)에서 온 규칙이다.
모든 에셋은 이 문서와 `anchor.png`를 기준으로 생성한다. 둘 중 하나를 바꾸면 전체를 다시 만든다.

## 프롬프트용 스타일 문장

High-resolution pixel art game sprite in a chunky 48x48 pixel grid style, clean
readable blocky pixels with no anti-aliasing and no dithering noise. Cute stylized
animal character seen from a 3/4 top-down angle, standing upright and facing the
viewer. Bold 1-pixel dark outline in near-black desaturated brown (#1B1D1D) around
the entire silhouette. Flat cel shading with exactly one darker shade per base color,
light source from the upper left. Body uses 4 to 6 flat colors only, plus at most 2
accent colors for the animal's signature feature. Chunky solid silhouette with a
large head and short body, big readable eyes with a single white highlight pixel.
Centered single character, isolated on a flat pure white (#FFFFFF) background, no
ground shadow, no text, no border, no frame, no UI elements.

## 팔레트

배경과 UI는 숲 톤을 기준으로 한다. 기물 본체 색은 동물 식별성이 우선이고,
서식지 색은 이펙트와 포인트에만 쓴다.

| 용도 | Hex | 메모 |
| --- | --- | --- |
| 외곽선 | `#1B1D1D` | 모든 기물 공통 1px 외곽선 |
| 배경 심연 | `#0E1714` | 앱 배경 |
| 보드 아군 칸 | `#2A3F30` / `#243727` | 체커 두 톤 |
| 보드 적 칸 | `#372E32` / `#302730` | 체커 두 톤 |
| 강조 초록 | `#2F7D4B` | 기획서 대표 색 |
| 강조 금색 | `#F4D35E` | 별, 골드, 발동한 시너지 |
| 위험 빨강 | `#E5615B` | 적 팀, 체력 경고 |
| 본문 텍스트 | `#EDE7D6` | |

## 서식지 포인트 색

기물 본체를 서식지 색으로 덮지 않는다. 이펙트, 장식, 눈 색에만 쓴다.

| 서식지 | Hex | 시각 포인트 |
| --- | --- | --- |
| 숲 | `#4E8C46` | 나뭇잎 장식, 둥근 귀 |
| 초원 | `#C8A64B` | 갈기, 털결, 바람선 |
| 늪 | `#3E7F72` | 물방울, 진흙, 독 거품 |
| 극지 | `#7CC7DC` | 얼음 결정, 하얀 테두리 |
| 하늘 | `#6F9FD8` | 날개, 깃털, 바람 궤적 |

## 규격

| 항목 | 값 |
| --- | --- |
| 논리 캔버스 | 48x48 픽셀 그리드 |
| 내보내기 크기 | 96x96 (뷰포트 768 기준 한 칸 96px에 1:1) |
| 몸체 점유 | 캔버스의 약 70~85%. 귀, 날개, 꼬리는 끝까지 사용 가능 |
| 방향 | 3/4 top-down, 정면을 향해 서 있음 |
| 팀 구분 | 좌우 반전이 아니라 발밑 팀 링과 체력바로 구분 |
| 등급 표현 | 별 아이콘. 등급마다 본체를 새로 그리지 않음 |
| 애니메이션 | 프레임 스프라이트가 아니라 코드 트윈으로 처리 |

## 하지 않는 것

- 이미지에 텍스트를 굽지 않는다. 한글은 엔진 폰트로만 렌더한다.
- 스프라이트에 바닥 그림자를 그리지 않는다. 엔진이 그린다.
- 프레임 애니메이션 시트를 만들지 않는다. 프레임 간 일관성이 확보되지 않는다.
- 희귀도 색으로 기물 본체를 덮지 않는다. 상점 카드 UI에서만 표현한다.
