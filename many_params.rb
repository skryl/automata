module ManyParams

  module ClassMethods
    def init_params(*params)
      @init_params = params
    end

    def get_init_params 
      @init_params || []
    end

    def validated_params(*params)
      @validated_params = params
    end

    def get_validated_params
      @validated_params || [] 
    end
  end

  def parse_init_params(params)
    self.class.get_init_params.each do |param|
      value = \
        if params.include?(param) && !params[param].nil?
          params[param] 
        elsif self.class.const_defined?('Defaults')
          self.class::Defaults.const_get(param.to_s.upcase)
        end
      # raise "Missing required parameter '#{param}'" unless value
      instance_variable_set("@#{param}", value) 
      self.class.send(:attr_reader, param)
    end
  end

  def valid_params?
    self.class.get_validated_params.all? { |p| self.send("valid_#{p}?") }
  end

  def invalid_params
    self.class.get_validated_params.reject { |p| self.send("valid_#{p}?") }
  end

  def inspect_instance_vars
    instance_variables.inject("") { |s, ivar| s << "  #{ivar} => #{eval(ivar.to_s).inspect}\n" }
  end

  def self.included(klass)
    klass.extend ClassMethods
  end

end
