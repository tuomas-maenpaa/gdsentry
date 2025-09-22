# GDSentry - Math Assertions
# Specialized assertions for numerical and mathematical validation
#
# Features:
# - Floating point precision handling
# - Vector and matrix comparisons
# - Range and boundary validation
# - Statistical calculations
# - Geometric property validation
# - Numerical stability testing
#
# Author: GDSentry Framework
# Version: 1.0.0

extends GDTest

class_name MathAssertions

# ------------------------------------------------------------------------------
# FLOATING POINT ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_float_equals(actual: float, expected: float, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that two floats are equal within tolerance"""
	var diff = abs(actual - expected)
	if diff <= tolerance:
		return true

	var error_msg = message if not message.is_empty() else "Float mismatch: expected " + str(expected) + ", got " + str(actual) + " (diff: " + str(diff) + ", tolerance: " + str(tolerance) + ")"
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_float_not_equals(actual: float, expected: float, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that two floats are not equal within tolerance"""
	var diff = abs(actual - expected)
	if diff > tolerance:
		return true

	var error_msg = message if not message.is_empty() else "Floats are equal within tolerance: " + str(actual) + " ≈ " + str(expected) + " (diff: " + str(diff) + " <= " + str(tolerance) + ")"
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_float_zero(value: float, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that float value is zero within tolerance"""
	return assert_float_equals(value, 0.0, tolerance, message if not message.is_empty() else "Value is not zero: " + str(value))

static func assert_float_positive(value: float, message: String = "") -> bool:
	"""Assert that float value is positive"""
	if value > 0:
		return true

	var error_msg = message if not message.is_empty() else "Value is not positive: " + str(value)
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_float_negative(value: float, message: String = "") -> bool:
	"""Assert that float value is negative"""
	if value < 0:
		return true

	var error_msg = message if not message.is_empty() else "Value is not negative: " + str(value)
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_float_in_range(value: float, min_val: float, max_val: float, message: String = "") -> bool:
	"""Assert that float value is within specified range"""
	if value >= min_val and value <= max_val:
		return true

	var error_msg = message if not message.is_empty() else "Value " + str(value) + " not in range [" + str(min_val) + ", " + str(max_val) + "]"
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

# ------------------------------------------------------------------------------
# VECTOR ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_vector2_equals(actual: Vector2, expected: Vector2, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that two Vector2 are equal within tolerance"""
	var diff = (actual - expected).length()
	if diff <= tolerance:
		return true

	var error_msg = message if not message.is_empty() else "Vector2 mismatch: expected " + str(expected) + ", got " + str(actual) + " (diff: " + str(diff) + ")"
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_vector3_equals(actual: Vector3, expected: Vector3, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that two Vector3 are equal within tolerance"""
	var diff = (actual - expected).length()
	if diff <= tolerance:
		return true

	var error_msg = message if not message.is_empty() else "Vector3 mismatch: expected " + str(expected) + ", got " + str(actual) + " (diff: " + str(diff) + ")"
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_vector2_zero(vector: Vector2, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that Vector2 is zero within tolerance"""
	return assert_vector2_equals(vector, Vector2.ZERO, tolerance, message if not message.is_empty() else "Vector2 is not zero: " + str(vector))

static func assert_vector3_zero(vector: Vector3, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that Vector3 is zero within tolerance"""
	return assert_vector3_equals(vector, Vector3.ZERO, tolerance, message if not message.is_empty() else "Vector3 is not zero: " + str(vector))

static func assert_vector2_length(vector: Vector2, expected_length: float, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that Vector2 has expected length"""
	var actual_length = vector.length()
	return assert_float_equals(actual_length, expected_length, tolerance, message if not message.is_empty() else "Vector2 length mismatch")

static func assert_vector3_length(vector: Vector3, expected_length: float, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that Vector3 has expected length"""
	var actual_length = vector.length()
	return assert_float_equals(actual_length, expected_length, tolerance, message if not message.is_empty() else "Vector3 length mismatch")

static func assert_vector2_normalized(vector: Vector2, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that Vector2 is normalized (length = 1.0)"""
	return assert_vector2_length(vector, 1.0, tolerance, message if not message.is_empty() else "Vector2 is not normalized")

static func assert_vector3_normalized(vector: Vector3, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that Vector3 is normalized (length = 1.0)"""
	return assert_vector3_length(vector, 1.0, tolerance, message if not message.is_empty() else "Vector3 is not normalized")

# ------------------------------------------------------------------------------
# MATRIX AND TRANSFORM ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_transform2d_equals(actual: Transform2D, expected: Transform2D, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that two Transform2D are equal within tolerance"""
	# Compare all matrix elements
	for i in range(3):
		for j in range(2):
			var actual_val = actual[i][j]
			var expected_val = expected[i][j]
			if abs(actual_val - expected_val) > tolerance:
				var error_msg = message if not message.is_empty() else "Transform2D mismatch at [" + str(i) + "][" + str(j) + "]: expected " + str(expected_val) + ", got " + str(actual_val)
				GDTestManager.log_test_failure("MathAssertions", error_msg)
				return false

	return true

static func assert_transform3d_equals(actual: Transform3D, expected: Transform3D, tolerance: float = 0.0001, _message: String = "") -> bool:
	"""Assert that two Transform3D are equal within tolerance"""
	# Compare basis vectors and origin
	if not assert_vector3_equals(actual.origin, expected.origin, tolerance, "Transform3D origin mismatch"):
		return false

	for i in range(3):
		if not assert_vector3_equals(actual.basis[i], expected.basis[i], tolerance, "Transform3D basis[" + str(i) + "] mismatch"):
			return false

	return true

# ------------------------------------------------------------------------------
# GEOMETRIC ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_point_in_rect(point: Vector2, rect: Rect2, message: String = "") -> bool:
	"""Assert that point is inside rectangle"""
	if rect.has_point(point):
		return true

	var error_msg = message if not message.is_empty() else "Point " + str(point) + " not in rectangle " + str(rect)
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_point_not_in_rect(point: Vector2, rect: Rect2, message: String = "") -> bool:
	"""Assert that point is outside rectangle"""
	if not rect.has_point(point):
		return true

	var error_msg = message if not message.is_empty() else "Point " + str(point) + " is in rectangle " + str(rect)
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_rect_equals(actual: Rect2, expected: Rect2, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that two rectangles are equal within tolerance"""
	if assert_vector2_equals(actual.position, expected.position, tolerance, "Rect position mismatch") and \
	   assert_vector2_equals(actual.size, expected.size, tolerance, "Rect size mismatch"):
		return true

	var error_msg = message if not message.is_empty() else "Rect mismatch: expected " + str(expected) + ", got " + str(actual)
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_rect_contains_rect(outer: Rect2, inner: Rect2, message: String = "") -> bool:
	"""Assert that outer rectangle completely contains inner rectangle"""
	if outer.encloses(inner):
		return true

	var error_msg = message if not message.is_empty() else "Rectangle " + str(outer) + " does not contain " + str(inner)
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_rect_intersects_rect(rect1: Rect2, rect2: Rect2, message: String = "") -> bool:
	"""Assert that two rectangles intersect"""
	if rect1.intersects(rect2):
		return true

	var error_msg = message if not message.is_empty() else "Rectangles do not intersect: " + str(rect1) + " and " + str(rect2)
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

# ------------------------------------------------------------------------------
# STATISTICAL ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_array_mean(array: Array, expected_mean: float, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that array has expected mean value"""
	if array.is_empty():
		var error_msg = message if not message.is_empty() else "Cannot calculate mean of empty array"
		GDTestManager.log_test_failure("MathAssertions", error_msg)
		return false

	var sum = 0.0
	for value in array:
		sum += value

	var mean = sum / array.size()
	return assert_float_equals(mean, expected_mean, tolerance, message if not message.is_empty() else "Array mean mismatch")

static func assert_array_variance(array: Array, expected_variance: float, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that array has expected variance"""
	if array.size() < 2:
		var error_msg = message if not message.is_empty() else "Need at least 2 values for variance calculation"
		GDTestManager.log_test_failure("MathAssertions", error_msg)
		return false

	# Calculate mean
	var sum = 0.0
	for value in array:
		sum += value
	var mean = sum / array.size()

	# Calculate variance
	var variance_sum = 0.0
	for value in array:
		variance_sum += pow(value - mean, 2)
	var variance = variance_sum / (array.size() - 1)  # Sample variance

	return assert_float_equals(variance, expected_variance, tolerance, message if not message.is_empty() else "Array variance mismatch")

static func assert_array_standard_deviation(array: Array, expected_std_dev: float, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that array has expected standard deviation"""
	if array.size() < 2:
		var error_msg = message if not message.is_empty() else "Need at least 2 values for standard deviation calculation"
		GDTestManager.log_test_failure("MathAssertions", error_msg)
		return false

	var variance = 0.0
	var mean = 0.0

	# Calculate mean
	for value in array:
		mean += value
	mean /= array.size()

	# Calculate variance
	for value in array:
		variance += pow(value - mean, 2)
	variance /= (array.size() - 1)  # Sample variance

	var std_dev = sqrt(variance)
	return assert_float_equals(std_dev, expected_std_dev, tolerance, message if not message.is_empty() else "Array standard deviation mismatch")

# ------------------------------------------------------------------------------
# NUMERICAL STABILITY ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_no_nan(value: float, message: String = "") -> bool:
	"""Assert that float value is not NaN"""
	if not is_nan(value):
		return true

	var error_msg = message if not message.is_empty() else "Value is NaN: " + str(value)
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_no_inf(value: float, message: String = "") -> bool:
	"""Assert that float value is not infinity"""
	if not is_inf(value):
		return true

	var error_msg = message if not message.is_empty() else "Value is infinite: " + str(value)
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_finite(value: float, message: String = "") -> bool:
	"""Assert that float value is finite (not NaN or infinite)"""
	if is_finite(value):
		return true

	var error_msg = message if not message.is_empty() else "Value is not finite: " + str(value)
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_vector2_finite(vector: Vector2, message: String = "") -> bool:
	"""Assert that Vector2 contains only finite values"""
	if is_finite(vector.x) and is_finite(vector.y):
		return true

	var error_msg = message if not message.is_empty() else "Vector2 contains non-finite values: " + str(vector)
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_vector3_finite(vector: Vector3, message: String = "") -> bool:
	"""Assert that Vector3 contains only finite values"""
	if is_finite(vector.x) and is_finite(vector.y) and is_finite(vector.z):
		return true

	var error_msg = message if not message.is_empty() else "Vector3 contains non-finite values: " + str(vector)
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

# ------------------------------------------------------------------------------
# ANGLE AND ROTATION ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_angle_equals(actual: float, expected: float, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that two angles are equal within tolerance (handles angle wrapping)"""
	var diff = abs(actual - expected)

	# Handle angle wrapping
	while diff > PI:
		diff -= 2 * PI
	diff = abs(diff)

	if diff <= tolerance:
		return true

	var error_msg = message if not message.is_empty() else "Angle mismatch: expected " + str(expected) + ", got " + str(actual) + " (diff: " + str(diff) + ")"
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

static func assert_angle_in_range(angle: float, min_angle: float, max_angle: float, message: String = "") -> bool:
	"""Assert that angle is within specified range"""
	# Normalize angle to 0-2π range
	while angle < 0:
		angle += 2 * PI
	while angle >= 2 * PI:
		angle -= 2 * PI

	# Check if angle is in range
	if angle >= min_angle and angle <= max_angle:
		return true

	var error_msg = message if not message.is_empty() else "Angle " + str(angle) + " not in range [" + str(min_angle) + ", " + str(max_angle) + "]"
	GDTestManager.log_test_failure("MathAssertions", error_msg)
	return false

# ------------------------------------------------------------------------------
# INTERPOLATION AND LERP ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_lerp_correct(start: float, end: float, t: float, expected: float, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that linear interpolation produces expected result"""
	var actual = lerpf(start, end, t)
	return assert_float_equals(actual, expected, tolerance, message if not message.is_empty() else "LERP result mismatch")

static func assert_vector2_lerp_correct(start: Vector2, end: Vector2, t: float, expected: Vector2, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that Vector2 linear interpolation produces expected result"""
	var actual = start.lerp(end, t)
	return assert_vector2_equals(actual, expected, tolerance, message if not message.is_empty() else "Vector2 LERP result mismatch")

static func assert_vector3_lerp_correct(start: Vector3, end: Vector3, t: float, expected: Vector3, tolerance: float = 0.0001, message: String = "") -> bool:
	"""Assert that Vector3 linear interpolation produces expected result"""
	var actual = start.lerp(end, t)
	return assert_vector3_equals(actual, expected, tolerance, message if not message.is_empty() else "Vector3 LERP result mismatch")

# ------------------------------------------------------------------------------
# RANDOMNESS AND PROBABILITY ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_random_distribution(values: Array, expected_mean: float, expected_std_dev: float, tolerance: float = 0.1, message: String = "") -> bool:
	"""Assert that array of values follows expected distribution"""
	if values.size() < 10:
		var error_msg = message if not message.is_empty() else "Need at least 10 values for distribution analysis"
		GDTestManager.log_test_failure("MathAssertions", error_msg)
		return false

	# Calculate actual mean and standard deviation
	var sum = 0.0
	for value in values:
		sum += value
	var actual_mean = sum / values.size()

	var variance_sum = 0.0
	for value in values:
		variance_sum += pow(value - actual_mean, 2)
	var actual_std_dev = sqrt(variance_sum / (values.size() - 1))

	# Check if they match expected values within tolerance
	var mean_diff = abs(actual_mean - expected_mean) / expected_mean
	var std_dev_diff = abs(actual_std_dev - expected_std_dev) / expected_std_dev

	if mean_diff <= tolerance and std_dev_diff <= tolerance:
		return true

	var final_error_msg = message if not message.is_empty() else "Distribution mismatch: expected mean " + str(expected_mean) + "±" + str(tolerance*100) + "%, std_dev " + str(expected_std_dev) + "±" + str(tolerance*100) + "% | actual mean " + str(actual_mean) + ", std_dev " + str(actual_std_dev)
	GDTestManager.log_test_failure("MathAssertions", final_error_msg)
	return false

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
static func is_equal_approx(a: float, b: float, tolerance: float = 0.0001) -> bool:
	"""Check if two floats are approximately equal"""
	return abs(a - b) <= tolerance

static func calculate_mean(values: Array) -> float:
	"""Calculate arithmetic mean of array of numbers"""
	if values.is_empty():
		return 0.0

	var sum = 0.0
	for value in values:
		sum += value

	return sum / values.size()

static func calculate_median(values: Array) -> float:
	"""Calculate median of array of numbers"""
	if values.is_empty():
		return 0.0

	var sorted = values.duplicate()
	sorted.sort()

	var size = sorted.size()
	if size % 2 == 1:
		return sorted[size / 2.0]
	else:
		return (sorted[size / 2.0 - 1] + sorted[size / 2.0]) / 2.0

static func calculate_mode(values: Array) -> float:
	"""Calculate mode (most frequent value) of array of numbers"""
	if values.is_empty():
		return 0.0

	var frequency = {}
	var max_freq = 0
	var mode = values[0]

	for value in values:
		frequency[value] = frequency.get(value, 0) + 1
		if frequency[value] > max_freq:
			max_freq = frequency[value]
			mode = value

	return mode

static func degrees_to_radians(degrees: float) -> float:
	"""Convert degrees to radians"""
	return degrees * PI / 180.0

static func radians_to_degrees(radians: float) -> float:
	"""Convert radians to degrees"""
	return radians * 180.0 / PI

static func clamp_angle(angle: float) -> float:
	"""Clamp angle to 0-2π range"""
	while angle < 0:
		angle += 2 * PI
	while angle >= 2 * PI:
		angle -= 2 * PI
	return angle
