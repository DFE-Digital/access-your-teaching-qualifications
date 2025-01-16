class Qualification
  include ActiveModel::Model

  attr_accessor :awarded_at, :certificate_url, :name, :status_description, :type
  attr_writer :details

  FORMATTED_QUALIFICATION_TEXT = {
    NPQEL: "National Professional <br/> Qualification for <br/> Executive Leadership",
    NPQLTD: "National Professional <br/> Qualification for Leading <br/> Teacher Development",
    NPQLT: "National Professional <br/> Qualification for Leading <br/> Teaching",
    NPQH:  "National Professional <br/> Qualification for <br/> Headship",
    NPQML:"National Professional <br/> Qualification for Middle <br/> Leadership",
    NPQLL: "National Professional <br/> Qualification for Leading <br/> Literacy",
    NPQEYL: "National Professional <br/> Qualification for Early <br/> Years Leadership",
    NPQSL: "National Professional <br/> Qualification for Senior <br/> Leadership",
    NPQLBC: "National Professional <br/> Qualification for Leading <br/> Behaviour and Culture"
  }.freeze

  def certificate_type
    return :npq if type&.downcase&.starts_with?("npq")

    type
  end

  def details
    @details ||= Hashie::Mash.new({})
  end

  def id
    # QTS and EYTS certificate URLs don't contain an id
    return nil if qts? || eyts?
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
    type&.starts_with?("NPQ")
  end

  def qts?
    type == :qts
  end

  def eyts?
    type == :eyts
  end

  def formatted_qualification_name
    FORMATTED_QUALIFICATION_TEXT[type].html_safe
  end

end
