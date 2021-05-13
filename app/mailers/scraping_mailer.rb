class ScrapingMailer < ApplicationMailer
  default from: '"Teqis Admin" <no-reply@teqis.club>'

  def tournament_email(nbr_successful, nbr_total, csv)
    @nbr_successful = nbr_successful
    @nbr_total = nbr_total
    attachments['tournament_scraping_report.csv'] = {mime_type: 'text/csv', content: csv}
    emails = ['rollus.jeremy@gmail.com', 'rollus.o@gmail.com']
    mail(to: emails, subject: 'Rapport Hebdomadaire - Scraping Tournois')
  end
end