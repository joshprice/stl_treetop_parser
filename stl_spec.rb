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
      result.solid_start.text_value.should == "solid \n"
      result.solid_start.solid_name.text_value.should == ""
      result.solid_end.text_value.should == "endsolid \n"
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
      result.facet.text_value.should == ""
    end
  end

  describe "named solid with one facet but no outer loop" do
    it "should parse facet" do
      result = @p.parse("solid onefacet\nfacet normal -1.0 0.0 1.0\nendfacet\nendsolid onefacet")
      result.should_not be_nil
      facet = result.facet
      facet.text_value.should_not be_nil
      facet.facet_start.ni.text_value.should == "-1.0"
      facet.facet_start.nj.text_value.should == "0.0"
      facet.facet_start.nk.text_value.should == "1.0"
      facet.outer_loop.text_value.should == ""
    end
  end

  describe "named solid with one facet and an outer loop" do
    it "should parse outer loop with no vertices" do
      result = @p.parse("solid onefacet\nfacet normal -1.0 0.0 1.0\n  outer loop\nendloop\nendfacet\nendsolid onefacet")
      result.should_not be_nil
      facet = result.facet
      facet.text_value.should_not be_nil
      facet.facet_start.ni.text_value.should == "-1.0"
      facet.facet_start.nj.text_value.should == "0.0"
      facet.facet_start.nk.text_value.should == "1.0"
      facet.outer_loop.text_value.should_not == ""
      facet.outer_loop.text_value.should == "  outer loop\nendloop\n"
    end

    it "should parse single vertex in outer loop" do
      result = @p.parse("solid onefacet\nfacet normal -1.0 0.0 1.0\n  outer loop\n    vertex -1.0 0.0 1.0\nendloop\nendfacet\nendsolid onefacet")
      result.should_not be_nil
      result.facet.outer_loop.vertex.text_value.should == "    vertex -1.0 0.0 1.0\n"
      result.facet.outer_loop.vertex.elements[0].vx.text_value.should == "-1.0"
      result.facet.outer_loop.vertex.elements[0].vy.text_value.should == "0.0"
      result.facet.outer_loop.vertex.elements[0].vz.text_value.should == "1.0"
    end

    it "should parse multiple vertices in outer loop" do
      result = @p.parse("solid onefacet\nfacet normal -1.0 0.0 1.0\n  outer loop\n    vertex -1.0 0.0 1.0\n    vertex -2.0 0.0 2.0\nendloop\nendfacet\nendsolid onefacet")
      result.should_not be_nil
      result.facet.outer_loop.vertex.text_value.should == "    vertex -1.0 0.0 1.0\n    vertex -2.0 0.0 2.0\n"
      result.facet.outer_loop.vertex.elements[0].vx.text_value.should == "-1.0"
      result.facet.outer_loop.vertex.elements[0].vy.text_value.should == "0.0"
      result.facet.outer_loop.vertex.elements[0].vz.text_value.should == "1.0"
      result.facet.outer_loop.vertex.elements[1].vx.text_value.should == "-2.0"
      result.facet.outer_loop.vertex.elements[1].vy.text_value.should == "0.0"
      result.facet.outer_loop.vertex.elements[1].vz.text_value.should == "2.0"
    end
  end
end
