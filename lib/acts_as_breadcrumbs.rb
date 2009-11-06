# Copyright (c) 2007-2009 Flinn Mueller
# Released under the MIT License.  See the MIT-LICENSE file for more details.

module ActiveRecord #:nodoc:
  module Acts #:nodoc:

    # ActsAsBreadcrumbs - In Hansel & Gretel, Hansel drops breadcrumbs along the trail through 
    # the forrest to find their way back home. Like Hansel, this plugin adds a breadcrumbs trail
    # attribute based on a base attribute.
    module Breadcrumbs
      def self.included(base) # :nodoc:
        base.extend Crummy
      end

      module Crummy
        # acts_as_breadcrumbs creates a cached trail of breadcrumbs based
        # on acts_as_tree methods, parent and children
        #
        # Options are:
        # * <tt>:attr</tt>: Attribute name for your breadcrumbs attribute, defaults to :breadcrumbs
        # * <tt>:basename</tt>: Basename attribute to build the breadcrumbs trail, defaults to :name
        # * <tt>:separator</tt>: Set a separator string, defaults to ":"
        # * <tt>:include_root</tt>: Include the root Boolean,
        #
        # Examples:
        #
        # class WebPage < ActiveRecord::Base
        #   acts_as_breadcrumbs :url, :basename => :slug, :separator => "/"
        #   acts_as_breadcrumbs :basename => :title, :separator => "&nbsp;&gt;&nbsp;"
        # end
        #
        # web_page.url         #=> "foo/bar/baz"
        # web_page.breadcrumbs #=> "Foo&nbsp;&gt;&nbsp;Bar&nbsp;&gt;&nbsp;Baz" # "Foo > Bar > Baz"
        #
        # class Location < ActiveRecord::Base
        #   acts_as_breadcrumbs :location_string
        # end
        #
        # location.location_string #=> "HQ:FL01:RM03"
        #
        # class Soldier < ActiveRecord::Base
        #   acts_as_breadcrumbs :chain_o_command, :separator => " > "
        # end
        #
        # soldier.chain_o_command #=> "General Hailstone > Colonel Stanley > LTC Mueller"
        #
        def acts_as_breadcrumbs(*args)
          include InstanceMethods

          options = args.extract_options!
          options.reverse_merge!({ :basename => :name, :separator => ":", :include_root => true })
          attribute = args.first || :breadcrumbs

          self.send(:before_save, proc{ |record| record.set_breadcrumb_for(attribute, options) })
          self.send(:after_save, proc{ |record| record.update_breadcrumb_for(attribute, options) })
        end
      end

      module InstanceMethods
        def breadcrumb_for(attribute, options = {})
          crumbs = []

          if self.root?
            crumbs << self.send(options[:basename]) if options[:include_root]
          else
            crumbs << self.send(options[:basename])
            crumbs << self.parent.send(attribute)
          end

          crumbs = crumbs.collect{ |crumb| crumb unless crumb.blank? }.compact
          crumbs.reverse.join(options[:separator])
        end

        def set_breadcrumb_for(attribute, options = {})
          crumb = breadcrumb_for(attribute, options)
          self.send("#{attribute}=".to_sym, crumb) unless crumb.blank?
        end

        def update_breadcrumb_for(attribute, options = {})
          if self.send("#{options[:basename]}_changed?".to_sym)
            descendants.each do |node|
              node.class.update_all({ attribute => node.breadcrumb_for(attribute, options) }, :id => node.id)
            end
          end
        end

      end
    end
  end
end