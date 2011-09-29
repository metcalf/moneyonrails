ActiveRecord::Acts::Tree.send(:include, ActsAsTreeOptions)

module ActsAsTreeOptions
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      class << self
        alias_method_chain :acts_as_tree, :options
      end
    end
  end
  
  module ClassMethods
    
    def acts_as_tree_with_options(options = {})
      configuration = { :foreign_key => "parent_id", :order => nil, :counter_cache => nil }
      configuration.update(options) if options.is_a?(Hash)
      
      if(options[:children])
        standard_params = { :class_name => name, :foreign_key => configuration[:foreign_key], :order => configuration[:order], :dependent => :destroy}
        children.each_pair do |option, parameters|
          has_many((option.to_s + "_children").intern, standard_params + parameters)
        end
        options.delete(:children)
      end
      
      acts_as_tree_without_options
    end
    
    private 
    
    def add_has_many
      
    end
    
  end
end