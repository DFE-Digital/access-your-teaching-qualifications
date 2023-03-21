class Qualification
  include ActiveModel::Model

  attr_accessor :awarded_at, :details, :name, :type
  attr_writer :certificate_url

  def certificate_type
    return :npq if type.downcase.starts_with?("npq")

    type
  end

  def id
    @certificate_url&.split("/")&.last
  end

  def induction?
    type == :induction
  end

  def itt?
    type == :itt
  end
end
