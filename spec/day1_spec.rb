require "day1"

RSpec.describe "day1" do
	subject(:day1) { Day1.new }

	describe "#find_first_and_last_digits_of_line" do
		it "gets the first and last digits of a line" do
			expect(day1.find_first_and_last_digits_of_line("1abc2")).to eq([1,2])
		end

		it "if theres only one digit it uses it as both first and last" do
			expect(day1.find_first_and_last_digits_of_line("frog5dof")).to eq([5,5])
		end

		context "with numbers as words" do
			it "finds the numbers as words" do
				expect(day1.find_first_and_last_digits_of_line("zero")).to  eq([0,0])
				expect(day1.find_first_and_last_digits_of_line("one")).to   eq([1,1])
				expect(day1.find_first_and_last_digits_of_line("two")).to   eq([2,2])
				expect(day1.find_first_and_last_digits_of_line("three")).to eq([3,3])
				expect(day1.find_first_and_last_digits_of_line("four")).to  eq([4,4])
				expect(day1.find_first_and_last_digits_of_line("five")).to  eq([5,5])
				expect(day1.find_first_and_last_digits_of_line("six")).to   eq([6,6])
				expect(day1.find_first_and_last_digits_of_line("seven")).to eq([7,7])
				expect(day1.find_first_and_last_digits_of_line("eight")).to eq([8,8])
				expect(day1.find_first_and_last_digits_of_line("nine")).to  eq([9,9])
				expect(day1.find_first_and_last_digits_of_line("one2three")).to eq([1,3])
				expect(day1.find_first_and_last_digits_of_line("abcone2three")).to eq([1,3])
				expect(day1.find_first_and_last_digits_of_line("onceuponatimetherewerethreelonelywolves")).to eq([3,1])
				expect(day1.find_first_and_last_digits_of_line("7pqrstsixteen")).to eq([7,6])
			end
		end
	end

	describe "#line_calibration_value" do
		it "concatenates first and last digit" do
			expect(day1.line_calibration_value("frog5dof")).to eq(55)
		end
		it "concatenates first and last digit" do
			expect(day1.line_calibration_value("a1b2c3d4e5f")).to eq(15)
		end

		it "concatenates first and last digit" do
			expect(day1.line_calibration_value("pqr3stu8vwx")).to eq(38)
		end

		context "a line where a number prefixes another number" do
			it "works" do
				expect(day1.line_calibration_value("fivephplggzkmfivetjfourmvcpnjxfvg58eightwoc")).to eq(52)
			end
		end
	end

	describe "#calibration_value" do
		context "numbers as digits" do
			let(:sample_input) {
				<<~SAMPLE
					1abc2
					pqr3stu8vwx
					a1b2c3d4e5f
					treb7uchet
				SAMPLE
			}

			it "for a single line" do
				expect(day1.calibration_value("1")).to eq(11)
			end

			it "sums the calibration values of multiple lines" do
				expect(day1.calibration_value(sample_input)).to eq(142)
			end
		end

		context "numbers as words" do
			let(:sample_input) {
				<<~SAMPLE
					two1nine
					eightwothree
					abcone2threexyz
					xtwone3four
					4nineeightseven2
					zoneight234
					7pqrstsixteen
				SAMPLE
			}

			it "sums the calibration values of multiple lines" do
				expect(day1.calibration_value(sample_input)).to eq(281)
			end
		end
	end


end