# GDSentry - CI/CD Integration System
# Comprehensive CI/CD pipeline integration with JUnit output and platform support
#
# Features:
# - JUnit XML output for all major CI platforms
# - Pipeline status reporting and metrics
# - Test result aggregation and trend analysis
# - Parallel test execution coordination
# - Build artifact management
# - Environment-specific configuration
# - Failure analysis and debugging support
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name CICdIntegration

# ------------------------------------------------------------------------------
# CI/CD CONSTANTS
# ------------------------------------------------------------------------------
const JUNIT_XML_VERSION = "1.0"
const JUNIT_XML_ENCODING = "UTF-8"

# ------------------------------------------------------------------------------
# CI/CD STATE
# ------------------------------------------------------------------------------
var ci_platform: String = "unknown"
var build_number: String = ""
var build_url: String = ""
var branch_name: String = ""
var commit_hash: String = ""
var pull_request_number: String = ""

# ------------------------------------------------------------------------------
# TEST RESULTS AGGREGATION
# ------------------------------------------------------------------------------
var test_results: Array = []
var aggregated_stats: Dictionary = {}
var test_trends: Array = []

# ------------------------------------------------------------------------------
# OUTPUT CONFIGURATION
# ------------------------------------------------------------------------------
var junit_output_path: String = "res://test_results/junit.xml"
var json_output_path: String = "res://test_results/results.json"
var html_report_path: String = "res://test_results/report.html"
var coverage_output_path: String = "res://test_results/coverage.xml"

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize CI/CD integration"""
	detect_ci_platform()
	setup_output_directories()
	load_ci_environment()

func detect_ci_platform() -> void:
	"""Detect the CI/CD platform being used"""
	# GitHub Actions
	if OS.has_environment("GITHUB_ACTIONS"):
		ci_platform = "github_actions"
		build_number = OS.get_environment("GITHUB_RUN_NUMBER")
		build_url = OS.get_environment("GITHUB_SERVER_URL") + "/" + OS.get_environment("GITHUB_REPOSITORY") + "/actions/runs/" + OS.get_environment("GITHUB_RUN_ID")
		branch_name = OS.get_environment("GITHUB_REF_NAME")
		commit_hash = OS.get_environment("GITHUB_SHA")

	# GitLab CI
	elif OS.has_environment("GITLAB_CI"):
		ci_platform = "gitlab_ci"
		build_number = OS.get_environment("CI_JOB_ID")
		build_url = OS.get_environment("CI_JOB_URL")
		branch_name = OS.get_environment("CI_COMMIT_REF_NAME")
		commit_hash = OS.get_environment("CI_COMMIT_SHA")

	# Jenkins
	elif OS.has_environment("JENKINS_HOME"):
		ci_platform = "jenkins"
		build_number = OS.get_environment("BUILD_NUMBER")
		build_url = OS.get_environment("BUILD_URL")
		branch_name = OS.get_environment("GIT_BRANCH")
		commit_hash = OS.get_environment("GIT_COMMIT")

	# Azure DevOps
	elif OS.has_environment("TF_BUILD"):
		ci_platform = "azure_devops"
		build_number = OS.get_environment("BUILD_BUILDNUMBER")
		build_url = OS.get_environment("SYSTEM_TEAMFOUNDATIONCOLLECTIONURI") + OS.get_environment("SYSTEM_TEAMPROJECT") + "/_build/results?buildId=" + OS.get_environment("BUILD_BUILDID")
		branch_name = OS.get_environment("BUILD_SOURCEBRANCHNAME")
		commit_hash = OS.get_environment("BUILD_SOURCEVERSION")

	# CircleCI
	elif OS.has_environment("CIRCLECI"):
		ci_platform = "circleci"
		build_number = OS.get_environment("CIRCLE_BUILD_NUM")
		build_url = OS.get_environment("CIRCLE_BUILD_URL")
		branch_name = OS.get_environment("CIRCLE_BRANCH")
		commit_hash = OS.get_environment("CIRCLE_SHA1")

	# Travis CI
	elif OS.has_environment("TRAVIS"):
		ci_platform = "travis_ci"
		build_number = OS.get_environment("TRAVIS_BUILD_NUMBER")
		build_url = "https://travis-ci.com/" + OS.get_environment("TRAVIS_REPO_SLUG") + "/builds/" + OS.get_environment("TRAVIS_BUILD_ID")
		branch_name = OS.get_environment("TRAVIS_BRANCH")
		commit_hash = OS.get_environment("TRAVIS_COMMIT")

	# Local development
	else:
		ci_platform = "local"
		build_number = "local_" + str(Time.get_unix_time_from_system())
		branch_name = get_git_branch()
		commit_hash = get_git_commit()

func get_git_branch() -> String:
	"""Get current git branch"""
	var output = []
	var exit_code = OS.execute("git", ["rev-parse", "--abbrev-ref", "HEAD"], output)
	if exit_code == 0 and output.size() > 0:
		return output[0].strip_edges()
	return "unknown"

func get_git_commit() -> String:
	"""Get current git commit hash"""
	var output = []
	var exit_code = OS.execute("git", ["rev-parse", "HEAD"], output)
	if exit_code == 0 and output.size() > 0:
		return output[0].strip_edges()
	return "unknown"

func setup_output_directories() -> void:
	"""Create necessary output directories"""
	var dirs = [
		"res://test_results/",
		"res://test_reports/",
		"res://test_artifacts/",
		"res://test_coverage/"
	]

	for dir_path in dirs:
		var global_path = ProjectSettings.globalize_path(dir_path)
		if not DirAccess.dir_exists_absolute(global_path):
			var error = DirAccess.make_dir_recursive_absolute(global_path)
			if error != OK:
				push_warning("Failed to create CI/CD directory: " + dir_path)

func load_ci_environment() -> void:
	"""Load CI/CD environment configuration"""
	# Load pull request information if available
	if OS.has_environment("GITHUB_EVENT_NAME") and OS.get_environment("GITHUB_EVENT_NAME") == "pull_request":
		pull_request_number = OS.get_environment("GITHUB_REF").split("/")[2] if OS.get_environment("GITHUB_REF").contains("/pull/") else ""
	elif OS.has_environment("GITLAB_MERGE_REQUEST_IID"):
		pull_request_number = OS.get_environment("GITLAB_MERGE_REQUEST_IID")

# ------------------------------------------------------------------------------
# JUNIT XML GENERATION
# ------------------------------------------------------------------------------
func generate_junit_xml(test_suites: Array) -> String:
	"""Generate JUnit XML output compatible with all CI platforms"""
	var xml_content = '<?xml version="' + JUNIT_XML_VERSION + '" encoding="' + JUNIT_XML_ENCODING + '"?>\n'
	xml_content += '<testsuites>\n'

	var total_tests = 0
	var total_failures = 0
	var total_errors = 0
	var total_time = 0.0

	# Process each test suite
	for suite_data in test_suites:
		var suite_name = suite_data.get("name", "UnknownSuite")
		var suite_tests = suite_data.get("tests", [])
		var suite_time = suite_data.get("time", 0.0)

		total_tests += suite_tests.size()
		total_time += suite_time

		xml_content += '  <testsuite name="' + _escape_xml(suite_name) + '" '
		xml_content += 'tests="' + str(suite_tests.size()) + '" '
		xml_content += 'time="' + str(suite_time) + '">\n'

		# Process individual tests
		for test_data in suite_tests:
			var test_name = test_data.get("name", "UnknownTest")
			var test_time = test_data.get("time", 0.0)
			var test_status = test_data.get("status", "passed")
			var test_message = test_data.get("message", "")
			var test_class = test_data.get("class", suite_name)

			xml_content += '	<testcase name="' + _escape_xml(test_name) + '" '
			xml_content += 'classname="' + _escape_xml(test_class) + '" '
			xml_content += 'time="' + str(test_time) + '">\n'

			# Add failure or error details
			if test_status == "failed":
				total_failures += 1
				xml_content += '	  <failure message="' + _escape_xml(test_message) + '">\n'
				xml_content += '		<![CDATA[' + test_data.get("details", "") + ']]>\n'
				xml_content += '	  </failure>\n'
			elif test_status == "error":
				total_errors += 1
				xml_content += '	  <error message="' + _escape_xml(test_message) + '">\n'
				xml_content += '		<![CDATA[' + test_data.get("details", "") + ']]>\n'
				xml_content += '	  </error>\n'

			xml_content += '	</testcase>\n'

		xml_content += '  </testsuite>\n'

	xml_content += '</testsuites>\n'

	# Update aggregated stats
	aggregated_stats = {
		"total_tests": total_tests,
		"total_failures": total_failures,
		"total_errors": total_errors,
		"total_time": total_time,
		"success_rate": (float(total_tests - total_failures - total_errors) / float(total_tests)) * 100.0 if total_tests > 0 else 0.0
	}

	return xml_content

func _escape_xml(text: String) -> String:
	"""Escape XML special characters"""
	return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&apos;")

# ------------------------------------------------------------------------------
# CI/CD PLATFORM INTEGRATION
# ------------------------------------------------------------------------------
func generate_platform_specific_commands() -> Dictionary:
	"""Generate platform-specific commands and configurations"""
	var commands = {
		"set_output": "",
		"set_summary": "",
		"upload_artifacts": "",
		"fail_build": "",
		"set_badge": ""
	}

	match ci_platform:
		"github_actions":
			commands.set_output = "echo 'test_results<<EOF' >> $GITHUB_OUTPUT"
			commands.set_summary = "echo '## Test Results' >> $GITHUB_STEP_SUMMARY"
			commands.upload_artifacts = "uses: actions/upload-artifact@v3"
			commands.fail_build = "exit 1"
			commands.set_badge = "echo '::set-badge::tests"

		"gitlab_ci":
			commands.set_output = "echo 'TEST_RESULTS<<EOF' >> gitlab.env"
			commands.set_summary = "echo '## Test Results' >> job.log"
			commands.upload_artifacts = "artifacts:"
			commands.fail_build = "exit 1"
			commands.set_badge = "echo 'BADGE"

		"jenkins":
			commands.set_output = "echo 'TEST_RESULTS=' > test_results.properties"
			commands.set_summary = "echo 'Test Results' > test_summary.txt"
			commands.upload_artifacts = "archiveArtifacts"
			commands.fail_build = "currentBuild.result = 'FAILURE'"
			commands.set_badge = "addBadge"

		"azure_devops":
			commands.set_output = 'echo "##vso[task.setvariable variable=test_results]"'
			commands.set_summary = 'echo "##vso[task.logissue type=warning]"'
			commands.upload_artifacts = "PublishBuildArtifacts"
			commands.fail_build = 'echo "##vso[task.complete result=Failed]"'
			commands.set_badge = 'echo "##vso[build.updatebuildnumber]"'

		"circleci":
			commands.set_output = "echo 'export TEST_RESULTS<<EOF' >> $BASH_ENV"
			commands.set_summary = "echo '## Test Results' >> test_summary.md"
			commands.upload_artifacts = "store_artifacts"
			commands.fail_build = "circleci step halt"
			commands.set_badge = "echo 'BADGE"

		"travis_ci":
			commands.set_output = "echo 'TEST_RESULTS=' > test_results.env"
			commands.set_summary = "echo 'Test Results' > test_summary.txt"
			commands.upload_artifacts = "after_success: echo 'Artifacts uploaded'"
			commands.fail_build = "exit 1"
			commands.set_badge = "echo 'BADGE"

		_:
			# Local development - use simple commands
			commands.set_output = "echo 'Test results available in test_results/'"
			commands.set_summary = "cat test_results/summary.txt"
			commands.upload_artifacts = "echo 'Artifacts saved locally'"
			commands.fail_build = "exit 1"
			commands.set_badge = "echo 'Local build badge'"

	return commands

# ------------------------------------------------------------------------------
# PIPELINE STATUS REPORTING
# ------------------------------------------------------------------------------
func report_pipeline_status(success: bool, stats: Dictionary = {}) -> void:
	"""Report test results to CI/CD pipeline"""
	var status_message = generate_status_message(success, stats)
	var _commands = generate_platform_specific_commands()

	match ci_platform:
		"github_actions":
			if success:
				print("::set-output name=test_status::success")
			else:
				print("::set-output name=test_status::failure")
			print("::set-output name=test_summary::" + status_message)

		"gitlab_ci":
			print("TEST_STATUS=" + ("success" if success else "failure"))
			print("TEST_SUMMARY=" + status_message)

		"jenkins":
			print("TEST_STATUS=" + ("SUCCESS" if success else "FAILURE"))
			print("TEST_SUMMARY=" + status_message)

		"azure_devops":
			if success:
				print("##vso[task.setvariable variable=test_status]success")
			else:
				print("##vso[task.setvariable variable=test_status]failure")
			print("##vso[task.setvariable variable=test_summary]" + status_message)

		_:
			print("Test Status: " + ("SUCCESS" if success else "FAILURE"))
			print("Summary: " + status_message)

func generate_status_message(success: bool, stats: Dictionary) -> String:
	"""Generate human-readable status message"""
	var message = ""

	if success:
		message = "✅ All tests passed!"
	else:
		message = "❌ Test failures detected!"

	message += " | Total: " + str(stats.get("total_tests", 0))
	message += " | Passed: " + str(stats.get("total_tests", 0) - stats.get("total_failures", 0) - stats.get("total_errors", 0))
	message += " | Failed: " + str(stats.get("total_failures", 0))
	message += " | Errors: " + str(stats.get("total_errors", 0))

	if stats.get("total_time", 0.0) > 0:
		message += " | Time: " + str(stats.get("total_time", 0.0)) + "s"

	return message

# ------------------------------------------------------------------------------
# TEST RESULT AGGREGATION
# ------------------------------------------------------------------------------
func aggregate_test_results(test_suites: Array) -> Dictionary:
	"""Aggregate test results from multiple sources"""
	var aggregated = {
		"total_tests": 0,
		"passed_tests": 0,
		"failed_tests": 0,
		"error_tests": 0,
		"skipped_tests": 0,
		"total_time": 0.0,
		"suites": [],
		"failures": [],
		"errors": [],
		"performance": {
			"average_test_time": 0.0,
			"slowest_test": null,
			"fastest_test": null
		}
	}

	for suite in test_suites:
		var suite_name = suite.get("name", "Unknown")
		var suite_tests = suite.get("tests", [])
		var suite_stats = analyze_suite(suite_tests)

		aggregated.total_tests += suite_stats.total_tests
		aggregated.passed_tests += suite_stats.passed_tests
		aggregated.failed_tests += suite_stats.failed_tests
		aggregated.error_tests += suite_stats.error_tests
		aggregated.skipped_tests += suite_stats.skipped_tests
		aggregated.total_time += suite_stats.total_time

		aggregated.suites.append({
			"name": suite_name,
			"stats": suite_stats
		})

		# Collect failures and errors
		for failure in suite_stats.failures:
			aggregated.failures.append(failure)

		for error in suite_stats.errors:
			aggregated.errors.append(error)

	# Calculate performance metrics
	if aggregated.total_tests > 0:
		aggregated.performance.average_test_time = aggregated.total_time / aggregated.total_tests

	# Update trends
	update_test_trends(aggregated)

	return aggregated

func analyze_suite(tests: Array) -> Dictionary:
	"""Analyze a single test suite"""
	var stats = {
		"total_tests": tests.size(),
		"passed_tests": 0,
		"failed_tests": 0,
		"error_tests": 0,
		"skipped_tests": 0,
		"total_time": 0.0,
		"failures": [],
		"errors": []
	}

	for test in tests:
		var status = test.get("status", "unknown")
		stats.total_time += test.get("time", 0.0)

		match status:
			"passed":
				stats.passed_tests += 1
			"failed":
				stats.failed_tests += 1
				stats.failures.append(test)
			"error":
				stats.error_tests += 1
				stats.errors.append(test)
			"skipped":
				stats.skipped_tests += 1

	return stats

func update_test_trends(current_results: Dictionary) -> void:
	"""Update test result trends for analysis"""
	test_trends.append({
		"timestamp": Time.get_unix_time_from_system(),
		"build_number": build_number,
		"results": current_results
	})

	# Keep only last 100 trend entries
	if test_trends.size() > 100:
		test_trends.remove_at(0)

# ------------------------------------------------------------------------------
# COVERAGE REPORTING
# ------------------------------------------------------------------------------
func generate_coverage_report(coverage_data: Dictionary) -> String:
	"""Generate code coverage report in Cobertura XML format"""
	var xml_content = '<?xml version="1.0" encoding="UTF-8"?>\n'
	xml_content += '<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">\n'
	xml_content += '<coverage line-rate="' + str(coverage_data.get("line_rate", 0.0)) + '" '
	xml_content += 'branch-rate="' + str(coverage_data.get("branch_rate", 0.0)) + '" '
	xml_content += 'lines-covered="' + str(coverage_data.get("lines_covered", 0)) + '" '
	xml_content += 'lines-valid="' + str(coverage_data.get("lines_valid", 0)) + '" '
	xml_content += 'branches-covered="' + str(coverage_data.get("branches_covered", 0)) + '" '
	xml_content += 'branches-valid="' + str(coverage_data.get("branches_valid", 0)) + '" '
	xml_content += 'complexity="0.0" version="1.0" timestamp="' + str(Time.get_unix_time_from_system()) + '">\n'

	# Add sources
	xml_content += '  <sources>\n'
	for source in coverage_data.get("sources", []):
		xml_content += '	<source>' + _escape_xml(source) + '</source>\n'
	xml_content += '  </sources>\n'

	# Add packages
	xml_content += '  <packages>\n'
	for package_data in coverage_data.get("packages", []):
		xml_content += '	<package name="' + _escape_xml(package_data.get("name", "")) + '" '
		xml_content += 'line-rate="' + str(package_data.get("line_rate", 0.0)) + '" '
		xml_content += 'branch-rate="' + str(package_data.get("branch_rate", 0.0)) + '" '
		xml_content += 'complexity="0.0">\n'

		# Add classes
		xml_content += '	  <classes>\n'
		for class_data in package_data.get("classes", []):
			xml_content += '		<class name="' + _escape_xml(class_data.get("name", "")) + '" '
			xml_content += 'filename="' + _escape_xml(class_data.get("filename", "")) + '" '
			xml_content += 'line-rate="' + str(class_data.get("line_rate", 0.0)) + '" '
			xml_content += 'branch-rate="' + str(class_data.get("branch_rate", 0.0)) + '" '
			xml_content += 'complexity="0.0">\n'

			# Add methods
			xml_content += '		  <methods>\n'
			for method_data in class_data.get("methods", []):
				xml_content += '			<method name="' + _escape_xml(method_data.get("name", "")) + '" '
				xml_content += 'signature="' + _escape_xml(method_data.get("signature", "")) + '" '
				xml_content += 'line-rate="' + str(method_data.get("line_rate", 0.0)) + '" '
				xml_content += 'branch-rate="' + str(method_data.get("branch_rate", 0.0)) + '">\n'
				xml_content += '			  <lines>\n'
				for line_data in method_data.get("lines", []):
					xml_content += '				<line number="' + str(line_data.get("number", 0)) + '" '
					xml_content += 'hits="' + str(line_data.get("hits", 0)) + '" '
					xml_content += 'branch="false" />\n'
				xml_content += '			  </lines>\n'
				xml_content += '			</method>\n'
			xml_content += '		  </methods>\n'

			# Add lines
			xml_content += '		  <lines>\n'
			for line_data in class_data.get("lines", []):
				xml_content += '			<line number="' + str(line_data.get("number", 0)) + '" '
				xml_content += 'hits="' + str(line_data.get("hits", 0)) + '" '
				xml_content += 'branch="false" />\n'
			xml_content += '		  </lines>\n'

			xml_content += '		</class>\n'
		xml_content += '	  </classes>\n'

		xml_content += '	</package>\n'
	xml_content += '  </packages>\n'

	xml_content += '</coverage>\n'

	return xml_content

# ------------------------------------------------------------------------------
# PARALLEL EXECUTION COORDINATION
# ------------------------------------------------------------------------------
func coordinate_parallel_execution(test_suites: Array, max_parallel: int = 4) -> Dictionary:
	"""Coordinate parallel test execution across multiple processes"""
	var coordination_data = {
		"total_suites": test_suites.size(),
		"max_parallel": max_parallel,
		"batches": [],
		"execution_plan": [],
		"estimated_time": 0.0
	}

	# Group tests into batches for parallel execution
	var batches = create_execution_batches(test_suites, max_parallel)
	coordination_data.batches = batches

	# Create execution plan
	for i in range(batches.size()):
		var batch = batches[i]
		var batch_plan = {
			"batch_id": i,
			"suite_count": batch.size(),
			"estimated_time": estimate_batch_time(batch),
			"priority": calculate_batch_priority(batch),
			"suites": batch
		}
		coordination_data.execution_plan.append(batch_plan)
		coordination_data.estimated_time += batch_plan.estimated_time

	return coordination_data

func create_execution_batches(test_suites: Array, max_parallel: int) -> Array:
	"""Create batches of test suites for parallel execution"""
	var batches = []
	var current_batch = []
	var current_batch_time = 0.0
	var max_batch_time = 300.0	# 5 minutes max per batch

	for suite in test_suites:
		var suite_time = suite.get("estimated_time", 60.0)

		# Start new batch if current batch is full or would exceed time limit
		if current_batch.size() >= max_parallel or (current_batch_time + suite_time) > max_batch_time:
			if not current_batch.is_empty():
				batches.append(current_batch)
				current_batch = []
				current_batch_time = 0.0

		current_batch.append(suite)
		current_batch_time += suite_time

	# Add remaining batch
	if not current_batch.is_empty():
		batches.append(current_batch)

	return batches

func estimate_batch_time(batch: Array) -> float:
	"""Estimate execution time for a batch of test suites"""
	var total_time = 0.0
	for suite in batch:
		total_time += suite.get("estimated_time", 60.0)
	return total_time

func calculate_batch_priority(batch: Array) -> int:
	"""Calculate execution priority for a batch"""
	# Prioritize batches with fast tests or critical functionality
	var priority = 0
	for suite in batch:
		if suite.get("is_critical", false):
			priority += 10
		if suite.get("is_fast", false):
			priority += 5
	return priority

# ------------------------------------------------------------------------------
# BUILD ARTIFACT MANAGEMENT
# ------------------------------------------------------------------------------
func manage_build_artifacts(artifacts: Dictionary) -> void:
	"""Manage build artifacts for CI/CD pipeline"""
	var artifact_manifest = {
		"build_info": {
			"platform": ci_platform,
			"build_number": build_number,
			"build_url": build_url,
			"branch": branch_name,
			"commit": commit_hash,
			"timestamp": Time.get_unix_time_from_system()
		},
		"artifacts": artifacts,
		"test_results": aggregated_stats
	}

	# Save artifact manifest
	var manifest_path = "res://test_artifacts/manifest.json"
	var global_path = ProjectSettings.globalize_path(manifest_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(artifact_manifest, "\t"))
		file.close()

	# Generate artifact summary for CI/CD
	generate_artifact_summary(artifacts)

func generate_artifact_summary(artifacts: Dictionary) -> void:
	"""Generate artifact summary for CI/CD systems"""
	var summary = "📦 Build Artifacts Summary\n"
	summary += "========================\n\n"

	for artifact_name in artifacts.keys():
		var artifact_data = artifacts[artifact_name]
		summary += "📄 " + artifact_name + "\n"
		summary += "   Path: " + artifact_data.get("path", "unknown") + "\n"
		summary += "   Size: " + str(artifact_data.get("size", 0)) + " bytes\n"
		summary += "   Type: " + artifact_data.get("type", "unknown") + "\n\n"

	# Output based on CI platform
	match ci_platform:
		"github_actions":
			print("::set-output name=artifact_summary::" + summary)
		"gitlab_ci":
			print("ARTIFACT_SUMMARY=" + summary)
		_:
			print(summary)

# ------------------------------------------------------------------------------
# FAILURE ANALYSIS
# ------------------------------------------------------------------------------
func analyze_test_failures(failures: Array) -> Dictionary:
	"""Analyze test failures for debugging support"""
	var analysis = {
		"failure_patterns": {},
		"common_errors": {},
		"affected_components": {},
		"severity_assessment": {},
		"debugging_suggestions": []
	}

	for failure in failures:
		var error_message = failure.get("message", "")
		var test_class = failure.get("class", "")
		var _test_name = failure.get("name", "")

		# Categorize failure patterns
		if "null" in error_message.to_lower():
			analysis.failure_patterns["null_reference"] = analysis.failure_patterns.get("null_reference", 0) + 1
		elif "assertion" in error_message.to_lower():
			analysis.failure_patterns["assertion_failure"] = analysis.failure_patterns.get("assertion_failure", 0) + 1
		elif "timeout" in error_message.to_lower():
			analysis.failure_patterns["timeout"] = analysis.failure_patterns.get("timeout", 0) + 1

		# Track affected components
		if not test_class.is_empty():
			analysis.affected_components[test_class] = analysis.affected_components.get(test_class, 0) + 1

	# Generate debugging suggestions
	analysis.debugging_suggestions = generate_debugging_suggestions(analysis)

	return analysis

func generate_debugging_suggestions(analysis: Dictionary) -> Array:
	"""Generate debugging suggestions based on failure analysis"""
	var suggestions = []

	var failure_patterns = analysis.get("failure_patterns", {})

	if failure_patterns.get("null_reference", 0) > 3:
		suggestions.append("Multiple null reference errors detected - check object initialization and lifecycle management")

	if failure_patterns.get("assertion_failure", 0) > 5:
		suggestions.append("Many assertion failures - review test expectations and implementation logic")

	if failure_patterns.get("timeout", 0) > 2:
		suggestions.append("Timeout errors detected - check for infinite loops or performance issues")

	var affected_components = analysis.get("affected_components", {})
	if affected_components.size() > 3:
		suggestions.append("Failures span multiple components - consider integration testing issues")

	return suggestions

# ------------------------------------------------------------------------------
# OUTPUT AND REPORTING
# ------------------------------------------------------------------------------
func save_junit_report(xml_content: String, file_path: String = "") -> bool:
	"""Save JUnit XML report to file"""
	if file_path.is_empty():
		file_path = junit_output_path

	var global_path = ProjectSettings.globalize_path(file_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		file.store_string(xml_content)
		file.close()
		return true

	return false

func save_json_report(results: Dictionary, file_path: String = "") -> bool:
	"""Save test results as JSON"""
	if file_path.is_empty():
		file_path = json_output_path

	var global_path = ProjectSettings.globalize_path(file_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(results, "\t"))
		file.close()
		return true

	return false

func generate_html_report(results: Dictionary) -> String:
	"""Generate HTML test report"""
	var html = """
