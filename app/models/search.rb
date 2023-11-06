module GOVUKDesignSystemFormBuilder
  module Elements
    class Date
      using PrefixableArray

      def field_id(segment:, link_errors: false)
        if link_errors && has_errors?(segment)
          build_id('field-error', attribute_name: segment, include_value: false)
        else
          build_id('field')
        end
      end

      private

      def classes(width, segment = nil)
        build_classes(
          %(input),
          %(date-input__input),
          %(input--width-#{width}),
          %(input--error) => has_errors?(segment),
        ).prefix(brand)
      end

      def has_errors?(segment = nil)
        @builder.object.respond_to?(:errors) && @builder.object.errors.any? && 
          (@builder.object.errors.messages[@attribute_name].present? || 
          @builder.object.errors.messages[segment].present?)
      end

      def id(segment, link_errors)
        if has_errors?(segment) && link_errors
          field_id(link_errors:, segment:)
        else
          [@object_name, @attribute_name, SEGMENTS.fetch(segment)].join("_")
        end
      end

      def input(segment, link_errors, width, value)
        tag.input(
          id: id(segment, link_errors),
          class: classes(width, segment),
          name: name(segment),
          type: 'text',
          inputmode: 'numeric',
          value:,
          autocomplete: date_of_birth_autocomplete_value(segment),
          maxlength: (width if maxlength_enabled?),
        )
      end

      def day
        date_part(:day, width: 2, link_errors: true)
      end

      def month
        date_part(:month, width: 2, link_errors: true)
      end

      def year
        date_part(:year, width: 4, link_errors: true)
      end
    end

    class ErrorMessage < Base
      def has_errors?
        @builder.object.respond_to?(:errors) && @builder.object.errors.any? && 
          (@builder.object.errors[@attribute_name].present? || 
            (@attribute_name == :date_of_birth && 
              (@builder.object.errors.messages.keys & %i[date_of_birth day month year]).any?
            )
          )
      end

      private

      def message
        error = @builder.object.errors.messages[@attribute_name]&.first
        error ||= @builder.object.errors.messages[:day]&.first if has_errors?
        set_message_safety(error)
      end
    end
  end

  module Containers
    class FormGroup < Base
      def has_errors?
        @builder.object.respond_to?(:errors) && 
          @builder.object.errors.any? && 
          (@builder.object.errors[@attribute_name].present? || 
            (@attribute_name == :date_of_birth && 
              (@builder.object.errors.messages.keys & %i[date_of_birth day month year]).any?
            )
          )
      end
    end
  end
end

class Search
  DateOfBirth =
    Struct.new(:year, :month, :day) do
      def to_s
        Date.parse("#{year}-#{month}-#{day}").to_s
      end
    end

  include ActiveModel::Model

  attr_accessor :last_name
  attr_reader :date_of_birth

  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validate :date_of_birth_is_valid, if: -> { date_of_birth.present? }

  def date_of_birth=(date_fields)
    return if date_fields.nil?

    date_fields.map! { |f| f.is_a?(String) ? word_to_number(f.strip).to_s : f }

    month_is_a_word = date_fields[1]&.to_i&.zero? && date_fields[1].length.positive?
    date_fields[1] = word_to_month_number(date_fields[1]) if month_is_a_word

    @date_of_birth = DateOfBirth.new(*date_fields)
  end

  private

  def date_of_birth_is_valid
    year = date_of_birth.year.to_i
    month = date_of_birth.month.to_i
    day = date_of_birth.day.to_i

    if day.zero?
      errors.add(:day, t(:missing_day))
    end

    if month.zero?
      errors.add(:month, t(:missing_month))
    end

    if year.zero?
      errors.add(:year, t(:missing_year))
    end

    begin
      date = Date.new(year, month, day)
      if date.future?
        errors.add(:date_of_birth, t(:in_the_future))
        return
      end

      if date.after?(16.years.ago)
        errors.add(:year, t(:inclusion))
        return
      end

      if date.year < 1000
        errors.add(:year, t(:missing_year))
        return
      end

      if date.year < 1900
        errors.add(:year, t(:born_after_1900))
      end
    rescue Date::Error
      errors.add(:date_of_birth, t(:invalid)) if (errors.messages.keys & %i[day month year]).empty?
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
