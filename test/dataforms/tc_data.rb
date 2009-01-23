#!/usr/bin/ruby

$:.unshift File::dirname(__FILE__) + '/../../lib'

require 'test/unit'
require "yaml"
require 'xmpp4r/dataforms'
include Jabber

class DataFormsTest < Test::Unit::TestCase

  def test_create_defaults
    v = Dataforms::XDataTitle.new
    assert_nil(v.title)
    assert_equal("", v.to_s)
  
    v = Dataforms::XDataInstructions.new
    assert_nil(v.instructions)
    assert_equal("", v.to_s)
  
    v = Dataforms::XDataField.new
    assert_nil(v.label)
    assert_nil(v.var)
    assert_nil(v.type)
    assert_equal(false, v.required?)
    assert_equal([], v.values)
    assert_equal({}, v.options)
  
    v = Dataforms::XData.new
    assert_equal([], v.fields)
    assert_nil(v.type)
  end

  def test_create
    v = Dataforms::XDataTitle.new "This is the title"
    assert_equal("This is the title",v.title)
    assert_equal("This is the title", v.to_s)

    v = Dataforms::XDataInstructions.new "Instructions"
    assert_equal("Instructions",v.instructions)
    assert_equal("Instructions", v.to_s)

    f = Dataforms::XDataField.new "botname", :text_single
    assert_nil(f.label)
    assert_equal("botname", f.var)
    assert_equal(:text_single, f.type)
    assert_equal(false, f.required?)
    assert_equal([], f.values)
    assert_equal({}, f.options)
    f.label = "The name of your bot"
    assert_equal("The name of your bot", f.label)
    [:boolean, :fixed, :hidden, :jid_multi, :jid_single,
     :list_multi, :list_single, :text_multi, :text_private,
     :text_single].each do |type|
      f.type = type
      assert_equal(type, f.type)
    end
    f.type = :wrong_type
    assert_nil(f.type)
    f.required= true
    assert_equal(true, f.required?)
    f.values = ["the value"]
    assert_equal(["the value"], f.values)
    f.options = { "option 1" => "Label 1", "option 2" => "Label 2", "option 3" => nil }
    assert_equal({ "option 1" => "Label 1", "option 2" => "Label 2", "option 3" => nil }, f.options)


    f = Dataforms::XDataField.new "test", :text_single
    v = Dataforms::XData.new :form
    assert_equal([], v.fields)
    assert_equal(:form, v.type)
    [:form, :result, :submit, :cancel].each do |type|
      v.type = type
      assert_equal(type, v.type)
    end
    v.add f
    assert_equal(f, v.field('test'))
    assert_nil(v.field('wrong field'))
    assert_equal([f], v.fields)
   end

  def test_should_fill_in_form_correctly_when_passed_hash
    
    input_yml = "#{File.dirname(__FILE__)}/fixtures/form_fields_and_values.yml"
    ex_xml = "#{File.dirname(__FILE__)}/fixtures/form_fields_and_values.xml"
    
    input_hsh = open(input_yml) {|f| YAML.load(f)} 
    input_f_and_v = Dictionary[ :student,    input_hsh[:student], 
                                :date,       input_hsh[:date], 
                                :session_id, input_hsh[:session_id],
                                :question,   input_hsh[:question],
                                :subjects,   input_hsh[:subjects] ]
    
 	  form = Jabber::Dataforms::XData.new
 	  form.fill_form input_f_and_v
 	  
 	  formatter = REXML::Formatters::Pretty.new 
 	  generated_xml = String.new
 	  expected_xml = String.new    

 	  formatter.write(form.root, generated_xml) 	  
    formatter.write(REXML::Document.new(File.open(ex_xml)), expected_xml)

    assert_equal(expected_xml, generated_xml)
  end

  def test_should_return_a_hash_of_field_names_and_values
    ex_yml = "#{File.dirname(__FILE__)}/fixtures/names_and_values.yml"
    ex_hsh = open(ex_yml) {|f| YAML.load(f)} 
    expected_f_and_v = Dictionary[ :name,             ex_hsh[:name], 
                                   :address,          ex_hsh[:address], 
                                   :valued_qualities, ex_hsh[:valued_qualities] ]
    
    form = Jabber::Dataforms::XData.new
    form << ::Jabber::Dataforms::XDataField.new(:name, :text_single)
    form.children[0].values = ("Barak Obama")
    form << ::Jabber::Dataforms::XDataField.new(:address, :text_multi)
    form.children[1].values = ("White House\nWashington\nUSA")
    form << ::Jabber::Dataforms::XDataField.new(:valued_qualities, :list_multi)
    form.children[2].values = (["Handsome", "Persuasive", "Well-groomed", "Charismatic"])
    
    generated_f_and_v = form.fields_and_values
    
    assert_equal(expected_f_and_v, generated_f_and_v)
  end


end
