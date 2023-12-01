class Day1
	def find_first_and_last_digits_of_line(line)
		nums = line.chars.select {|c| c =~ /^[0-9]$/}.map(&:to_i)
		[nums.first, nums.last]
	end

	def line_calibration_value(line)
		first,last = find_first_and_last_digits_of_line(line)
		if first
			first * 10 + last
		else
			0
		end
	end

	def calibration_value(input)
		input.split("\n").reject(&:empty?).map {|l| line_calibration_value(l)}.sum
	end
end

if __FILE__==$0
	puts Day1.new.calibration_value(ARGF.read)
end
