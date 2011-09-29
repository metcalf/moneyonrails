module ActsAsProtected
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def instantiate(*args)
      record = super(*args)
      if(record.class.respond_to?(:allowed?))
        return nil unless record.class.allowed?(record)
      end
      record
    end
    
    def find_by_sql(*args)
      super(*args).compact
    end
    
    def find_with_associations(*args)
      super(*args).compact
    end
    
  end
end