extends VisualRegressionTestFramework

## Approval Workflow Example
##
## Demonstrates visual change approval workflow for baseline updates.
## This example shows how to:
## - Manage pending approvals
## - Approve or reject baseline updates
## - Auto-approve minor changes
## - Track approval state

var test_container: VBoxContainer
var test_title: Label

func _ready():
	"""Setup test scene"""
	super._ready()
	setup_test_ui()

func setup_test_ui():
	"""Create test UI"""
	test_container = VBoxContainer.new()
	test_container.position = Vector2(150, 150)
	add_child(test_container)
	
	test_title = Label.new()
	test_title.text = "Approval Workflow Test"
	test_title.add_theme_font_size_override("font_size", 28)
	test_container.add_child(test_title)

func test_create_pending_approval():
	"""Create a pending approval for visual change"""
	describe("Create Pending Approval")
	
	print("\n📋 Creating pending approval...")
	
	# Capture original baseline
	await get_tree().process_frame
	capture_baseline("approval_test")
	
	# Make intentional visual change
	test_title.text = "Updated Title"
	test_title.add_theme_color_override("font_color", Color.BLUE)
	await get_tree().process_frame
	
	# Compare (will detect change)
	var result = compare_with_baseline("approval_test", 0.02)
	
	print("  Similarity: ", "%.2f" % (result.similarity * 100), "%")
	
	if not result.success:
		# Create pending approval
		pending_approvals["approval_test"] = {
			"state": ApprovalState.PENDING,
			"similarity": result.similarity,
			"timestamp": Time.get_unix_time_from_system(),
			"reason": "Intentional title update",
			"change_description": "Changed title text and color to blue"
		}
		
		print("\n  ⏳ Approval Status: PENDING")
		print("  Reason: ", pending_approvals["approval_test"].reason)
		print("  Description: ", pending_approvals["approval_test"].change_description)
		print("  Similarity: ", "%.2f" % (result.similarity * 100), "%")
	
	assert_true(pending_approvals.has("approval_test"), "Pending approval should be created")
	print("\n  ✅ Pending approval created")

func test_approve_baseline_update():
	"""Approve a pending baseline update"""
	describe("Approve Baseline Update")
	
	print("\n✅ Approving baseline update...")
	
	# Ensure pending approval exists
	if not pending_approvals.has("approval_test"):
		await test_create_pending_approval()
	
	# Approve the change
	var approval_data = pending_approvals["approval_test"]
	approval_data.state = ApprovalState.APPROVED
	approval_data.approved_by = "test_user"
	approval_data.approved_at = Time.get_unix_time_from_system()
	
	print("  Previous State: PENDING")
	print("  New State: APPROVED")
	print("  Approved By: ", approval_data.approved_by)
	print("  Approved At: ", Time.get_datetime_string_from_system())
	
	# Update baseline with new version
	capture_baseline("approval_test")
	
	# Remove from pending
	pending_approvals.erase("approval_test")
	
	print("\n  ✅ Baseline approved and updated")
	print("  Note: New baseline will be used for future comparisons")

func test_reject_baseline_update():
	"""Reject a pending baseline update"""
	describe("Reject Baseline Update")
	
	print("\n❌ Rejecting baseline update...")
	
	# Create new pending approval
	await get_tree().process_frame
	capture_baseline("rejection_test")
	
	test_title.text = "Rejected Change"
	await get_tree().process_frame
	
	var result = compare_with_baseline("rejection_test", 0.02)
	
	if not result.success:
		pending_approvals["rejection_test"] = {
			"state": ApprovalState.PENDING,
			"similarity": result.similarity,
			"timestamp": Time.get_unix_time_from_system(),
			"reason": "Unintended change"
		}
	
	# Reject the change
	var approval_data = pending_approvals["rejection_test"]
	approval_data.state = ApprovalState.REJECTED
	approval_data.rejected_by = "test_user"
	approval_data.rejected_at = Time.get_unix_time_from_system()
	approval_data.rejection_reason = "Change not intended, reverting"
	
	print("  Previous State: PENDING")
	print("  New State: REJECTED")
	print("  Rejected By: ", approval_data.rejected_by)
	print("  Reason: ", approval_data.rejection_reason)
	
	# Revert change
	test_title.text = "Approval Workflow Test"
	
	# Remove from pending
	pending_approvals.erase("rejection_test")
	
	print("\n  ✅ Baseline update rejected")
	print("  Note: Original baseline retained, change reverted")

