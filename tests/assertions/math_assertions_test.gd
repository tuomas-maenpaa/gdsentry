# GDSentry - Math Assertions Tests
# Comprehensive testing of mathematical and numerical assertion functionality
#
# Tests math assertions including:
# - Floating point precision and tolerance validation
# - Vector and matrix comparisons with tolerance
# - Range and boundary validation
# - Statistical calculations and analysis
# - Geometric property validation
# - Numerical stability and finiteness checks
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name MathAssertionsTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Math assertions comprehensive validation"
	test_tags = ["assertions", "math", "numerical", "floating_point", "vector", "statistics"]
	test_priority = "high"
	test_category = "assertions"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all math assertions tests"""
	run_test("test_floating_point_assertions", func(): return test_floating_point_assertions())
	run_test("test_vector_assertions", func(): return test_vector_assertions())
	run_test("test_matrix_transform_assertions", func(): return test_matrix_transform_assertions())
	run_test("test_geometric_assertions", func(): return test_geometric_assertions())
	run_test("test_statistical_assertions", func(): return test_statistical_assertions())
	run_test("test_numerical_stability_assertions", func(): return test_numerical_stability_assertions())
	run_test("test_angle_rotation_assertions", func(): return test_angle_rotation_assertions())
	run_test("test_interpolation_assertions", func(): return test_interpolation_assertions())

# ------------------------------------------------------------------------------
# FLOATING POINT ASSERTIONS TESTS
# ------------------------------------------------------------------------------
func test_floating_point_assertions() -> bool:
	"""Test floating point assertions with tolerance handling"""
	var success := true

	# Test float equals with tolerance
	var value1 := 3.14159
	var value2 := 3.14160
	var value3 := 3.15

	success = success and MathAssertions.assert_float_equals(value1, value2, 0.001, "Values should be equal within tolerance")
	success = success and assert_false(MathAssertions.assert_float_equals(value1, value3, 0.001, "Values should not be equal within tolerance"), "Values should not be equal within tolerance")

	# Test float not equals
	success = success and MathAssertions.assert_float_not_equals(value1, value3, 0.001, "Values should not be equal within tolerance")
	success = success and assert_false(MathAssertions.assert_float_not_equals(value1, value2, 0.001, "Values should not be equal within tolerance"), "Values should not be equal within tolerance")

	# Test zero assertions
	var zero_value := 0.0001
	var non_zero_value := 0.5

	success = success and MathAssertions.assert_float_zero(zero_value, 0.001, "Value should be zero within tolerance")
	success = success and assert_false(MathAssertions.assert_float_zero(non_zero_value, 0.001, "Value should not be zero within tolerance"), "Value should not be zero within tolerance")

	# Test positive/negative assertions
	var positive_val := 5.5
	var negative_val := -3.2

	success = success and MathAssertions.assert_float_positive(positive_val, "Value should be positive")
	success = success and assert_false(MathAssertions.assert_float_positive(negative_val, "Value should not be positive"), "Value should not be positive")

	success = success and MathAssertions.assert_float_negative(negative_val, "Value should be negative")
	success = success and assert_false(MathAssertions.assert_float_negative(positive_val, "Value should not be negative"), "Value should not be negative")

	# Test range assertions
	var in_range_val := 7.5
	var out_range_val := 15.0

	success = success and MathAssertions.assert_float_in_range(in_range_val, 5.0, 10.0, "Value should be in range")
	success = success and assert_false(MathAssertions.assert_float_in_range(out_range_val, 5.0, 10.0, "Value should not be in range"), "Value should not be in range")

	return success

func test_vector_assertions() -> bool:
	"""Test vector assertions with tolerance handling"""
	var success := true

	# Test Vector2 equals
	var vec2_a := Vector2(1.5, 2.5)
	var vec2_b := Vector2(1.5001, 2.4999)
	var vec2_c := Vector2(2.0, 3.0)

	success = success and MathAssertions.assert_vector2_equals(vec2_a, vec2_b, 0.01, "Vectors should be equal within tolerance")
	success = success and assert_false(MathAssertions.assert_vector2_equals(vec2_a, vec2_c, 0.01, "Vectors should not be equal within tolerance"), "Vectors should not be equal within tolerance")

	# Test Vector3 equals
	var vec3_a := Vector3(1.5, 2.5, 3.5)
	var vec3_b := Vector3(1.5001, 2.4999, 3.5001)
	var vec3_c := Vector3(2.0, 3.0, 4.0)

	success = success and MathAssertions.assert_vector3_equals(vec3_a, vec3_b, 0.01, "3D Vectors should be equal within tolerance")
	success = success and assert_false(MathAssertions.assert_vector3_equals(vec3_a, vec3_c, 0.01, "3D Vectors should not be equal within tolerance"), "3D Vectors should not be equal within tolerance")

	# Test zero vectors
	var zero_vec2 := Vector2(0.001, -0.001)
	var non_zero_vec2 := Vector2(1.0, 0.5)

	success = success and MathAssertions.assert_vector2_zero(zero_vec2, 0.01, "Vector2 should be zero within tolerance")
	success = success and assert_false(MathAssertions.assert_vector2_zero(non_zero_vec2, 0.01, "Vector2 should not be zero within tolerance"), "Vector2 should not be zero within tolerance")

	# Test vector length
	var unit_vec := Vector2(0.707, 0.707)  # Approximately unit length
	var long_vec := Vector2(3.0, 4.0)  # Length = 5

	success = success and MathAssertions.assert_vector2_length(unit_vec, 1.0, 0.1, "Vector should have length ~1.0")
	success = success and MathAssertions.assert_vector2_length(long_vec, 5.0, 0.1, "Vector should have length 5.0")

	# Test normalized vectors
	var normalized_vec := Vector2(0.6, 0.8)  # Length = 1.0
	var non_normalized_vec := Vector2(2.0, 3.0)  # Length = 3.606

	success = success and MathAssertions.assert_vector2_normalized(normalized_vec, 0.01, "Vector should be normalized")
	success = success and assert_false(MathAssertions.assert_vector2_normalized(non_normalized_vec, 0.01, "Vector should not be normalized"), "Vector should not be normalized")

	return success

func test_matrix_transform_assertions() -> bool:
	"""Test matrix and transform assertions"""
	var success := true

	# Test Transform2D equals
	var transform_a := Transform2D(Vector2(1, 0), Vector2(0, 1), Vector2(10, 20))
	var transform_b := Transform2D(Vector2(1.0001, 0), Vector2(0, 0.9999), Vector2(10.0001, 20.0001))
	var transform_c := Transform2D(Vector2(1, 0), Vector2(0, 1), Vector2(50, 60))

	success = success and MathAssertions.assert_transform2d_equals(transform_a, transform_b, 0.01, "Transforms should be equal within tolerance")
	success = success and assert_false(MathAssertions.assert_transform2d_equals(transform_a, transform_c, 0.01, "Transforms should not be equal within tolerance"), "Transforms should not be equal within tolerance")

	# Test Transform3D equals
	var basis_a := Basis(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1))
	var transform3d_a := Transform3D(basis_a, Vector3(1, 2, 3))
	var transform3d_b := Transform3D(basis_a, Vector3(1.001, 2.001, 3.001))
	var transform3d_c := Transform3D(basis_a, Vector3(10, 20, 30))

	success = success and MathAssertions.assert_transform3d_equals(transform3d_a, transform3d_b, 0.01, "3D Transforms should be equal within tolerance")
	success = success and assert_false(MathAssertions.assert_transform3d_equals(transform3d_a, transform3d_c, 0.01, "3D Transforms should not be equal within tolerance"), "3D Transforms should not be equal within tolerance")

	return success

func test_geometric_assertions() -> bool:
	"""Test geometric assertions for points and rectangles"""
	var success := true

	# Test point in rectangle
	var rect := Rect2(10, 10, 100, 100)
	var point_inside := Vector2(50, 50)
	var point_outside := Vector2(150, 150)

	success = success and MathAssertions.assert_point_in_rect(point_inside, rect, "Point should be inside rectangle")
	success = success and assert_false(MathAssertions.assert_point_in_rect(point_outside, rect, "Point should not be inside rectangle"), "Point should not be inside rectangle")

	success = success and MathAssertions.assert_point_not_in_rect(point_outside, rect, "Point should be outside rectangle")
	success = success and assert_false(MathAssertions.assert_point_not_in_rect(point_inside, rect, "Point should not be outside rectangle"), "Point should not be outside rectangle")

	# Test rectangle equals
	var rect_a := Rect2(10, 20, 100, 200)
	var rect_b := Rect2(10.001, 19.999, 100.001, 200.001)
	var rect_c := Rect2(50, 60, 150, 250)

	success = success and MathAssertions.assert_rect_equals(rect_a, rect_b, 0.01, "Rectangles should be equal within tolerance")
	success = success and assert_false(MathAssertions.assert_rect_equals(rect_a, rect_c, 0.01, "Rectangles should not be equal within tolerance"), "Rectangles should not be equal within tolerance")

	# Test rectangle containment and intersection
	var small_rect := Rect2(20, 30, 50, 50)
	var large_rect := Rect2(0, 0, 200, 200)
	var separate_rect := Rect2(300, 300, 50, 50)

	success = success and MathAssertions.assert_rect_contains_rect(large_rect, small_rect, "Large rect should contain small rect")
	success = success and assert_false(MathAssertions.assert_rect_contains_rect(small_rect, large_rect, "Small rect should not contain large rect"), "Small rect should not contain large rect")

	success = success and MathAssertions.assert_rect_intersects_rect(large_rect, small_rect, "Rectangles should intersect")
	success = success and assert_false(MathAssertions.assert_rect_intersects_rect(large_rect, separate_rect, "Rectangles should not intersect"), "Rectangles should not intersect")

	return success

func test_statistical_assertions() -> bool:
	"""Test statistical calculation assertions"""
	var success := true

	# Test array mean
	var values := [1.0, 2.0, 3.0, 4.0, 5.0]
	var expected_mean := 3.0

	success = success and MathAssertions.assert_array_mean(values, expected_mean, 0.001, "Array mean should match expected value")

	# Test array variance (sample variance for n=5: values)
	# Values: 1,2,3,4,5; mean=3; variance = ((1-3)^2 + (2-3)^2 + (3-3)^2 + (4-3)^2 + (5-3)^2) / 4 = (4+1+0+1+4)/4 = 10/4 = 2.5
	var expected_variance := 2.5
	success = success and MathAssertions.assert_array_variance(values, expected_variance, 0.001, "Array variance should match expected value")

	# Test array standard deviation
	var expected_std_dev := sqrt(2.5)  # Approximately 1.581
	success = success and MathAssertions.assert_array_standard_deviation(values, expected_std_dev, 0.01, "Array standard deviation should match expected value")

	return success

func test_numerical_stability_assertions() -> bool:
	"""Test numerical stability and finiteness assertions"""
	var success := true

	# Test NaN assertions
	var finite_value := 5.5
	var nan_value := float("nan")
	var inf_value := INF

	success = success and MathAssertions.assert_no_nan(finite_value, "Finite value should not be NaN")
	if not is_nan(nan_value):  # Only test if NaN is detectable
		success = success and assert_false(MathAssertions.assert_no_nan(nan_value, "NaN value should be NaN"), "NaN value should be NaN")

	# Test infinity assertions
	success = success and MathAssertions.assert_no_inf(finite_value, "Finite value should not be infinite")
	if is_inf(inf_value):  # Only test if INF is detectable
		success = success and assert_false(MathAssertions.assert_no_inf(inf_value, "Infinite value should be infinite"), "Infinite value should be infinite")

	# Test finite assertions
	success = success and MathAssertions.assert_finite(finite_value, "Finite value should be finite")
	if is_inf(inf_value):  # Only test if INF is detectable
		success = success and assert_false(MathAssertions.assert_finite(inf_value, "Infinite value should not be finite"), "Infinite value should not be finite")

	# Test vector finiteness
	var finite_vec2 := Vector2(1.5, -2.5)
	var finite_vec3 := Vector3(1.0, 2.0, 3.0)

	success = success and MathAssertions.assert_vector2_finite(finite_vec2, "Vector2 should contain finite values")
	success = success and MathAssertions.assert_vector3_finite(finite_vec3, "Vector3 should contain finite values")

	return success

func test_angle_rotation_assertions() -> bool:
	"""Test angle and rotation assertions"""
	var success := true

	# Test angle equals with wrapping
	var angle1 := 1.5  # ~86 degrees
	var angle2 := 1.5001  # ~86.006 degrees
	var angle3 := 3.0  # ~172 degrees

	success = success and MathAssertions.assert_angle_equals(angle1, angle2, 0.01, "Angles should be equal within tolerance")
	success = success and assert_false(MathAssertions.assert_angle_equals(angle1, angle3, 0.01, "Angles should not be equal within tolerance"), "Angles should not be equal within tolerance")

	# Test angle wrapping (6.28 is ~2π, should equal 0)
	var full_circle := 6.283185307
	var zero_angle := 0.0
	success = success and MathAssertions.assert_angle_equals(full_circle, zero_angle, 0.01, "Full circle should equal zero angle")

	# Test angle in range
	var angle_in_range := 2.0  # ~115 degrees
	var angle_out_range := 5.0  # ~286 degrees

	success = success and MathAssertions.assert_angle_in_range(angle_in_range, 1.0, 3.0, "Angle should be in range")
	success = success and assert_false(MathAssertions.assert_angle_in_range(angle_out_range, 1.0, 3.0, "Angle should not be in range"), "Angle should not be in range")

	return success

func test_interpolation_assertions() -> bool:
	"""Test interpolation and LERP assertions"""
	var success := true

	# Test LERP correctness
	var start := 10.0
	var end := 20.0
	var t := 0.5
	var expected_lerp := 15.0

	success = success and MathAssertions.assert_lerp_correct(start, end, t, expected_lerp, 0.001, "LERP result should match expected value")

	# Test Vector2 LERP
	var vec2_start := Vector2(10, 20)
	var vec2_end := Vector2(30, 40)
	var vec2_t := 0.25
	var vec2_expected := Vector2(15, 25)

	success = success and MathAssertions.assert_vector2_lerp_correct(vec2_start, vec2_end, vec2_t, vec2_expected, 0.001, "Vector2 LERP should match expected result")

	# Test Vector3 LERP
	var vec3_start := Vector3(10, 20, 30)
	var vec3_end := Vector3(20, 40, 60)
	var vec3_t := 0.75
	var vec3_expected := Vector3(17.5, 35, 52.5)

	success = success and MathAssertions.assert_vector3_lerp_correct(vec3_start, vec3_end, vec3_t, vec3_expected, 0.001, "Vector3 LERP should match expected result")

	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_test_vector2() -> Vector2:
	"""Create a test Vector2 for testing"""
	return Vector2(3.5, -7.2)

func create_test_vector3() -> Vector3:
	"""Create a test Vector3 for testing"""
	return Vector3(1.5, 2.7, -4.1)

func create_test_float_array(size: int) -> Array:
	"""Create an array of test float values"""
	var result := []
	for i in range(size):
		result.append(float(i) * 1.5 + 0.5)
	return result

func create_normalized_vector2() -> Vector2:
	"""Create a normalized Vector2"""
	var vec := Vector2(3.0, 4.0)
	return vec.normalized()

func create_test_rect2() -> Rect2:
	"""Create a test Rect2 for testing"""
	return Rect2(10, 20, 100, 150)

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
