class Qualification
  include ActiveModel::Model

  attr_accessor :awarded_at,
                :name,
                :type,
                :qtls_only,
                :set_membership_active,
                :set_membership_expired,
                :passed_induction,
                :failed_induction,
                :qts_and_qtls,
                :routes

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
    NPQLBC: "National Professional <br/> Qualification for Leading <br/> Behaviour and Culture",
    NPQLPM: "National Professional <br/> Qualification for Leading <br/> Primary Mathematics",
    NPQSENCO: "National Professional <br/> Qualification for Special <br/> Educational Needs Co-ordinators"
  }.freeze

  def certificate_type
    return :npq if type&.downcase&.starts_with?("npq")

    type
  end

  def details
    @details ||= Hashie::Mash.new({})
  end

  def induction?
    type == :induction
  end

  def rtps?
    [:qts_rtps, :eyts_rtps, :rtps].include?(type)
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

  def route_ids
    routes&.map do |route|
      route.route_to_professional_status_type.route_to_professional_status_type_id
    end || []
  end
end
