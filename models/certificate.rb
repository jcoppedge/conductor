class Certificate
  include MongoMapper::Document

  key :name, String, :required => true
  key :contents, String, :required => true
  timestamps!

  before_save :write_file

  def write_file
    File.open(file_path, 'w') do |f|
      f.write contents
    end
  end

  def file_name
    "#{name.gsub(/[\x00\/\\:\*\?\"<>\|]/, '_')}.pem"
  end

  def file_path
    "#{Dir.pwd}/certificate/#{file_name}"
  end

  class << self
    def list_files
      Dir.glob('certificate/*.pem')
    end
  end
end