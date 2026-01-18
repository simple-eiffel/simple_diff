note
	description: "Stress tests for simple_diff resource limits"
	author: "simple_diff hardening"
	date: "2026-01-18"

class
	STRESS_TESTS

inherit
	TEST_SET_BASE

feature -- Volume Tests

	test_1000_lines
			-- Test 1000 line diff.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
			l_source, l_target: STRING
			i: INTEGER
		do
			create l_diff.make
			create l_source.make (50000)
			create l_target.make (50000)
			from i := 1 until i > 1000 loop
				l_source.append ("line" + i.out + "%N")
				l_target.append ("line" + i.out + "%N")
				i := i + 1
			end
			l_target.replace_substring_all ("line500", "modified500")
			l_result := l_diff.diff_strings (l_source, l_target)
			assert ("handles_1000_lines", l_result /= Void)
			assert ("found_change", l_result.has_changes)
		end

	test_2000_lines
			-- Test 2000 line diff.
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
			l_source, l_target: STRING
			i: INTEGER
		do
			create l_diff.make
			create l_source.make (100000)
			create l_target.make (100000)
			from i := 1 until i > 2000 loop
				l_source.append ("line" + i.out + "%N")
				l_target.append ("line" + i.out + "%N")
				i := i + 1
			end
			l_target.replace_substring_all ("line1000", "modified1000")
			l_result := l_diff.diff_strings (l_source, l_target)
			assert ("handles_2000_lines", l_result /= Void)
			assert ("found_change", l_result.has_changes)
		end

	test_5000_lines
			-- Test 5000 line diff (may be slow).
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
			l_source, l_target: STRING
			i: INTEGER
		do
			create l_diff.make
			create l_source.make (250000)
			create l_target.make (250000)
			from i := 1 until i > 5000 loop
				l_source.append ("line" + i.out + "%N")
				l_target.append ("line" + i.out + "%N")
				i := i + 1
			end
			l_target.replace_substring_all ("line2500", "modified2500")
			l_result := l_diff.diff_strings (l_source, l_target)
			assert ("handles_5000_lines", l_result /= Void)
			assert ("found_change", l_result.has_changes)
		end

feature -- Worst Case Tests

	test_completely_different_1000
			-- Test 1000 completely different lines (worst case for LCS).
		local
			l_diff: SIMPLE_DIFF
			l_result: DIFF_RESULT
			l_source, l_target: STRING
			i: INTEGER
		do
			create l_diff.make
			create l_source.make (50000)
			create l_target.make (50000)
			from i := 1 until i > 1000 loop
				l_source.append ("source_line" + i.out + "%N")
				l_target.append ("target_line" + i.out + "%N")
				i := i + 1
			end
			l_result := l_diff.diff_strings (l_source, l_target)
			assert ("handles_worst_case", l_result /= Void)
			assert ("found_changes", l_result.has_changes)
			assert ("many_additions", l_result.additions_total >= 1000)
			assert ("many_deletions", l_result.deletions_total >= 1000)
		end

end
