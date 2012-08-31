class Device
  include MongoMapper::Document

  key :name, String, :required => true
  key :uuid, String, :required => true
  timestamps!

  many :notifications,
    :dependent => :destroy

  validates_presence_of :name
  validates_presence_of :uuid

  def obfuscated_uuid
    "#{uuid[0,5]}..#{uuid[-5,5]}"
  end
end
