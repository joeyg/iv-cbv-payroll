class ApplicantMailer < ApplicationMailer
  attr_reader :email_address

  def invitation_email
    @link = params[:link]
    mail(to: params[:email_address], subject: I18n.t("applicant_mailer.invitation_email.subject"))
  end

  def send_pdf_to_caseworker(email_address, case_number)
    attachments["income_verification.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(template: "cbv_flows/summary", formats: [ :pdf ])
    )
    mail(to: email_address, subject: I18n.t("applicant_mailer.send_pdf_to_caseworker.subject", case_number: case_number))
  end
end
