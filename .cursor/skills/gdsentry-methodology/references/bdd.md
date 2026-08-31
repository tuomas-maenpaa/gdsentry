# BDD phrasing → GDSentry asserts

Use Given / When / Then in names or comments; implement with `assert_*` and `run_test`.

```gdscript
extends SceneTreeTest

func _ready() -> void:
	test_description = "Player can open the inventory"
	test_tags = ["game", "inventory", "bdd"]
	test_category = "game"

func run_test_suite() -> void:
	run_test("given_closed_inventory_when_toggle_then_visible", func():
		return given_closed_inventory_when_toggle_then_visible())

func given_closed_inventory_when_toggle_then_visible() -> bool:
	var inv = _make_inventory()
	if not assert_false(inv.visible, "Given: inventory starts hidden"):
		return false
	inv.toggle()
	return assert_true(inv.visible, "Then: inventory is visible")
```

| BDD | GDSentry |
|-----|----------|
| Given | Setup + assert starting state |
| When | Action / signal / input |
| Then | `assert_eq`, `assert_true`, `assert_not_null`, … |
| And | Extra asserts or another `run_test` |

One behavior per `run_test`. Stop when scenario passes without weakening asserts.
