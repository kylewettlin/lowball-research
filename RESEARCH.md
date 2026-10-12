# Lowball: Technology Research Milestone

Individual research for **Lowball** (PixelKarma), a single-player, top-down pawn shop management game. This folder holds my notes and a small Godot 4.3 sample app that prototypes the game's core loop.

---

## 1. Platforms

| Platform | Fit for Lowball | Notes / limitations |
|---|---|---|
| **Windows / macOS / Linux desktop** | **Primary target** | Mouse and keyboard suit menus, haggling and inventory. Distribute on itch.io (free, easy) or Steam (about $100 fee per app). macOS builds need signing/notarization to avoid Gatekeeper warnings. |
| **Web (HTML5)** | Good for demos and playtests | Godot 4 web export works for GDScript projects. C# projects can't export to web (as of 4.3). Threaded builds need cross-origin isolation headers; 4.3 added a single-threaded web export that avoids this, which itch.io handles fine. |
| Mobile (Android/iOS) | Not planned | Would need a touch UI redesign. iOS export requires a Mac and Xcode. |
| Console | Out of scope | Needs publisher/devkit access and a third-party porting service for Godot. |

**Decision:** desktop first, with a web build for easy playtesting and grading.

## 2. Engines considered

| Engine | Pros | Cons | Verdict |
|---|---|---|---|
| **Godot 4** | Free and MIT-licensed with no royalties. Small download (~100 MB, no installer). Good 2D tools (pixel-perfect, TileMap, Control UI). GDScript is quick to learn. Scenes are text files, which makes Git diffs and merges easier. | Smaller asset ecosystem than Unity. C# can't target web. Docs sometimes mix Godot 3 and 4 answers. | **Chosen.** |
| Unity 6 | Huge ecosystem and tutorials. C#. Good tooling. | Heavy install. The 2023 runtime-fee controversy (fee later cancelled) hurt trust. Scene/prefab merges are painful. 2D is fine but feels bolted on. | Strong runner-up |
| GameMaker | Very good for 2D, quick prototyping. | Proprietary GML. Paid license for commercial export. UI-heavy games (inventory, menus) are clunky. | No |
| Unreal Engine 5 | AAA 3D, Blueprints. | Overkill for 2D. Huge install, slow iteration. 2D (Paper2D) is barely maintained. | No |
| Phaser / web frameworks | Runs anywhere in a browser. | We'd have to build scene editing, UI layout and physics tooling ourselves. | No |

### Language: GDScript vs C# (inside Godot)
- **GDScript:** Python-like syntax, tight editor integration, hot reload, and web export works. Optional static typing (`var x: int`, `Array[Item]`) catches many bugs.
- **C#:** familiar to anyone who knows Java/C#, and faster for heavy computation. Needs the separate .NET build of Godot and the .NET SDK, and it can't export to web.
- **Decision:** GDScript. Lowball isn't CPU-heavy, and web export matters for playtesting.

## 3. Libraries / add-ons worth knowing

| Need (from Requirements) | Option | Notes |
|---|---|---|
| Customer dialogue (5.2, 9.x) | **Dialogic 2** (add-on) | Visual dialogue/timeline editor. Probably overkill until customers have real conversations; plain `Label` + data works for now (see the prototype). |
| Unit tests | **GUT** (Godot Unit Test) or **gdUnit4** | Lets us test negotiation and pricing math without clicking through the game. Both can run headless in CI (GitHub Actions). |
| Save / load (1.5, 1.7) | Built-in `FileAccess` + `JSON`, `ConfigFile`, or custom `Resource` + `ResourceSaver` | No add-on needed. Use `ConfigFile` for the settings menu (1.6) and JSON or Resources for save slots. |
| Pixel art pipeline | **Aseprite** (or free LibreSprite) + **Aseprite Wizard** add-on | Imports `.aseprite` animations straight into `AnimatedSprite2D`. |
| Shop layout / tiles | Built-in `TileMapLayer` (4.3) | No add-on needed. |
| Item/customer data | Custom `Resource` classes (`.tres`) | Designers can edit items in the Inspector instead of code. A good upgrade from the hard-coded dictionaries in the prototype. |

## 4. Package manager

Godot has **no npm/pip-style CLI package manager**. Options:

1. **Asset Library (built in):** in the editor, open the **AssetLib** tab, search, then **Download** and **Install**. Files go to `res://addons/<name>/`. Turn plugins on in **Project → Project Settings → Plugins**.
2. **Version pinning:** since there's no lockfile, **commit `addons/` to Git** so every teammate has the same version. Update deliberately in one PR.
3. **gd-plug** (community add-on): a `plug.gd` manifest that installs add-ons from Git URLs, the closest thing to a real package manager.
4. **C# only:** NuGet through `dotnet add package`, the same as any .NET project.

Version control setup (already in this project): `.gitignore` excludes `.godot/` (the import cache, which regenerates), and `.gitattributes` normalizes line endings.

