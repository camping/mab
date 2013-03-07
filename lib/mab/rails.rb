module Mab
  class RailsBuilder < Builder
    def content_for(*args)
      blk = proc do |*a|
        mab { yield(*a) }.html_safe
      end if block_given?

      @_helper.send(:content_for, *args, &blk)
    end
  end

  class RailsHandler
    def call(template)
      "::Mab::RailsBuilder.new({}, self) { #{template.source} }.to_s"
    end
  end

  ::ActionView::Template.register_template_handler :mab, RailsHandler.new
end

