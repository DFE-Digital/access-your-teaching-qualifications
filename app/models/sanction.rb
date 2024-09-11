class Sanction
  attr_accessor :code, :start_date

  def initialize(api_data)
    @code = api_data[:code]
    @start_date = api_data[:start_date].present? ? Date.parse(api_data[:start_date]) : nil
  end

  SANCTIONS = {
    "A13" => {
      title: "Suspension order with conditions",
      description: <<~DESCRIPTION.chomp
        Suspended by the General Teaching Council for England.

        Must meet conditions to teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "A14" => {
      title: "Suspension order with conditions",
      description: <<~DESCRIPTION.chomp
        Suspended by the General Teaching Council for England.

        Must meet conditions to teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "A18" => {
      title: "Registration order with conditions",
      description: <<~DESCRIPTION.chomp
        Given a registration order by the General Teaching Council for England.

        Must meet conditions to teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "A1A" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the General Teaching Council for England because of unacceptable professional conduct.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "A1B" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the General Teaching Council for England because of unacceptable professional conduct.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "A20" => {
      title: "Suspension order with conditions",
      description: <<~DESCRIPTION.chomp
        Suspended by the General Teaching Council for England.

        Must meet conditions to teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "A21A" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the General Teaching Council for England because of a criminal offence which is relevant to fitness to teach.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "A21B" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the General Teaching Council for England because of a criminal offence which is relevant to their fitness to teach.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "A3" => {
      title: "Registration order with conditions",
      description: <<~DESCRIPTION.chomp
        Given a registration order by the General Teaching Council.

        Must meet conditions to teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "A5A" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the General Teaching Council for England because of serious professional incompetence.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "A5B" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the General Teaching Council for England because of serious professional incompetence.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "A7" => {
      title: "Registration order with conditions",
      description: <<~DESCRIPTION.chomp
        Given a registration order by the General Teaching Council for England.

        Must meet conditions to teach in maintained schools, pupil referral units and non-maintained special schools in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "B3" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the Secretary of State or an independent schools tribunal.

        Cannot teach in any school in England, including sixth-form colleges, relevant youth accommodation and children’s homes.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "C1" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching because they failed probation.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "C2" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching because they failed induction.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "C3" => {
      title: "Restriction",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching because they failed probation.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "T1" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Found guilty of of serious misconduct.

        Cannot teach in any school in England, including sixth-form colleges, relevant youth accommodation and children’s homes.

        Check the [list of published decisions on GOV.UK](https://www.gov.uk/search/all?parent=&keywords=panel+outcome+misconduct&level_one_taxon=&manual=&organisations%5B%5D=teaching-regulation-agency&organisations%5B%5D=national-college-for-teaching-and-leadership&public_timestamp%5Bfrom%5D=&public_timestamp%5Bto%5D=&order=updated-newest) for more details.
      DESCRIPTION
    },
    "T2" => {
      title: "Interim prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching during an investigation for serious misconduct.

        Cannot teach in any school in England, including sixth-form colleges, relevant youth accommodation and children’s homes.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "T3" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Deregistered by the General Teaching Council for Scotland because of serious misconduct.

        Cannot teach in any school, including sixth-form colleges, relevant youth accommodation and children’s homes.
      DESCRIPTION
    },
    "T4" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Deregistered by the Education Workforce Council, Wales because of serious misconduct.

        Cannot teach in any school, including sixth-form colleges, relevant youth accommodation and children’s homes.

        Email [registration@ewc.wales](mailto:registration@ewc.wales) for more information.
      DESCRIPTION
    },
    "T5" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Found guilty of serious misconduct by the General Teaching Council for Northern Ireland.

        Cannot teach in any school, including sixth-form colleges, relevant youth accommodation and children’s homes.

        Email [registration@gtcni.org.uk](mailto:registration@gtcni.org.uk) for more information.
      DESCRIPTION
    },
    "T6" => {
      title: "Found guilty of serious misconduct but not prevented from teaching",
      description: <<~DESCRIPTION.chomp
        Check the [list of published decisions on GOV.UK](https://www.gov.uk/search/all?parent=&keywords=panel+outcome+misconduct&level_one_taxon=&manual=&organisations%5B%5D=teaching-regulation-agency&organisations%5B%5D=national-college-for-teaching-and-leadership&public_timestamp%5Bfrom%5D=&public_timestamp%5Bto%5D=&order=updated-newest) for more details.
      DESCRIPTION
    }
  }.freeze

  def description
    SANCTIONS[code][:description] if SANCTIONS[code]
  end

  def title
    SANCTIONS[code][:title] if SANCTIONS[code]
  end

  def guilty_but_not_prohibited?
    code == "T6"
  end
end
