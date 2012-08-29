# require 'apns'
# 
# APNS.host = 'gateway.sandbox.push.apple.com'
# APNS.pem = 'certificate/push.ios.vk.pem'
# APNS.port = 2195

class Device

  include MongoMapper::Document
  key :name, String, :required => true
  key :uuid, String, :required => true
  many :notifications

  validates_presence_of :name
  validates_presence_of :uuid

  # def push(category, message)
  #   puts "pushing!!"
  #   other = {:category => category, :system_id => 123, :remote_id => 456, :expires_at => (Time.now+(5*60)).to_i}
  #   APNS.send_notification(uuid, :alert => message, :other => other)
  #   
  # end
end
