class Search
  DateOfBirth =
    Struct.new(:year, :month, :day) do
      def to_s
        Date.parse("#{year}-#{month}-#{day}").to_s
      end
    end

  include ActiveModel::Model

  attr_accessor :last_name, :searched_at
  attr_reader :date_of_birth


  validates :last_name, presence: true
  validate :date_of_birth_is_valid

  def date_of_birth=(date_fields)
    return if date_fields.nil?

    date_fields.map! { |f| f.is_a?(String) ? word_to_number(f.strip).to_s : f }

    month_is_a_word = date_fields[1]&.to_i&.zero? && date_fields[1].length.positive?
    date_fields[1] = word_to_month_number(date_fields[1]) if month_is_a_word

    @date_of_birth = DateOfBirth.new(*date_fields)
  end

  def searched_at_to_s
    searched_at.strftime("%-I:%M%P on %-d %B %Y")
  end

  private

  def date_of_birth_is_valid
    if @date_of_birth.nil?
      errors.add(:date_of_birth, t(:blank))
      return
    end

    year = @date_of_birth.year.to_i
    month = @date_of_birth.month.to_i
    day = @date_of_birth.day.to_i

    if day.zero? && month.zero? && year.zero?
      errors.add(:date_of_birth, t(:blank))
      return
    end

    if day.zero? && month.zero?
      errors.add(:date_of_birth, t(:missing_day_and_month))
      return
    end

    if day.zero? && year.zero?
      errors.add(:date_of_birth, t(:missing_day_and_year))
      return
    end

    if month.zero? && year.zero?
      errors.add(:date_of_birth, t(:missing_month_and_year))
      return
    end

    if day.zero?
      errors.add(:date_of_birth, t(:missing_day))
      return
    end

    if month.zero?
      errors.add(:date_of_birth, t(:missing_month))
      nil
    end

    if year.zero?
      errors.add(:date_of_birth, t(:missing_year))
      return
    end

    begin
      date = Date.new(year, month, day)
      if date.future?
        errors.add(:date_of_birth, t(:in_the_future))
        return
      end

      if date.after?(16.years.ago)
        errors.add(:date_of_birth, t(:inclusion))
        return
      end

      if date.year < 1000
        errors.add(:date_of_birth, t(:missing_year))
        return
      end

      if date.year < 1900
        errors.add(:date_of_birth, t(:born_after_1900))
        nil
      end
    rescue Date::Error
      errors.add(:date_of_birth, t(:blank))
      nil
    end
  end

  def t(str)
    I18n.t("activemodel.errors.models.search.attributes.date_of_birth.#{str}")
  end

  def word_to_month_number(raw_month)
    begin
      month = Date.parse(raw_month).month
    rescue Date::Error
      month = 0
    end
    month.to_s
  end

  def word_to_number(field)
    return field if field.is_a? Integer

    words = {
      one: 1,
      two: 2,
      three: 3,
      four: 4,
      five: 5,
      six: 6,
      seven: 7,
      eight: 8,
      nine: 9,
      ten: 10,
      eleven: 11,
      twelve: 12
    }

    words[field.downcase.to_sym] || field
  end
end
