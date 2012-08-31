class Certificate
  attr_accessor :file_name

  def self.raw_file_list
    Dir.glob('certificate/*.pem').collect{|f| f.gsub(/^certificate\//, '')}
  end

  def self.all
    Dir.glob('certificate/*.pem').collect do |f|
      Certificate.new :file_name => f.gsub(/^certificate\//, '')
    end
  end

  def self.find_by_file_name(file_name)
    if raw_file_list.include? file_name
      Certificate.new :file_name => file_name
    end
  end

  def initialize(options = {})
    @file_name = options[:file_name]||options["file_name"]
  end

  def file_path
    "#{Dir.pwd}/certificate/#{file_name}"
  end
  
  def new_record?
    not File.file? file_path
  end
end