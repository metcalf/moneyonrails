class AlertType < ActiveRecord::Base
  belongs_to :alert_parameter_type
  
  def body(params)
    replace(self[:body], params)
  end
  
  def subject(params)
    replace(self[:subject], params)
  end
  
  protected
  def replace(text, params)
    params.each do |param|
      text.gsub!("$" + param.alert_parameter_type.name, param.value)
    end
    text
  end
end