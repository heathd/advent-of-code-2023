require "strscan"

class Day1
	DIGITS = %w{
		zero
		one
		two
		three
		four
		five
		six
		seven
		eight
		nine
	}

	def find_first_and_last_digits_of_line(line)
		digits = []
		s = StringScanner.new(line)
		while s.scan_until(/([0-9]|zero|one|two|three|four|five|six|seven|eight|nine)/)
			digit = s.matched
			if digit =~ /[0-9]/
				digits << digit.to_i
			else
				digits << DIGITS.find_index(digit)
			end

			# Move the pointer back to one character after the start of the match
			s.pos = s.pos - (digit.size - 1)
		end
		[digits.first, digits.last]
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
