#!/usr/bin/env python3
"""절차적 SFX 생성기 (jsfxr 계열 방식, 외부 의존성 없음).

효과음 10종을 결정적으로 합성해 godot/assets/audio/sfx/에
16-bit 22.05kHz mono wav로 쓴다. 샘플 소재를 쓰지 않으므로 라이선스 부담이 없고,
이 스크립트를 다시 돌리면 언제나 같은 결과가 나온다.
BGM과 스팅어는 Stable Audio 파이프라인(sound-manifest.json)이 담당한다.
"""
import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 22050
OUT_DIR = Path(__file__).resolve().parents[1] / "godot" / "assets" / "audio" / "sfx"


def noise(i):
    """결정적 의사 난수 노이즈. random 모듈을 쓰지 않아 재생성이 항상 동일하다."""
    x = (i * 1664525 + 1013904223) & 0xFFFFFFFF
    x ^= x >> 16
    x = (x * 2246822519) & 0xFFFFFFFF
    x ^= x >> 13
    return (x / 0x7FFFFFFF) - 1.0


def render(duration, sample_fn):
    total = int(SAMPLE_RATE * duration)
    frames = bytearray()
    for i in range(total):
        t = i / SAMPLE_RATE
        value = max(-1.0, min(1.0, sample_fn(t, i)))
        # 마지막 3ms는 페이드아웃해 딸깍 소리를 막는다.
        tail = min(1.0, (duration - t) / 0.003)
        frames += struct.pack("<h", int(value * tail * 32767 * 0.82))
    return bytes(frames)


def write_wav(name, data):
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    path = OUT_DIR / f"{name}.wav"
    with wave.open(str(path), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SAMPLE_RATE)
        f.writeframes(data)
    print(f"[sfx] {path.name}")


def sine(freq, t):
    return math.sin(math.tau * freq * t)


def pluck(t, freq, decay, partial=3.0, partial_gain=0.3):
    """짧게 튕기는 음. 기본음 + 부분음이 더 빨리 죽는다."""
    env = math.exp(-t * decay)
    return sine(freq, t) * env + partial_gain * sine(freq * partial, t) * math.exp(-t * decay * 2.6)


# --- UI ---------------------------------------------------------------

def tap(t, _i):
    return 0.5 * pluck(t, 880.0, 46.0)


def denied(t, _i):
    tone = sine(150.0, t) + 0.5 * sine(101.0, t)
    return 0.6 * tone * math.exp(-t * 20.0)


def buy(t, _i):
    """동전 두 번 튕기는 소리."""
    first = pluck(t, 988.0, 30.0)
    second = pluck(max(0.0, t - 0.055), 1319.0, 30.0) if t > 0.055 else 0.0
    return 0.55 * (first + second)


def place(t, i):
    """보드에 내려놓는 소리. 낮은 둔탁함 + 짧은 클릭."""
    thud = 0.7 * sine(190.0 - 60.0 * min(1.0, t / 0.08), t) * math.exp(-t * 26.0)
    click = 0.25 * noise(i) * math.exp(-t * 190.0)
    return thud + click


def reroll(t, i):
    """카드를 훑는 느낌의 상승 노이즈."""
    sweep = 0.45 * noise(i) * math.exp(-t * 9.0)
    body = 0.3 * sine(300.0 + 900.0 * min(1.0, t / 0.25), t) * math.exp(-t * 8.0)
    return sweep + body


def merge(t, _i):
    """합성 성공. 네 음이 차례로 올라간다."""
    steps = [(0.00, 523.25), (0.07, 659.25), (0.14, 784.0), (0.21, 1046.5)]
    total = 0.0
    for start, freq in steps:
        if t >= start:
            total += pluck(t - start, freq, 12.0)
    return 0.42 * total


# --- 전투 -------------------------------------------------------------

def attack(t, i):
    """근접 타격. 노이즈 임팩트 + 낮은 몸통."""
    impact = 0.8 * noise(i) * math.exp(-t * 90.0)
    body = 0.55 * sine(140.0, t) * math.exp(-t * 42.0)
    return impact + body


def arrow(t, i):
    """원거리 타격. 아래로 떨어지는 바람 소리."""
    swish = 0.5 * noise(i) * math.exp(-t * 30.0)
    tone = 0.45 * sine(1500.0 - 1100.0 * min(1.0, t / 0.12), t) * math.exp(-t * 26.0)
    return swish + tone


def skill(t, _i):
    """스킬 발동. 비브라토가 실린 상승음."""
    progress = min(1.0, t / 0.32)
    freq = 420.0 + 700.0 * progress + 14.0 * math.sin(math.tau * 11.0 * t)
    env = math.exp(-t * 5.5) * (1.0 - math.exp(-t * 80.0))
    return 0.5 * (sine(freq, t) + 0.35 * sine(freq * 2.0, t)) * env


def death(t, _i):
    """쓰러짐. 아래로 미끄러지는 음."""
    freq = 400.0 * math.exp(-t * 5.0) + 60.0
    return 0.55 * (sine(freq, t) + 0.3 * sine(freq * 1.5, t)) * math.exp(-t * 6.0)


def levelup(t, _i):
    """라운드 진행/보상. 밝은 3화음."""
    total = pluck(t, 523.25, 8.0) + pluck(t, 659.25, 8.0) + pluck(t, 784.0, 8.0)
    return 0.32 * total


SOUNDS = [
    ("sfx_tap", 0.10, tap),
    ("sfx_denied", 0.22, denied),
    ("sfx_buy", 0.26, buy),
    ("sfx_place", 0.20, place),
    ("sfx_reroll", 0.34, reroll),
    ("sfx_merge", 0.55, merge),
    ("sfx_attack", 0.14, attack),
    ("sfx_arrow", 0.18, arrow),
    ("sfx_skill", 0.60, skill),
    ("sfx_death", 0.45, death),
    ("sfx_levelup", 0.70, levelup),
]


def main():
    for name, duration, fn in SOUNDS:
        write_wav(name, render(duration, fn))
    print(f"{len(SOUNDS)}개 생성 완료: {OUT_DIR}")


if __name__ == "__main__":
    main()
