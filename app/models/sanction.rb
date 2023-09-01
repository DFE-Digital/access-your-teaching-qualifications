class Sanction
  attr_accessor :code, :start_date

  def initialize(api_data)
    @code = api_data[:code]
    @start_date = api_data[:start_date].present? ? Date.parse(api_data[:start_date]) : nil
  end

  SANCTIONS = {
    "A13" => { title: "Suspension order - with conditions" },
    "A14" => { title: "Suspension order - with conditions" },
    "A18" => { title: "Conditional registration order - conviction of a relevant offence" },
    "A19" => { title: "Suspension order" },
    "A1A" => { title: "Prohibition by the General Teaching Council England (GTCE)" },
    "A1B" => { title: "Prohibition by the General Teaching Council England (GTCE)" },
    "A2" => { title: "Suspension order" },
    "A20" => { title: "Suspension order - with conditions" },
    "A21A" => { title: "Prohibition by the General Teaching Council England (GTCE)" },
    "A21B" => { title: "Prohibition by the General Teaching Council England (GTCE)" },
    "A23" => { title: "Suspension order" },
    "A24" => { title: "Suspension order - with conditions" },
    "A25A" => { title: "Prohibition by the General Teaching Council England (GTCE)" },
    "A25B" => { title: "Prohibition by the General Teaching Council England (GTCE)" },
    "A3" => { title: "Conditional registration order - unacceptable professional conduct" },
    "A5A" => { title: "Prohibition by the General Teaching Council England (GTCE)" },
    "A5B" => { title: "Prohibition by the General Teaching Council England (GTCE)" },
    "A6" => { title: "Suspension order" },
    "A7" => { title: "Conditional registration order  - serious professional incompetence" },
    "B3" => { title: "Prohibition by the Secretary of State or an Independent Schools Tribunal" },
    "C1" => { title: "Prohibition by the Secretary of State" },
    "C2" => { title: "Failed induction" },
    "C3" => { title: "Restriction by the Secretary of State" },
    "G1" => { title: "Record found" },
    "T1" => { title: "Prohibition by the Secretary of State" },
    "T2" => { title: "Interim prohibition by the Secretary of State" },
    "T3" => { title: "Prohibition by the Secretary of State - deregistered by GTC Scotland" },
    "T4" => { title: "Prohibition by the Secretary of State  - refer to the Education Workforce Council, Wales" },
    "T5" => { title: "Prohibition by the Secretary of State - refer to GTC Northern Ireland" },
    "T6" => { title: "Secretary of State decision - no prohibition" },
    "T7" => { title: "Section 128 barring direction" }
  }.freeze

  def title
    SANCTIONS[code][:title] if SANCTIONS[code]
  end
end
