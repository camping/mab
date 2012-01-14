module Mab
  class SimpleBuilder
    include Mixin

    def initialize(assigns = {}, helper = nil, &blk)
      @_helper = helper
      @_result = []

      assigns.each do |key, value|
        instance_variable_set(:"@#{key}", value)
      end

      if helper
        helper.instance_variables.each do |var|
          instance_variable_set(var, helper.instance_variable_get(var))
        end
      end

      capture(&blk) if blk
    end

    def capture(&blk)
      @_result << mab(&blk)
    end

    def to_s; @_result.join end

    def method_missing(name, *args, &blk)
      if @_helper && @_helper.respond_to?(name, true)
        @_helper.send(name, *args, &blk)
      else
        super
      end
    end
  end

  class Builder < SimpleBuilder
    include HTML5
  end

  class PrettyBuilder < Builder
    include Indentation
  end
end

