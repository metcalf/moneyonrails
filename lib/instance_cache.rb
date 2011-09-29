module InstanceCache
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def init_caches(methods)
      class_eval do
            include InstanceCache::InstanceMethods
      end
      methods.each { |method| init_cache(method) }
    end
    
    def init_cache(method)
      
      definition = "def cached_#{method.to_s}(*args); @cache ||= {}; @cache[:#{method.to_s}] ||= not_cached_#{method.to_s}(*args); end"
      class_eval(definition)
      
      alias_method 'not_cached_' + method.to_s, method.to_s
      alias_method method.to_s, 'cached_' + method.to_s
      
    end
  end
  
  module InstanceMethods
    
    
    def expire_cache
      @cache = {}
    end
    
  end
end