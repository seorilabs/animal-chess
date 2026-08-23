# Animal Chess

Pixel-style animal auto battler built with Godot.

## Current Slice

- 8x8 configurable board
- 8 starter units: Turtle, Rabbit, Sparrow, Frog, Fox, Wolf, Penguin, Bear
- Korean in-game UI with a bundled Korean font
- Round-based owned/deployed unit caps so early turns stay simple
- Shop, bench, placement, reroll, and rewarded-ad mock
- AI waves match the player's deployed unit count in the current round
- Round wrap-up panel after combat with result, remaining units, reward/damage, and next caps
- Selected-unit detail panel for stats, role, skill, and tactical trait
- Automatic tick-based combat with mana-charged skills
- Generated pixel-art sprites, BGM, and procedurally synthesized SFX

## Regenerating Assets

Art (Gemini) and music (Stable Audio) are manifest-driven; sound effects are
synthesized locally with no external dependency.

```bash
python3 tools/generate_sfx.py
```

Art and music regeneration go through the `game-asset-pipeline` and
`game-sound-pipeline` skills using `godot/assets/art/asset-manifest.json` and
`godot/assets/audio/sound-manifest.json`.

## Run

```bash
godot --path godot
```

## Tests

All test cases run through one scene. A failure exits with code 1.

```bash
godot --headless --path godot --scene res://tests/test_runner.tscn
```

The full gate (import pass, compile check, log inspection, then the tests):

```bash
~/.claude/skills/godot-game/scripts/godot_quality_gate.sh --project godot \
  --smoke-scene res://tests/test_runner.tscn
```

## Visual QA

Renders the game offscreen at the 768x1366 design resolution and writes a PNG to
`user://shots/`. Needs a rendering context, so it does not run headless.

```bash
godot --path godot --scene res://tests/screenshot_scene.tscn -- --shot prep
```

## Planning Source

The approved planning note is in Obsidian:

```text
프로젝트/개인/animal-chess/01 기획서.md
```
