# GDSentry - Framework Path Resolver Tests
# Behavioral tests for core/framework_paths.gd
#
# Extends SceneTree (not SceneTreeTest) so it runs headless without global
# class_name / GDTestManager registration — required for fresh standalone
# project.godot materialization.
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTree

var _Paths: GDScript = null
var _failed: int = 0
var _passed: int = 0

func _init() -> void:
	print("🧭 FrameworkPathsTest starting")
	_Paths = _load_paths_module()
	if _Paths == null:
		push_error("Could not load framework_paths.gd")
		quit(1)
		return

	_run("test_setup_self_locate_succeeds", test_setup_self_locate_succeeds)
	_run("test_setup_with_valid_override", test_setup_with_valid_override)
	_run("test_setup_with_invalid_override_fails", test_setup_with_invalid_override_fails)
	_run("test_helpers_join_under_root", test_helpers_join_under_root)
	_run("test_unresolved_root_fails_hard", test_unresolved_root_fails_hard)
	_run("test_failed_setup_clears_stale_root", test_failed_setup_clears_stale_root)

	print("🧭 FrameworkPathsTest done: passed=%d failed=%d" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)

func _run(name: String, fn: Callable) -> void:
	print("🧪 ", name)
	_Paths.clear()
	if fn.call():
		_passed += 1
		print("   ✅ ", name)
	else:
		_failed += 1
		print("   ❌ ", name)

func _load_paths_module() -> GDScript:
	var self_path: String = get_script().resource_path
	if self_path.is_empty():
		return null
	# res://…/tests/core/this.gd -> up to tests/core -> tests -> framework root
	var framework_root: String = self_path.get_base_dir().get_base_dir().get_base_dir()
	return load(framework_root.path_join("core").path_join("framework_paths.gd"))

func _known_good_root() -> String:
	return get_script().resource_path.get_base_dir().get_base_dir().get_base_dir()

func _assert_true(cond: bool, msg: String) -> bool:
	if not cond:
		push_error("ASSERT: " + msg)
	return cond

func _assert_false(cond: bool, msg: String) -> bool:
	return _assert_true(not cond, msg)

func _assert_eq(a, b, msg: String) -> bool:
	if a != b:
		push_error("ASSERT: %s (got %s expected %s)" % [msg, str(a), str(b)])
		return false
	return true

func test_setup_self_locate_succeeds() -> bool:
	var success := true
	success = _assert_true(_Paths.setup(_Paths), "setup(self) should succeed") and success
	success = _assert_false(_Paths.root().is_empty(), "root should be set") and success
	success = _assert_true(_Paths.has_marker_at(_Paths.root()), "resolved root should contain marker") and success
	var gd_test_path: String = _Paths.base_class("gd_test.gd")
	success = _assert_true(
		ResourceLoader.exists(gd_test_path) or FileAccess.file_exists(gd_test_path),
		"base_class helper should resolve gd_test.gd"
	) and success
	return success

func test_setup_with_valid_override() -> bool:
	var success := true
	var good_root: String = _known_good_root()
	success = _assert_true(_Paths.setup_with_override(good_root), "valid override should succeed") and success
	var expected: String = good_root
	while expected.ends_with("/") and expected != "res://":
		expected = expected.left(expected.length() - 1)
	success = _assert_eq(_Paths.root(), expected, "root should match override") and success
	success = _assert_eq(_Paths.last_strategy(), "override", "strategy should be override") and success
	return success

func test_setup_with_invalid_override_fails() -> bool:
	var success := true
	success = _assert_true(_Paths.setup(_Paths), "precondition: self-locate works") and success
	success = _assert_false(
		_Paths.setup_with_override("res://this_path_does_not_exist_gdsentry"),
		"invalid override must fail"
	) and success
	success = _assert_true(_Paths.root().is_empty(), "root must be empty after failed override") and success
	return success

func test_helpers_join_under_root() -> bool:
	var success := true
	success = _assert_true(_Paths.setup(_Paths), "setup should succeed") and success
	var root: String = _Paths.root()
	var manager_path: String = _Paths.framework("core/test_manager.gd")
	success = _assert_true(manager_path.begins_with(root), "framework() join should sit under root") and success
	var examples_dir: String = _Paths.examples()
	success = _assert_true(examples_dir.begins_with(root), "examples() should sit under root") and success
	success = _assert_true(
		manager_path.ends_with("core/test_manager.gd") or manager_path.ends_with("core\\test_manager.gd"),
		"framework() should append relative path"
	) and success
	return success

func test_unresolved_root_fails_hard() -> bool:
	var success := true
	success = _assert_false(
		_Paths.setup_with_override("res://missing_framework_install"),
		"unresolved override must return false"
	) and success
	success = _assert_true(_Paths.root().is_empty(), "root must stay empty") and success
	success = _assert_false(
		_Paths.root() == "res://gdsentry" or _Paths.root() == "res://gdsentry/",
		"must not silently fall back to res://gdsentry"
	) and success
	return success

func test_failed_setup_clears_stale_root() -> bool:
	var success := true
	success = _assert_true(_Paths.setup(_Paths), "first setup should succeed") and success
	success = _assert_false(_Paths.root().is_empty(), "root should be set after success") and success
	var previous_root: String = _Paths.root()
	success = _assert_false(
		_Paths.setup_with_override("res://stale_root_clear_test_missing"),
		"second setup with bad override should fail"
	) and success
	success = _assert_true(_Paths.root().is_empty(), "failed setup must clear stale root") and success
	success = _assert_false(_Paths.root() == previous_root, "stale good root must not remain") and success
	return success
