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
        Can only teach in maintained schools, pupil referral units and non-maintained special schools subject to the 
        conditions of the sanction. Contact the Teaching Regulation Agency (TRA) on 0207 593 5393 to confirm the 
        current status of the order.
      DESCRIPTION
    },
    "A14" => { 
      title: "Suspension order with conditions",
      description: <<~DESCRIPTION.chomp
        Can only teach in maintained schools, pupil referral units and non-maintained special schools subject to the 
        conditions of the sanction. Contact the Teaching Regulation Agency (TRA) on 0207 593 5393 to confirm the 
        current status of the order.
      DESCRIPTION
    },
    "A18" => { 
      title: "Conditional registration order - conviction of a relevant offence",
      description: <<~DESCRIPTION.chomp
        Conviction of a relevant offence. [01/01/2001]. Can only teach in maintained schools, pupil referral units and 
        non-maintained special schools subject to the conditions of the sanction. Contact the Teaching Regulation 
        Agency (TRA) on 0207 593 5393 to confirm the current status of the order.
      DESCRIPTION
    },
    "A19" => {
      title: "Suspension order",
      description: <<~DESCRIPTION.chomp
        Can only teach in maintained schools, pupil referral units and non-maintained special schools subject to the 
        conditions of the sanction. Contact the Teaching Regulation Agency (TRA) on 0207 593 5393 to confirm the current
        status of the order.
      DESCRIPTION
    },
    "A1A" => { 
      title: "Prohibition by the General Teaching Council England (GTCE)",
      description: <<~DESCRIPTION.chomp
        Unacceptable professional conduct. [01/01/2001]. Cannot teach in any maintained school, pupil referral unit or 
        non-maintained special school.
      DESCRIPTION
    },
    "A1B" => { 
      title: "Prohibition by the General Teaching Council England (GTCE)",
      description: <<~DESCRIPTION.chomp
        Unacceptable professional conduct. [01/01/2001]. Will be reviewed on [01/01/2022]. Cannot teach in any school, 
        including sixth-form colleges, relevant youth accommodation and children’s homes.
      DESCRIPTION
    },
    "A2" => {
      title: "Suspension order",
      description: <<~DESCRIPTION.chomp
        Can only teach in maintained schools, pupil referral units and non-maintained special schools subject to the 
        conditions of the sanction. Contact the Teaching Regulation Agency (TRA) on 0207 593 5393 to confirm the current 
        status of the order.
      DESCRIPTION
    },
    "A20" => { 
      title: "Suspension order - with conditions",
      description: <<~DESCRIPTION.chomp
        Can only teach in maintained schools, pupil referral units and non-maintained special schools subject to the 
        conditions of the sanction. Contact the Teaching Regulation Agency (TRA) on 0207 593 5393 to confirm the current 
        status of the order.
      DESCRIPTION
    },
    "A21A" => { 
      title: "Prohibition by the General Teaching Council England (GTCE)",
      description: <<~DESCRIPTION.chomp
        Conviction of a relevant offence. [01/01/2001]. Cannot teach in any maintained school, pupil referral unit or 
        non-maintained special school.
      DESCRIPTION
    },
    "A21B" => { 
      title: "Prohibition by the General Teaching Council England (GTCE)",
      description: <<~DESCRIPTION.chomp
        Conviction of a relevant offence. [01/01/2001]. Will be reviewed on [01/01/2022].
      DESCRIPTION
    },
    "A23" => {
      title: "Suspension order",
      description: <<~DESCRIPTION.chomp
        Can only teach in maintained schools, pupil referral units and non-maintained special schools subject to the 
        conditions of the sanction. Contact the Teaching Regulation Agency (TRA) on 0207 593 5393 to confirm the current
        status of the order.
      DESCRIPTION
    },
    "A24" => {
      title: "Suspension order - with conditions",
      description: <<~DESCRIPTION.chomp
        Can only teach in maintained schools, pupil referral units and non-maintained special schools subject to the 
        conditions of the sanction. Contact the Teaching Regulation Agency (TRA) on 0207 593 5393 to confirm the current
        status of the order.
      DESCRIPTION
    },
    "A25A" => {
      title: "Prohibition by the General Teaching Council England (GTCE)",
      description: <<~DESCRIPTION.chomp
        Breach of conditions. [01/01/2001]. Cannot teach in any maintained school, pupil referral unit or non-maintained 
        special school.
      DESCRIPTION
    },
    "A25B" => {
      title: "Prohibition by the General Teaching Council England (GTCE)",
      description: <<~DESCRIPTION.chomp
        Breach of conditions. [01/01/2001]. Will be reviewed on [01/01/2022]. Cannot teach in any school, including 
        sixth-form colleges, relevant youth accommodation and children’s homes.
      DESCRIPTION
    },
    "A3" => { 
      title: "Conditional registration order - unacceptable professional conduct",
      description: <<~DESCRIPTION.chomp
        Unacceptable professional conduct. [01/01/2001]. Can only teach in maintained schools, pupil referral units and 
        non-maintained special schools subject to the conditions of the sanction. Contact the Teaching Regulation 
        Agency (TRA) on 0207 593 5393 to confirm the current status of the order.
      DESCRIPTION
    },
    "A5A" => { 
      title: "Prohibition by the General Teaching Council England (GTCE)",
      description: <<~DESCRIPTION.chomp
        Serious professional incompetence. [01/01/2001]. Cannot teach in any maintained school, pupil referral unit or 
        non-maintained special school.
      DESCRIPTION
    },
    "A5B" => { 
      title: "Prohibition by the General Teaching Council England (GTCE)",
      description: <<~DESCRIPTION.chomp
        Serious professional incompetence. [01/01/2001]. Will be reviewed on [01/01/2022]. Cannot teach in any school, 
        including sixth-form colleges, relevant youth accommodation and children’s homes.
      DESCRIPTION
    },
    "A6" => {
      title: "Suspension order",
      description: <<~DESCRIPTION.chomp
        Can only teach in maintained schools, pupil referral units and non-maintained special schools subject to the 
        conditions of the sanction. Contact the Teaching Regulation Agency (TRA) on 0207 593 5393 to confirm the current
        status of the order.
      DESCRIPTION
    },
    "A7" => { 
      title: "Conditional registration order - serious professional incompetence",
      description: <<~DESCRIPTION.chomp
        Serious professional incompetence. [01/01/2001]. Can only teach in maintained schools, pupil referral units and 
        non-maintained special schools subject to the conditions of the sanction. Contact the Teaching Regulation 
        Agency (TRA) on 0207 593 5393 to confirm the current status of the order.
      DESCRIPTION
    },
    "B3" => { 
      title: "Prohibition by the Secretary of State or an Independent Schools Tribunal",
      description: <<~DESCRIPTION.chomp
        [01/01/2001]. Cannot teach in any school, including sixth-form colleges, relevant youth accommodation and 
        children’s homes.
      DESCRIPTION
    },
    "C1" => { 
      title: "Prohibition by the Secretary of State",
      description: <<~DESCRIPTION.chomp
        Failed probation. [01/02/2001]. Cannot teach in any maintained school, pupil referral unit or non-maintained 
        special school.
      DESCRIPTION
    },
    "C2" => { 
      title: "Failed induction",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching because they failed induction.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.
        
        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "C3" => { 
      title: "Restriction by the Secretary of State",
      description: <<~DESCRIPTION.chomp
        Failed probation [01/01/2001]. Can carry out specified work for the same amount of time as a statutory 
        induction period.
      DESCRIPTION
    },
    "G1" => { 
      title: "Record found",
      description: <<~DESCRIPTION.chomp
        Contact DBS for more details [dbscost@dbs.gov.uk](mailto:dbscost@dbs.gov.uk).
      DESCRIPTION
    },
    "T1" => { 
      title: "Prohibition by the Secretary of State",
      description: <<~DESCRIPTION.chomp
        Found guilty of of serious misconduct.

        Cannot teach in any school in England, including sixth-form colleges, relevant youth accommodation and children’s homes.
        
        Check the [list of published decisions on GOV.UK](https://www.gov.uk/search/all?parent=&keywords=panel+outcome+misconduct&level_one_taxon=&manual=&organisations%5B%5D=teaching-regulation-agency&organisations%5B%5D=national-college-for-teaching-and-leadership&public_timestamp%5Bfrom%5D=&public_timestamp%5Bto%5D=&order=updated-newest) for more details.
      DESCRIPTION
    },
    "T2" => { 
      title: "Interim prohibition by the Secretary of State",
      description: <<~DESCRIPTION.chomp
        Interim prohibition. [01/01/2001]. Investigation ongoing. Cannot teach in any school, including sixth-form colleges, 
        relevant youth accommodation and children’s homes.
      DESCRIPTION
    },
    "T3" => { 
      title: "Prohibition by the Secretary of State - deregistered by GTC Scotland",
      description: <<~DESCRIPTION.chomp
        Deregistered by the General Teaching Council for Scotland (GTCS). [01/01/2001]. Cannot teach in any maintained 
        school, pupil referral unit or non-maintained special school.
      DESCRIPTION
    },
    "T4" => { 
      title: "Prohibition by the Secretary of State  - refer to the Education Workforce Council, Wales",
      description: <<~DESCRIPTION.chomp
        Contact the Education Workforce Council for more details.
      DESCRIPTION
    },
    "T5" => { 
      title: "Prohibition by the Secretary of State - refer to GTC Northern Ireland",
      description: <<~DESCRIPTION.chomp
        Contact the General Teaching Council for Northern Ireland (GTCNI) for more details.
      DESCRIPTION
    },
    "T6" => { 
      title: "Secretary of State decision - no prohibition",
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
end
