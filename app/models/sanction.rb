class Sanction
  attr_accessor :alert_type_id, :start_date

  def initialize(api_data)
    @alert_type_id = api_data[:alert_type][:alert_type_id]
    @start_date = api_data[:start_date].present? ? Date.parse(api_data[:start_date]) : nil
  end

  SANCTIONS = {
    "1a2b06ae-7e9f-4761-b95d-397ca5da4b13" => {
      title: "Suspension order with conditions",
      description: <<~DESCRIPTION.chomp
        Suspended by the General Teaching Council for England.

        Must meet conditions to teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "50508749-7a6b-4175-8538-9a1e55692efd" => {
      title: "Suspension order with conditions",
      description: <<~DESCRIPTION.chomp
        Suspended by the General Teaching Council for England.

        Must meet conditions to teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "a6fc9f2e-8923-4163-978e-93bd901d146f" => {
      title: "Registration order with conditions",
      description: <<~DESCRIPTION.chomp
        Given a registration order by the General Teaching Council for England.

        Must meet conditions to teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "fa6bd220-61b0-41fc-9066-421b3b9d7885" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the General Teaching Council for England because of unacceptable professional conduct.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "e3658a61-bee2-4df1-9a26-e010681ee310" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the General Teaching Council for England because of unacceptable professional conduct.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "d372fcfa-1c4a-4fed-84c8-4c7885575681" => {
      title: "Suspension order with conditions",
      description: <<~DESCRIPTION.chomp
        Suspended by the General Teaching Council for England.

        Must meet conditions to teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "950d3eed-bef5-448a-b0f0-bf9c54f2103b" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the General Teaching Council for England because of a criminal offence which is relevant to fitness to teach.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "72e48b6a-e781-4bf3-910b-91f2d28f2eaa" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the General Teaching Council for England because of a criminal offence which is relevant to their fitness to teach.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "3499860a-a0fb-43e3-878e-c226d14150b0" => {
      title: "Registration order with conditions",
      description: <<~DESCRIPTION.chomp
        Given a registration order by the General Teaching Council.

        Must meet conditions to teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "c02bdc3a-7a19-4034-aa23-3a23c54e1d34" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the General Teaching Council for England because of serious professional incompetence.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "cac68337-3f95-4475-97cf-1381e6b74700" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the General Teaching Council for England because of serious professional incompetence.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "1ebd1620-293d-4169-ba78-0b41a6413ad9" => {
      title: "Registration order with conditions",
      description: <<~DESCRIPTION.chomp
        Given a registration order by the General Teaching Council for England.

        Must meet conditions to teach in maintained schools, pupil referral units and non-maintained special schools in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "8ef92c14-4b1f-4530-9189-779ad9f3cefd" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching by the Secretary of State or an independent schools tribunal.

        Cannot teach in any school in England, including sixth-form colleges, relevant youth accommodation and children’s homes.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "651e1f56-3135-4961-bd7e-3f7b2c75cb04" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching because they failed probation.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "9fafaa80-f9f8-44a0-b7b3-cffedcbe0298" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching because they failed induction.

        Cannot teach in a maintained school, pupil referral unit or non-maintained special school in England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "5ea8bb68-4774-4ad8-b635-213a0cdda4c3" => {
      title: "Restriction",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching because they failed probation.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "ed0cd700-3fb2-4db0-9403-ba57126090ed" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Found guilty of of serious misconduct.

        Cannot teach in any school in England, including sixth-form colleges, relevant youth accommodation and children’s homes.

        Check the [list of published decisions on GOV.UK](https://www.gov.uk/search/all?parent=&keywords=panel+outcome+misconduct&level_one_taxon=&manual=&organisations%5B%5D=teaching-regulation-agency&organisations%5B%5D=national-college-for-teaching-and-leadership&public_timestamp%5Bfrom%5D=&public_timestamp%5Bto%5D=&order=updated-newest) for more details.
      DESCRIPTION
    },
    "a414283f-7d5b-4587-83bf-f6da8c05b8d5" => {
      title: "Interim prohibition order",
      description: <<~DESCRIPTION.chomp
        Prevented from teaching during an investigation for serious misconduct.

        Cannot teach in any school in England, including sixth-form colleges, relevant youth accommodation and children’s homes.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 for more information.
      DESCRIPTION
    },
    "50feafbc-5124-4189-b06c-6463c7ebb8a8" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Deregistered by the General Teaching Council for Scotland because of serious misconduct.

        Cannot teach in any school, including sixth-form colleges, relevant youth accommodation and children’s homes.
      DESCRIPTION
    },
    "a5bd4352-2cec-4417-87a1-4b6b79d033c2" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Deregistered by the Education Workforce Council, Wales because of serious misconduct.

        Cannot teach in any school, including sixth-form colleges, relevant youth accommodation and children’s homes.

        Email [registration@ewc.wales](mailto:registration@ewc.wales) for more information.
      DESCRIPTION
    },
    "5aa21b8f-2069-43c9-8afd-05b34b02505f" => {
      title: "Prohibition order",
      description: <<~DESCRIPTION.chomp
        Found guilty of serious misconduct by the General Teaching Council for Northern Ireland.

        Cannot teach in any school, including sixth-form colleges, relevant youth accommodation and children’s homes.

        Email [registration@gtcni.org.uk](mailto:registration@gtcni.org.uk) for more information.
      DESCRIPTION
    },
    "7924fe90-483c-49f8-84fc-674feddba848" => {
      title: "Found guilty of serious misconduct but not prevented from teaching",
      description: <<~DESCRIPTION.chomp
        Check the [list of published decisions on GOV.UK](https://www.gov.uk/search/all?parent=&keywords=panel+outcome+misconduct&level_one_taxon=&manual=&organisations%5B%5D=teaching-regulation-agency&organisations%5B%5D=national-college-for-teaching-and-leadership&public_timestamp%5Bfrom%5D=&public_timestamp%5Bto%5D=&order=updated-newest) for more details.
      DESCRIPTION
    },
    "af65c236-47a6-427b-8e4b-930de6d256f0" => {
      title: "Suspension order without conditions",
      description: <<~DESCRIPTION.chomp
        Suspended by the General Teaching Council for England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "872d7700-aa6f-435e-b5f9-821fb087962a" => {
      title: "Suspension order without conditions",
      description: <<~DESCRIPTION.chomp
        Suspended by the General Teaching Council for England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "3c5fc83b-10e1-4a15-83e6-794fce3e0b45" => {
      title: "Suspension order without conditions",
      description: <<~DESCRIPTION.chomp
        Suspended by the General Teaching Council for England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "17b4fe26-7468-4702-92e5-785b861cf0fa" => {
      title: "Suspension order with conditions",
      description: <<~DESCRIPTION.chomp
        Suspended by the General Teaching Council for England.
  
        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
    "a6f51ccc-a19c-4dc2-ba80-ffb7a95ff2ee" => {
      title: "Suspension order without conditions",
      description: <<~DESCRIPTION.chomp
        Suspended by the General Teaching Council for England.

        Call the Teaching Regulation Agency (TRA) on 0207 593 5393 to check the conditions.
      DESCRIPTION
    },
  }.freeze


  def description
    SANCTIONS[alert_type_id][:description] if SANCTIONS[alert_type_id]
  end

  def title
    SANCTIONS[alert_type_id][:title] if SANCTIONS[alert_type_id]
  end

  def guilty_but_not_prohibited?
    alert_type_id == "7924fe90-483c-49f8-84fc-674feddba848"
  end
end
