class StateMachine::AuditTrail::Backend::ActiveRecord < StateMachine::AuditTrail::Backend
  attr_accessor :context_to_log

  def initialize(transition_class, context_to_log = nil)
    self.context_to_log = context_to_log
    super transition_class
  end

  def log(object, event, from, to, timestamp = Time.now)
    # Let ActiveRecord manage the timestamp for us so it does the 
    # right thing with regards to timezones.
    params = {foreign_key_field(object) => object.id, :event => event, :from => from, :to => to}
    context = self.context_to_log
    if context.is_a? Array
      context.each { |c| params[c] = object.send(c) unless c.nil? }
    elsif !context.nil?
      params[context] = object.send(context)
    end
    transition_class.create(params)
  end

  def foreign_key_field(object)
    object.class.base_class.name.foreign_key.to_sym
  end
end
