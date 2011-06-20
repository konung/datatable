require 'spec_helper'

describe 'How to?' do



  it 'should not work without any include' do
    class One
      def self.path
        orders_path
      end
    end

    lambda { One.path.should == '/orders' }.should raise_error(NameError)
  end

  it 'should be a module and have paths' do
    Rails.application.routes.url_helpers.class.should == Module
    Rails.application.routes.url_helpers.orders_path.should == '/orders'
  end

  it 'should work when called directly' do
    class Two
      def self.path
        Rails.application.routes.url_helpers.orders_path
      end
    end

    Two.path.should == '/orders' 
  end


  it 'the class method should fail with include, but the instance method should work' do
    class Three
      include Rails.application.routes.url_helpers
      def self.path
        orders_path
      end

      def path
        orders_path
      end
    end

    lambda { Three.path.should == '/orders' }.should raise_error(NameError)
    Three.new.path.should == '/orders' 
  end


  it 'using extend causes the same behavior as include' do
    # See actionpack/lib/action_dispatch/routing/route_set.rb:264
    # The url helpers are not just a normal Module
    class Three
      extend Rails.application.routes.url_helpers
      def self.path
        orders_path
      end

      def path
        orders_path
      end
    end

    lambda { Three.path.should == '/orders' }.should raise_error(NameError)
    Three.new.path.should == '/orders' 
  end



  it 'method missing' do

    class Four
      def self.path
        orders_path
      end


      def self.method_missing(symbol, *args, &block)
        if symbol.to_s =~ /(path|url)$/
          return Rails.application.routes.url_helpers.send(symbol, *args)
        end

        super(symbol, *args, &block)
      end
    end

    Four.path.should == '/orders'
    lambda { Four.undefined_method }.should raise_error(NameError)
  end

  it 'proposed solution' do

    class Base
      def self.method_missing(symbol, *args, &block)
        if symbol.to_s =~ /(path|url)$/
          return Rails.application.routes.url_helpers.send(symbol, *args)
        end

        super(symbol, *args, &block)
      end

    end

    class Five < Base

      def self.path
        orders_path 
      end

    end

    Five.path.should == '/orders'

  end


end
