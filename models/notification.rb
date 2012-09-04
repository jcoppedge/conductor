require 'apns'

APNS.host = 'gateway.sandbox.push.apple.com'
APNS.port = 2195

class Notification
  include MongoMapper::Document

  key :message, String, :required => true
  key :category, String, :required => true
  key :certificate, String
  timestamps!

  belongs_to :device

  validates_presence_of :message
  validates_presence_of :category

  def push
    begin
      other = {:category => category, :system_id => 123, :remote_id => 456, :expires_at => (Time.now+(5*60)).to_i}
      APNS.pem = certificate
      APNS.send_notification(device.uuid, :alert => message, :other => other)
    rescue OpenSSL::X509::CertificateError => e
      errors.add('certficate', "is invalid, #{e.message}")
    rescue Exception => e
      errors.add('certificate', "error, #{e.message}")
    end
  end

  def certificate=(c)
    self[:certificate] = c.file_path
  end

  def pretty_certificate
    certificate and certificate.gsub(/.*\/certificate\//, '')
  end
end
