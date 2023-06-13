class Qualification
  include ActiveModel::Model

  attr_accessor :awarded_at, :certificate_url, :name, :type
  attr_writer :details

  def certificate_type
    return :npq if type&.downcase&.starts_with?("npq")

    type
  end

  def details
    @details ||= Hashie::Mash.new({})
  end

  def id
    # QTS certificate URLs don't contain an id
    return nil if qts?

    @certificate_url&.split("/")&.last
  end

  def induction?
    type == :induction
  end

  def itt?
    type == :itt
  end

  def mq?
    type == :mandatory
  end

  def npq?
    type&.downcase&.starts_with?("npq")
  end

  def qts?
    type == :qts
  end
end
