# frozen_string_literal: true

class TabbedPaginationComponent < GovukComponent::PaginationComponent
  def initialize(fragment: nil, **kwargs)
    self.fragment = fragment
    super(**kwargs)
  end

  private

  attr_accessor :fragment

  def build_items
    pagy.series.map { |i| with_item(number: i, href: pagy_url_for(pagy, i, fragment:), from_pagy: true) }
  end

  def build_next
    return unless pagy&.next

    kwargs = {
      href: pagy_url_for(pagy, pagy.next, fragment:),
      text: @next_text,
    }

    with_next_page(**kwargs.compact)
  end

  def build_previous
    return unless pagy&.prev

    kwargs = {
      href: pagy_url_for(pagy, pagy.prev, fragment:),
      text: @previous_text,
    }

    with_previous_page(**kwargs.compact)
  end
end