## 5. Sample app: what I built

A playable slice of the core loop, kept deliberately small. Placeholder art is drawn in code.

| Requirement | Status in prototype |
|---|---|
| 1.1 Main menu | ✅ Start New Game / Quit |
| 1.2 Begin a work day | ✅ Loads the shop, N customers per day |
| 1.3 Pause | ✅ Esc: Resume / Quit to menu (tree actually pauses) |
| 1.4 End-of-day summary | ✅ Customers, bought/sold totals, net cash. No upgrade screen yet. |
| 2.1 / 2.2 Move and interact | ✅ WASD/arrows, `[E]` prompts near desk, display case, back room, exit |
| 2.3 Serve customers | ✅ Customers are random sellers or buyers |
| 2.5 / 7.3 Display case and sales | ✅ Only displayed items can be bought by customers |
| 3.1 Items | ✅ Name, category, condition, defects, estimated vs. hidden actual value |
| 3.2 / 3.3 / 3.4 Acquire, view, update | ✅ Back-room inventory list and detail. Values update after repair. |
| 4.1 Inspect | ✅ Partial: the negotiation screen shows condition, defects and estimates (no images or hover yet) |
| 5.1 to 5.4 Negotiation | ✅ Offer / counter / reject / walk out, dialogue hints about hidden value, final confirm step |
| 6.1 / 6.3 Restore items | ✅ Minimal: "Clean / Repair" fixes one defect (+20 condition). No tool minigame. |
| 7.1 / 7.2 / 7.4 Economy | ✅ Cash tracking, condition-based pricing, unaffordable purchases blocked with a message |

### Project layout
```
project.godot            # settings, input map, GameState autoload, main scene
scenes/
  main_menu.tscn
  shop.tscn              # world + HUD + negotiation/inventory panels + pause menu
  end_of_day.tscn
scripts/
  game_state.gd          # autoload singleton: money, day, inventory, daily stats, item generator
  item.gd                # class_name Item: value/condition model
  customer.gd            # class_name Customer: haggling AI
  player.gd              # CharacterBody2D top-down movement
  interactable.gd        # reusable Area2D "press E here" object
  shop.gd                # wires interactions to panels
  negotiation_panel.gd
  inventory_panel.gd
  pause_menu.gd
  end_of_day.gd
  main_menu.gd
```

### How to run
1. Open `Godot_v4.3-stable_win64.exe`, choose **Import**, and select this folder's `project.godot`.
2. Press **F5** (Run Project).
3. Or from a terminal: `Godot_v4.3-stable_win64.exe --path <this folder>`.

### Godot concepts this exercised
- **Scenes and nodes:** every screen is a scene. `get_tree().change_scene_to_file()` switches between them.
- **Autoload singletons:** `GameState` keeps money and inventory alive across scene changes.
- **`class_name`:** global types (`Item`, `Customer`, `Interactable`) with static typing.
- **Signals:** panels emit `closed`, and `Area2D.body_entered` drives the interaction prompts (connected with `.bind()`).
- **Physics:** `CharacterBody2D.move_and_slide()` against `StaticBody2D` walls and desk. Collision shapes can be built in code.
- **UI:** Containers (`CenterContainer`, `VBoxContainer`, `HBoxContainer`), `ItemList`, `SpinBox`, `StyleBoxFlat` theme overrides, and `%UniqueName` node access.
- **Input map:** named actions (`move_up`, `interact`, `pause`) instead of hard-coded keys.
- **Pausing:** `get_tree().paused` plus `process_mode = Always` on the pause menu so it still receives input.
- **Headless runs:** `Godot_console.exe --headless --path . --import` validates the project. `-s script.gd` runs an automated smoke test with no window.

### Gotchas I hit
- **The editor overwrites `project.godot`.** If you hand-edit it while the editor has the project open, the editor saves over your changes. Change settings in the editor, or close the editor first.
- **Typed arrays are strict.** `inventory.filter(...)` returns an untyped `Array`, and returning it from a function declared `-> Array[Item]` is a runtime error. Build the typed array in a loop instead.
- **`SpinBox` text isn't committed until Enter or focus loss.** Call `spin_box.apply()` before reading `.value`.
- **The pause menu must be `process_mode = Always`.** Otherwise it pauses itself and can never un-pause.
- **`.godot/` is cache only.** Never commit it. Teammates regenerate it on first open.

## 6. Recommendation for the team

**Godot 4.x + GDScript**, desktop first with a web build for playtests. Use Git with `addons/` committed. Adopt **GUT** early so pricing and negotiation logic is unit-tested. Move item and customer definitions into custom `Resource` files once art exists. Only add **Dialogic** if customer conversations grow past one-liners.

Next things to learn before team coding: TileMapLayer for the real shop layout, AnimatedSprite2D with Aseprite imports, `Resource`-based data, saving with `FileAccess`/JSON, and running GUT in GitHub Actions.