func test_auto_approval():
	"""Test automatic approval for minor changes"""
	describe("Auto-Approval for Minor Changes")
	
	print("\n🤖 Testing auto-approval...")
	
	# Configure auto-approval
	auto_approve_similar = true
	perceptual_threshold = 0.98  # 98% similarity auto-approves
	
	print("  Auto-Approve Enabled: ", auto_approve_similar)
	print("  Threshold: ", "%.1f" % (perceptual_threshold * 100), "%")
	
	# Capture baseline
	await get_tree().process_frame
	capture_baseline("auto_approve_test")
	
	# Make very minor change (should auto-approve)
	test_title.modulate = Color(1.0, 1.0, 0.99)  # Barely visible tint
	await get_tree().process_frame
	
	# Compare
	var result = compare_with_baseline("auto_approve_test", 0.02)
	
	print("\n  Similarity: ", "%.2f" % (result.similarity * 100), "%")
	
	# Check if should auto-approve
	if result.similarity >= perceptual_threshold:
		print("  Status: ✅ AUTO-APPROVED")
		print("  Reason: Similarity (", "%.2f" % (result.similarity * 100), 
		      "%) exceeds threshold (", "%.1f" % (perceptual_threshold * 100), "%)")
		
		# Auto-approve
		if not result.success:
			pending_approvals["auto_approve_test"] = {
				"state": ApprovalState.AUTO_APPROVED,
				"similarity": result.similarity,
				"timestamp": Time.get_unix_time_from_system(),
				"reason": "Auto-approved (minor change)"
			}
			
			# Update baseline
			capture_baseline("auto_approve_test")
			pending_approvals.erase("auto_approve_test")
	else:
		print("  Status: ⏳ PENDING MANUAL APPROVAL")
		print("  Reason: Similarity below auto-approve threshold")
	
	# Restore
	test_title.modulate = Color.WHITE
	
	print("\n  ✅ Auto-approval test completed")
	print("  Note: Auto-approval reduces manual review burden")

func test_approval_state_tracking():
	"""Test approval state tracking"""
	describe("Approval State Tracking")
	
	print("\n📊 Testing approval state tracking...")
	
	# Create multiple approvals in different states
	var approvals = {
		"pending_1": {
			"state": ApprovalState.PENDING,
			"similarity": 0.92,
			"timestamp": Time.get_unix_time_from_system(),
			"reason": "UI layout change"
		},
		"approved_1": {
			"state": ApprovalState.APPROVED,
			"similarity": 0.95,
			"timestamp": Time.get_unix_time_from_system() - 3600,
			"approved_by": "developer_1",
			"reason": "Intentional color update"
		},
		"rejected_1": {
			"state": ApprovalState.REJECTED,
			"similarity": 0.85,
			"timestamp": Time.get_unix_time_from_system() - 7200,
			"rejected_by": "qa_lead",
			"rejection_reason": "Unintended regression"
		},
		"auto_approved_1": {
			"state": ApprovalState.AUTO_APPROVED,
			"similarity": 0.99,
			"timestamp": Time.get_unix_time_from_system() - 1800,
			"reason": "Minor rendering difference"
		}
	}
	
	# Print approval summary
	print("\n  Approval Summary:")
	
	var state_counts = {
		"PENDING": 0,
		"APPROVED": 0,
		"REJECTED": 0,
		"AUTO_APPROVED": 0
	}
	
	for approval_name in approvals:
		var approval = approvals[approval_name]
		var state_name = ApprovalState.keys()[approval.state]
		state_counts[state_name] += 1
		
		print("\n    ", approval_name, ":")
		print("      State: ", state_name)
		print("      Similarity: ", "%.2f" % (approval.similarity * 100), "%")
		print("      Reason: ", approval.reason)
	
	print("\n  State Counts:")
	for state in state_counts:
		print("    ", state, ": ", state_counts[state])
	
	print("\n  ✅ Approval tracking completed")
	print("  Note: Track approval history for audit trail")

func test_approval_workflow_integration():
	"""Test complete approval workflow"""
	describe("Complete Approval Workflow")
	
	print("\n🔄 Testing complete approval workflow...")
	
	print("\n  Step 1: Capture baseline")
	await get_tree().process_frame
	capture_baseline("workflow_test")
	print("    ✅ Baseline captured")
	
	print("\n  Step 2: Make visual change")
	test_title.text = "Workflow Test - Updated"
	await get_tree().process_frame
	print("    ✅ Visual change applied")
	
	print("\n  Step 3: Detect change")
	var result = compare_with_baseline("workflow_test", 0.02)
	print("    Similarity: ", "%.2f" % (result.similarity * 100), "%")
	print("    ✅ Change detected")
	
	print("\n  Step 4: Create pending approval")
	if not result.success:
		pending_approvals["workflow_test"] = {
			"state": ApprovalState.PENDING,
			"similarity": result.similarity,
			"timestamp": Time.get_unix_time_from_system(),
			"reason": "Workflow test update"
		}
		print("    ✅ Pending approval created")
	
	print("\n  Step 5: Review change")
	print("    Reviewer checks diff image...")
	print("    Decision: APPROVE")
	
	print("\n  Step 6: Approve and update baseline")
	pending_approvals["workflow_test"].state = ApprovalState.APPROVED
	capture_baseline("workflow_test")
	pending_approvals.erase("workflow_test")
	print("    ✅ Baseline approved and updated")
	
	print("\n  Step 7: Verify new baseline")
	var verify_result = compare_with_baseline("workflow_test", 0.02)
	print("    Similarity: ", "%.2f" % (verify_result.similarity * 100), "%")
	print("    ✅ New baseline verified")
	
	assert_true(verify_result.success, "New baseline should match current state")
	
	print("\n  ✅ Complete workflow executed successfully")
	print("\n  Workflow Summary:")
	print("    1. Capture baseline")
	print("    2. Make change")
	print("    3. Detect change")
	print("    4. Create approval")
	print("    5. Review")
	print("    6. Approve/Reject")
	print("    7. Update baseline or revert")
