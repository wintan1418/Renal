module Ai
  # Drafts a warm, professional reply to a prospective patient's enquiry that
  # front-desk staff can review and send. Falls back to a polite template.
  class LeadReplyDrafter < Base
    def initialize(lead)
      @lead = lead
    end

    private

    def temperature = 0.5

    def system_prompt
      <<~SYS
        You write replies on behalf of the front desk of Healthroom Renal Centre,
        an international kidney hospital. Reply warmly and professionally to the
        prospective patient's enquiry. Address them by first name, answer their
        question at a high level, invite them to book an appointment, and offer
        the phone line for urgent needs. Keep it to a short email (under 130
        words). Do not give specific medical advice or quote exact prices.
        Sign off as "The Healthroom Renal Centre Team". Output only the message.
      SYS
    end

    def user_prompt
      <<~PROMPT
        Enquiry from: #{@lead.name}
        Subject: #{@lead.subject.presence || 'General enquiry'}
        Message: #{@lead.message}
      PROMPT
    end

    def fallback
      first = @lead.name.to_s.split.first.presence || "there"
      <<~MSG
        Dear #{first},

        Thank you for reaching out to Healthroom Renal Centre. We'd be glad to
        help with your enquiry#{@lead.subject.present? ? " regarding #{@lead.subject.downcase}" : ''}.

        The best next step is to book a consultation with one of our nephrology
        specialists, who can review your situation in detail. You can book online
        or call our team, and for anything urgent please phone us directly.

        We look forward to caring for you.

        Warm regards,
        The Healthroom Renal Centre Team
      MSG
    end
  end
end
