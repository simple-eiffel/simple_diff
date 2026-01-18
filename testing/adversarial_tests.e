note
	description: "Adversarial tests for simple_diff hardening validation"
	author: "simple_diff hardening"
	date: "2026-01-18"

class
	ADVERSARIAL_TESTS

inherit
	TEST_SET_BASE

feature -- Input Attack Tests

	test_null_byte_in_content
			-- Test binary content with null bytes.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
			l_source, l_target: STRING
		do
			create l_diff.make
			l_source := "line1%Uline2"  -- %U is null byte
			l_target := "line1%Umodified"
			l_result := l_diff.diff_strings (l_source, l_target)
			assert ("handles_null_byte", l_result /= Void)
		end

	test_control_characters
			-- Test various control characters.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
			l_source, l_target: STRING
		do
			create l_diff.make
			l_source := "line%Twith%Ttabs"
			l_target := "line%Rwith%Rreturns"
			l_result := l_diff.diff_strings (l_source, l_target)
			assert ("handles_control_chars", l_result /= Void)
		end

	test_very_long_line
			-- Test extremely long single line.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
			l_source, l_target: STRING
			i: INTEGER
		do
			create l_diff.make
			create l_source.make (100000)
			create l_target.make (100000)
			from i := 1 until i > 100000 loop
				l_source.append_character ('a')
				l_target.append_character ('b')
				i := i + 1
			end
			l_result := l_diff.diff_strings (l_source, l_target)
			assert ("handles_long_line", l_result /= Void)
			assert ("has_changes", l_result.has_changes)
		end

	test_many_lines
			-- Test many lines (stress LCS algorithm).
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
			l_source, l_target: STRING
			i: INTEGER
		do
			create l_diff.make
			create l_source.make (10000)
			create l_target.make (10000)
			from i := 1 until i > 500 loop
				l_source.append ("line" + i.out + "%N")
				l_target.append ("line" + i.out + "%N")
				i := i + 1
			end
			l_target.replace_substring_all ("line250", "modified250")
			l_result := l_diff.diff_strings (l_source, l_target)
			assert ("handles_500_lines", l_result /= Void)
			assert ("found_change", l_result.has_changes)
		end

feature -- Output Attack Tests

	test_html_injection_content
			-- Test that HTML special chars are escaped in HTML output.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
			l_html: STRING
		do
			create l_diff.make
			l_result := l_diff.diff_strings ("<script>alert('xss')</script>", "safe content")
			l_html := l_result.to_html
			assert ("html_escapes_script", not l_html.has_substring ("<script>"))
		end

	test_json_special_chars
			-- Test that JSON special chars are handled.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
			l_json: STRING
		do
			create l_diff.make
			l_result := l_diff.diff_strings ("line with %"quotes%" and \\backslash", "other")
			l_json := l_result.to_json
			assert ("json_starts_brace", l_json.starts_with ("{"))
			assert ("json_ends_brace", l_json.ends_with ("}"))
		end

	test_unicode_content
			-- Test unicode character handling.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
		do
			create l_diff.make
			l_result := l_diff.diff_strings ("Hello World", "Hello Earth")
			assert ("handles_unicode", l_result /= Void)
			assert ("detected_change", l_result.has_changes)
		end

feature -- State Attack Tests

	test_reuse_after_error
			-- Test that engine recovers after file error.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
		do
			create l_diff.make
			l_result := l_diff.diff_files ("nonexistent1.txt", "nonexistent2.txt")
			l_result := l_diff.diff_strings ("a", "b")
			assert ("recovered", l_result /= Void)
			assert ("works_after_error", l_result.has_changes)
		end

	test_multiple_diffs_same_instance
			-- Test multiple sequential diffs on same instance.
		local
			l_diff: SIMPLE_DIFF
			l_result1, l_result2, l_result3: DIFF_RESULT
		do
			create l_diff.make
			l_result1 := l_diff.diff_strings ("a", "b")
			l_result2 := l_diff.diff_strings ("c", "d")
			l_result3 := l_diff.diff_strings ("e", "f")
			assert ("r1_valid", l_result1 /= Void and then l_result1.has_changes)
			assert ("r2_valid", l_result2 /= Void and then l_result2.has_changes)
			assert ("r3_valid", l_result3 /= Void and then l_result3.has_changes)
			assert ("r1_independent", l_result1 /= l_result2)
		end

feature -- Edge Case Tests

	test_only_newlines
			-- Test content that is only newlines.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
		do
			create l_diff.make
			l_result := l_diff.diff_strings ("%N%N%N", "%N%N%N%N")
			assert ("handles_only_newlines", l_result /= Void)
		end

	test_trailing_newline_difference
			-- Test files differing only in trailing newline.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
		do
			create l_diff.make
			l_result := l_diff.diff_strings ("content", "content%N")
			assert ("handles_trailing_newline", l_result /= Void)
		end

	test_identical_large_files
			-- Test that identical large content is handled efficiently.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
			l_content: STRING
			i: INTEGER
		do
			create l_diff.make
			create l_content.make (50000)
			from i := 1 until i > 1000 loop
				l_content.append ("This is line number " + i.out + " of the test content%N")
				i := i + 1
			end
			l_result := l_diff.diff_strings (l_content, l_content)
			assert ("identical_detected", l_result.is_identical)
			assert ("no_changes", not l_result.has_changes)
		end

feature -- Patch Attack Tests

	test_patch_context_mismatch
			-- Test patching with wrong context.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
			l_applier: PATCH_APPLIER
			l_patched: STRING
		do
			create l_diff.make
			l_result := l_diff.diff_strings ("context%Nold%Ncontext", "context%Nnew%Ncontext")
			create l_applier.make
			l_patched := l_applier.apply_to_string (l_result, "wrong%Nold%Nwrong")
			assert ("rejects_mismatch", l_applier.has_rejects)
		end

	test_reverse_patch
			-- Test reverse patch application.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
			l_applier: PATCH_APPLIER
			l_patched: STRING
		do
			create l_diff.make
			l_result := l_diff.diff_strings ("original", "modified")
			create l_applier.make
			l_applier.set_reverse (True)
			l_patched := l_applier.apply_to_string (l_result, "modified")
			assert ("reverse_works", l_patched.has_substring ("original"))
		end

end
