require 'spec_helper'

describe "ruby_aocolumns" do

  describe "using active relation" do

    it "should have tests" do
      pending
    end

  end

  describe "using raw sql" do

    before do
      Object.send(:remove_const, :T) rescue nil
      class T < Datatable::Base
        sql <<-SQL
          SELECT
            orders.id,
            orders.order_number
          FROM
            orders
        SQL
        columns(
          {'orders.id' => {:type => :integer}},
          {'orders.order_number' => {:type => :string}}
        )
      end
      assign(:datatable, T)
    end

    it 'should return nil for all columns when no properties are set' do
      T.columns(
        { 'orders.id'           => {:type => :integer }},
        { 'orders.order_number' => {:type => :string  }}
      )
      helper.send(:ruby_aocolumns)[0].should be_nil
      helper.send(:ruby_aocolumns)[1].should be_nil
    end

    it 'should support asSorting' do
      T.columns(
        {           'orders.id' => {:type => :integer, :asSorting => 'asc'   }},
        { 'orders.order_number' => {:type => :string,  :asSorting => 'desc'  }}
      )
      helper.send(:ruby_aocolumns)[0]['asSorting'].should == 'asc'
      helper.send(:ruby_aocolumns)[1]['asSorting'].should == 'desc'
    end

    it 'should support bSearchable' do
      T.columns(
        {           'orders.id' => {:type => :integer, :bSearchable => true   }},
        { 'orders.order_number' => {:type => :string,  :bSearchable => false  }}
      )
      helper.send(:ruby_aocolumns)[0]['bSearchable'].should == true
      helper.send(:ruby_aocolumns)[1]['bSearchable'].should == false
    end

    it 'should support bSortable' do
      T.columns(
        {           'orders.id' => {:type => :integer, :bSortable => true   }},
        { 'orders.order_number' => {:type => :string,  :bSortable => false  }}
      )
      helper.send(:ruby_aocolumns)[0]['bSortable'].should == true
      helper.send(:ruby_aocolumns)[1]['bSortable'].should == false
    end

    it 'should support bUseRendered' do
      T.columns(
        {           'orders.id' => {:type => :integer, :bUseRendered => true   }},
        { 'orders.order_number' => {:type => :string,  :bUseRendered => false  }}
      )
      helper.send(:ruby_aocolumns)[0]['bUseRendered'].should == true
      helper.send(:ruby_aocolumns)[1]['bUseRendered'].should == false
    end

    it 'should support bVisible' do
      T.columns(
        {           'orders.id' => {:type => :integer, :bVisible => false }},
        { 'orders.order_number' => {:type => :string                      }}
      )
      helper.send(:ruby_aocolumns)[0]['bVisible'].should_not be_nil
      helper.send(:ruby_aocolumns)[0]['bVisible'].should be_false
      helper.send(:ruby_aocolumns)[1].should be_nil
    end

    it 'should support fnRender' do
      T.columns(
        {           'orders.id' => {:type => :integer, :fnRender => "function(oObj){'foo'}" }},
        { 'orders.order_number' => {:type => :string,  :fnRender => "function(oObj){'bar'}" }}
      )
      helper.send(:ruby_aocolumns)[0]['fnRender'].should == "function(oObj){'foo'}"
      helper.send(:ruby_aocolumns)[1]['fnRender'].should == "function(oObj){'bar'}"
    end

    it 'should support iDataSort' do
      T.columns(
        {           'orders.id' => {:type => :integer, :iDataSort => 1 }},
        { 'orders.order_number' => {:type => :string,  :iDataSort => 0 }}
      )
      helper.send(:ruby_aocolumns)[0]['iDataSort'].should == 1
      helper.send(:ruby_aocolumns)[1]['iDataSort'].should == 0
    end

    it 'should support mDataProp' do
      pending "need to understand what it does before I can write a spec for it"
    end

    it 'should support sClass' do
      T.columns(
        {           'orders.id' => {:type => :integer, :sClass => 'foo' }},
        { 'orders.order_number' => {:type => :string,  :sClass => 'bar' }}
      )
      helper.send(:ruby_aocolumns)[0]['sClass'].should == 'foo'
      helper.send(:ruby_aocolumns)[1]['sClass'].should == 'bar'
    end

    it 'should support sDefaultContent' do
      T.columns(
        {           'orders.id' => {:type => :integer, :sDefaultContent => 'foo' }},
        { 'orders.order_number' => {:type => :string,  :sDefaultContent => 'bar' }}
      )
      helper.send(:ruby_aocolumns)[0]['sDefaultContent'].should == 'foo'
      helper.send(:ruby_aocolumns)[1]['sDefaultContent'].should == 'bar'
    end

    it 'should support sName' do
      T.columns(
        {           'orders.id' => {:type => :integer, :sName => 'foo' }},
        { 'orders.order_number' => {:type => :string,  :sName => 'bar' }}
      )
      helper.send(:ruby_aocolumns)[0]['sName'].should == 'foo'
      helper.send(:ruby_aocolumns)[1]['sName'].should == 'bar'
    end

    it "should support sSortDataType" do
      pending "figure out if this is relevant for server side sorting?"
    end

    it 'should support sTitle' do
      T.columns(
        {           'orders.id' => {:type => :integer, :sTitle => 'foo' }},
        { 'orders.order_number' => {:type => :string,  :sTitle => 'bar' }}
      )
      helper.send(:ruby_aocolumns)[0]['sTitle'].should == 'foo'
      helper.send(:ruby_aocolumns)[1]['sTitle'].should == 'bar'
    end

    it 'should support sType' do
      T.columns(
        {           'orders.id' => {:type => :integer, :sType => 'string' }},
        { 'orders.order_number' => {:type => :string,  :sType => 'numeric' }}
      )
      helper.send(:ruby_aocolumns)[0]['sType'].should == 'string'
      helper.send(:ruby_aocolumns)[1]['sType'].should == 'numeric'
    end

    it 'should support sWidth' do
      T.columns(
        {           'orders.id' => {:type => :integer, :sWidth => '42px' }},
        { 'orders.order_number' => {:type => :string,  :sWidth => '42%' }}
      )
      helper.send(:ruby_aocolumns)[0]['sWidth'].should == '42px'
      helper.send(:ruby_aocolumns)[1]['sWidth'].should == '42%'
    end

  end

  describe "aocolumn" do
    before do
      Object.send(:remove_const, :T) rescue nil
      class T < Datatable::Base
        sql <<-SQL
          SELECT
            orders.id,
            orders.order_number
          FROM
            orders
        SQL
        columns(
          {'orders.id' => {:type => :integer, :fnRender => "function(oObj){'foo'}" }},
          {'orders.order_number' => {:type => :string}}
        )
      end
      assign(:datatable, T)
    end

    it "should render functions properly" do
      helper.send(:aocolumns_text).should contain("function(oObj){'foo'}")
    end

    it "linkto should replace fnRender" do
      T.columns(
        {'orders.id' => {:type => :integer, :fnRender => "function(oObj){'bar'}", :link_to => link_to('{{0}}', order_path('{{0}}')) }},
        {'orders.order_number' => {:type => :string, :bVisible => false}}
      )
      true.should_not be_false
    end

  end

end
