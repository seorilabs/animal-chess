# Animal Chess

Pixel-style animal auto battler built with Godot.

## Current Slice

- 8x8 configurable board
- 8 starter units: Turtle, Rabbit, Sparrow, Frog, Fox, Wolf, Penguin, Bear
- Korean in-game UI and Korean unit/habitat/role labels
- Round-based owned/deployed unit caps so early turns stay simple
- Shop, bench, placement, reroll, and rewarded-ad mock
- AI waves match the player's deployed unit count in the current round
- Round wrap-up panel after combat with result, remaining units, reward/damage, and next caps
- Selected-unit detail panel for stats, role, skill, and tactical trait
- AI wave opponent
- Automatic tick-based combat
- Procedural 48x48 pixel-style unit drawings for early readability testing

## Run

```bash
godot --path godot
```

## Smoke Test

```bash
godot --headless --path godot --quit
godot --headless --path godot --scene res://scenes/Main.tscn --quit-after 1
godot --headless --path godot --script res://scripts/smoke_test.gd
```

## Planning Source

The approved planning note is in Obsidian:

```text
프로젝트/animal-chess/01 기획서.md
```
