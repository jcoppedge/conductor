require 'apns'

APNS.host = 'gateway.sandbox.push.apple.com'
APNS.pem = 'certificate/push.ios.vk.pem'
APNS.port = 2195

class Notification
  include MongoMapper::Document

  key :message, String, :required => true
  key :category, String, :required => true
  timestamps!

  belongs_to :device

  validates_presence_of :message
  validates_presence_of :category

  def push
    other = {:category => category, :system_id => 123, :remote_id => 456, :expires_at => (Time.now+(5*60)).to_i}
    APNS.send_notification(device.uuid, :alert => message, :other => other)
  end
end
