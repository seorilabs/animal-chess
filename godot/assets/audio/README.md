# 오디오 에셋 출처

- `bgm_title.ogg`, `bgm_prep.ogg`, `bgm_battle.ogg`, `sting_win.wav`, `sting_lose.wav`:
  Stability AI Stable Audio 2.5 생성 (`sound-manifest.json` + `game-sound-pipeline` 스킬).
  심리스 루프는 tail-to-head 크로스페이드 후 seam 수치를 검증했다.
  스팅어는 로컬 ffmpeg에 libvorbis가 없어 wav로 둔다. 둘 합쳐 700KB 수준이라 문제없다.
  `raw/` 원본은 112MB라 커밋하지 않는다. 재생성은 manifest 재실행으로 한다.
- `sfx/*.wav` 11종: `tools/generate_sfx.py` 절차적 합성. 외부 소재와 의존성이 없고
  스크립트를 다시 돌리면 언제나 같은 결과가 나온다.
- 라이선스: 전 트랙 자체 생성물로 서드파티 라이선스 없음.
