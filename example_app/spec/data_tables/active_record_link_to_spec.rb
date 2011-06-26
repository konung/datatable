require 'spec_helper'

describe '' do

  before do
    Object.send(:remove_const, :Foo) rescue nil
  end

  it 'link_to should not be available as a class method' do
    class Foo
      def self.test
        link_to
      end
    end
    lambda { Foo.test }.should_not raise_error(NoMethodError)
  end

  it 'make sure link_to is accessible directly ' do
    defined?(ActionController::Base.helpers.link_to).should be_true
  end

  it "should not work" do
    class Foo
      def self.link_to(*args)
        ActionController::Base.helpers.link_to(args)
      end
    end
    lambda { Foo.link_to "foo", "bar" }.should raise_error
  end

  it "should work" do
    class Foo
      extend ActionView::Helpers::UrlHelper
      extend ActionView::Helpers::TagHelper
    end
    lambda { Foo.link_to "foo", "bar" }.should_not raise_error
  end

end
