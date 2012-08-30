class Device
  include MongoMapper::Document

  key :name, String, :required => true
  key :uuid, String, :required => true
  timestamps!

  many :notifications,
    :dependent => :destroy

  validates_presence_of :name
  validates_presence_of :uuid

end