<!DOCTYPE html>
<html>
<head>
	<title>GDSentry Test Report</title>
	<style>
		body { font-family: Arial, sans-serif; margin: 20px; }
		.header { background: #2c3e50; color: white; padding: 20px; border-radius: 5px; }
		.summary { background: #ecf0f1; padding: 15px; margin: 20px 0; border-radius: 5px; }
		.stats { display: flex; justify-content: space-around; }
		.stat { text-align: center; }
		.stat-value { font-size: 2em; font-weight: bold; }
		.passed { color: #27ae60; }
		.failed { color: #e74c3c; }
		.error { color: #f39c12; }
		.suite { margin: 20px 0; border: 1px solid #ddd; border-radius: 5px; }
		.suite-header { background: #f8f9fa; padding: 10px; border-bottom: 1px solid #ddd; }
		.test { padding: 5px 10px; border-bottom: 1px solid #eee; }
		.test-passed { background: #d4edda; }
		.test-failed { background: #f8d7da; }
		.test-error { background: #fff3cd; }
	</style>
</head>
<body>
	<div class="header">
		<h1>GDSentry Test Report</h1>
		<p>Generated on: """ + Time.get_datetime_string_from_system() + """</p>
		<p>Build: """ + build_number + """ | Branch: """ + branch_name + """</p>
		<p>Commit: """ + commit_hash.substr(0, 8) + """</p>
	</div>

	<div class="summary">
		<h2>Test Summary</h2>
		<div class="stats">
			<div class="stat">
				<div class="stat-value">""" + str(results.get("total_tests", 0)) + """</div>
				<div>Total Tests</div>
			</div>
			<div class="stat">
				<div class="stat-value passed">""" + str(results.get("passed_tests", 0)) + """</div>
				<div>Passed</div>
			</div>
			<div class="stat">
				<div class="stat-value failed">""" + str(results.get("failed_tests", 0)) + """</div>
				<div>Failed</div>
			</div>
			<div class="stat">
				<div class="stat-value error">""" + str(results.get("error_tests", 0)) + """</div>
				<div>Errors</div>
			</div>
			<div class="stat">
				<div class="stat-value">""" + str("%.1f" % results.get("total_time", 0.0)) + """s</div>
				<div>Total Time</div>
			</div>
		</div>
	</div>
"""

	# Add suite details
	html += "	 <h2>Test Suites</h2>\n"
	for suite in results.get("suites", []):
		html += '	 <div class="suite">\n'
		html += '		 <div class="suite-header">\n'
		html += '			 <h3>' + suite.name + '</h3>\n'
		html += '			 <p>' + str(suite.stats.total_tests) + ' tests, ' + str("%.2f" % suite.stats.total_time) + 's</p>\n'
		html += '		 </div>\n'

		for test in suite.stats.tests:
			var test_class = "test-passed"
			if test.status == "failed":
				test_class = "test-failed"
			elif test.status == "error":
				test_class = "test-error"

			html += '		 <div class="test ' + test_class + '">\n'
			html += '			 <strong>' + test.name + '</strong> (' + str("%.3f" % test.time) + 's)\n'
			if test.status != "passed":
				html += '			 <br><small>' + test.message + '</small>\n'
			html += '		 </div>\n'

		html += '	 </div>\n'

	html += """
</body>
</html>"""

	return html

func save_html_report(html_content: String, file_path: String = "") -> bool:
	"""Save HTML report to file"""
	if file_path.is_empty():
		file_path = html_report_path

	var global_path = ProjectSettings.globalize_path(file_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		file.store_string(html_content)
		file.close()
		return true

	return false

# ------------------------------------------------------------------------------
# CONFIGURATION METHODS
# ------------------------------------------------------------------------------
func set_output_paths(junit_path: String = "", json_path: String = "", html_path: String = "") -> void:
	"""Set output file paths"""
	if not junit_path.is_empty():
		junit_output_path = junit_path
	if not json_path.is_empty():
		json_output_path = json_path
	if not html_path.is_empty():
		html_report_path = html_path

func enable_ci_features(platform: String = "") -> void:
	"""Enable CI/CD specific features"""
	if not platform.is_empty():
		ci_platform = platform
	detect_ci_platform()

func get_ci_info() -> Dictionary:
	"""Get current CI/CD information"""
	return {
		"platform": ci_platform,
		"build_number": build_number,
		"build_url": build_url,
		"branch_name": branch_name,
		"commit_hash": commit_hash,
		"pull_request_number": pull_request_number
	}

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup CI/CD integration resources"""
	# Save final results if available
	if not aggregated_stats.is_empty():
		save_json_report(aggregated_stats)

	# Generate final HTML report
	if not aggregated_stats.is_empty():
		var html_report = generate_html_report(aggregated_stats)
		save_html_report(html_report)
