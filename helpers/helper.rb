helpers do
  def errors_for(object, message='')
    return if object.nil?
    unless object.errors.empty?
      haml_tag :div do
        if message.empty?
          haml_tag :span, "Problem adding #{object.class.name.humanize}"
        else
          haml_tag :span, message
        end
      
        haml_tag :ul do
          object.errors.messages.each do |key, value|
            haml_tag :li, "#{key.to_s.humanize} #{value.first}"
          end
        end
      end
    end

  end
end