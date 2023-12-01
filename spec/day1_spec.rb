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
	end

	describe "#calibration_value" do

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
end