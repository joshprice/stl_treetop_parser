require 'treetop'
require 'stl'
require 'ap'

describe "STL treetop parser" do
  before do
    @p = STLParser.new
  end
  
  describe "solid with no facets" do
    it "should parse an anonymous solid" do
      result = @p.parse("solid \nendsolid \n")
      result.should_not be_nil
      result.solid_start.solid_name.text_value.should == ""
    end

    it "should handle EOF on last line" do
      result = @p.parse("solid \nendsolid ")
      result.should_not be_nil
      result.solid_start.solid_name.text_value.should == ""
    end

    it "should parse a named solid" do
      result = @p.parse("solid name\nendsolid name\n")
      result.should_not be_nil
      result.solid_start.solid_name.text_value.should == "name"
      result.solid_end.solid_name.text_value.should == "name"
    end

    it "should have no facets" do
      result = @p.parse("solid name\nendsolid name\n")
      result.should_not be_nil
      #puts result.inspect
      result.solid.facet.should be_nil
    end
  end

  describe "named solid with one facet but no outer loop" do
    it "should parse facet" do
      result = @p.parse("solid onefacet\nfacet normal 0.0 0.0 1.0\nendfacet\nendsolid onefacet")
      result.should_not be_nil
      ap result.methods.sort
      result.facet.text_value.should_not be_nil
    end

  end
end
