require 'treetop'
require 'stl'

describe "STL" do
  before do
    @p = STLParser.new
  end
  
  describe "solid with no facets" do
    it "should parse an anonymous solid" do
      solid = @p.parse("solid \nendsolid \n")
      solid.should_not be_nil
      solid.name.should == ""
      solid.solid_start.text_value.should == "solid \n"
      solid.solid_start.solid_name.text_value.should == ""
      solid.solid_end.text_value.should == "endsolid \n"
    end

    it "should handle EOF on last line" do
      solid = @p.parse("solid \nendsolid ")
      solid.should_not be_nil
      solid.solid_start.solid_name.text_value.should == ""
    end

    it "should parse a named solid" do
      solid = @p.parse("solid name\nendsolid name\n")
      solid.should_not be_nil
      solid.name.should == "name"
      solid.solid_start.solid_name.text_value.should == "name"
      solid.solid_end.solid_name.text_value.should == "name"
    end

    it "should have no facets" do
      solid = @p.parse("solid name\nendsolid name\n")
      solid.should_not be_nil
      solid.facets.should == []
      solid.facet.text_value.should == ""
      solid.facet.elements.should == []
    end
  end

  describe "named solid with one facet but no outer loop" do
    it "should parse facet" do
      solid = @p.parse("solid onefacet\nfacet normal -1.0 0.0 1.0\nendfacet\nendsolid onefacet")
      solid.should_not be_nil
      solid.facets.size.should == 1
      solid.facets[0].normal.should == [-1.0, 0.0, 1.0]
      solid.facets[0].text_value.should_not be_nil
      solid.facets[0].facet_start.ni.value.should == -1.0
      solid.facets[0].facet_start.nj.value.should == 0.0
      solid.facets[0].facet_start.nk.value.should == 1.0
      solid.facets[0].outer_loop.text_value.should == ""
    end
  end

  describe "named solid with one facet and an outer loop" do
    it "should parse outer loop with no vertices" do
      solid = @p.parse("solid onefacet\nfacet normal -1.0 0.0 1.0\n  outer loop\nendloop\nendfacet\nendsolid onefacet")
      solid.facets[0].normal.should == [-1.0, 0.0, 1.0]
      solid.facets[0].outer_loop.text_value.should_not == ""
      solid.facets[0].outer_loop.text_value.should == "outer loop\nendloop\n"
      solid.facets[0].outer_loop.vertex.elements.should == []
    end

    it "should parse single vertex in outer loop" do
      solid = @p.parse("solid onefacet\nfacet normal -1.0 0.0 1.0\n  outer loop\n    vertex -1.0 0.0 1.0\nendloop\nendfacet\nendsolid onefacet")
      solid.should_not be_nil
      solid.facets[0].vertices.size.should == 1
      solid.facets[0].vertices[0].value.should == [-1.0, 0.0, 1.0]
      solid.facets[0].outer_loop.vertex.text_value.should == "vertex -1.0 0.0 1.0\n"
      solid.facets[0].outer_loop.vertex.elements[0].vx.value.should == -1.0
      solid.facets[0].outer_loop.vertex.elements[0].vy.value.should == 0.0
      solid.facets[0].outer_loop.vertex.elements[0].vz.value.should == 1.0
    end

    it "should parse multiple vertices in outer loop" do
      solid = @p.parse("solid onefacet\nfacet normal -1.0 0.0 1.0\n  outer loop\n    vertex -1.0 0.0 1.0\n    vertex -2.0 0.0 2.0\nendloop\nendfacet\nendsolid onefacet")
      solid.should_not be_nil
      solid.facets[0].vertices.size.should == 2
      solid.facets[0].vertices[0].value.should == [-1.0, 0.0, 1.0]
      solid.facets[0].vertices[1].value.should == [-2.0, 0.0, 2.0]
    end
  end
  
  describe "named solid with multiple facets" do
    before do
      @stl_doc = <<-STL
        solid rect
        facet normal 0.0 0.0 -1.0
           outer loop
              vertex 116.377952755906 66.1023622047244 0.0
              vertex 0.0 0.0 0.0
              vertex 0.0 66.1023622047244 0.0
           endloop
        endfacet
        facet normal 0.0 0.0 -1.0
           outer loop
              vertex 0.0 0.0 0.0
              vertex 116.377952755906 116.377952755906 0.0
              vertex 116.377952755906 0.0 0.0
           endloop
        endfacet
        endsolid rect
      STL
    end
    
    it "should parse solid with arbitrary indentation (the compact way)" do
      solid = @p.parse(@stl_doc)
      solid.name.should == "rect"
      solid.facets.size.should == 2
      solid.facets[0].normal.should == [0.0, 0.0, -1.0]
      solid.facets[0].vertices.size.should == 3
      solid.facets[0].vertices[0].value.should == [116.377952755906, 66.1023622047244, 0.0]
      solid.facets[0].vertices[1].value.should == [0.0, 0.0, 0.0]
      solid.facets[0].vertices[2].value.should == [0.0, 66.1023622047244, 0.0]

      solid.facets[1].normal.should == [0.0, 0.0, -1.0]
      solid.facets[1].vertices.size.should == 3
      solid.facets[1].vertices[0].value.should == [0.0, 0.0, 0.0]
      solid.facets[1].vertices[1].value.should == [116.377952755906, 116.377952755906, 0.0]
      solid.facets[1].vertices[2].value.should == [116.377952755906, 0.0, 0.0]
    end
    
    it "should parse solid with arbitrary indentation (the long way)" do
      solid = @p.parse(@stl_doc)
      solid.should_not be_nil
      facets = solid.facet.elements
      facets[0].text_value.should_not be_nil
      facets[0].facet_start.ni.value.should == 0.0
      facets[0].facet_start.nj.value.should == 0.0
      facets[0].facet_start.nk.value.should == -1.0
      facets[0].outer_loop.vertex.elements[0].vx.value.should == 116.377952755906
      facets[0].outer_loop.vertex.elements[0].vy.value.should == 66.1023622047244
      facets[0].outer_loop.vertex.elements[0].vz.value.should == 0.0
      facets[0].outer_loop.vertex.elements[1].vx.value.should == 0.0
      facets[0].outer_loop.vertex.elements[1].vy.value.should == 0.0
      facets[0].outer_loop.vertex.elements[1].vz.value.should == 0.0
      facets[0].outer_loop.vertex.elements[2].vx.value.should == 0.0
      facets[0].outer_loop.vertex.elements[2].vy.value.should == 66.1023622047244
      facets[0].outer_loop.vertex.elements[2].vz.value.should == 0.0
      facets[1].text_value.should_not be_nil
      facets[1].facet_start.ni.value.should == 0.0
      facets[1].facet_start.nj.value.should == 0.0
      facets[1].facet_start.nk.value.should == -1.0
      facets[1].outer_loop.vertex.elements[0].vx.value.should == 0.0
      facets[1].outer_loop.vertex.elements[0].vy.value.should == 0.0
      facets[1].outer_loop.vertex.elements[0].vz.value.should == 0.0
      facets[1].outer_loop.vertex.elements[1].vx.value.should == 116.377952755906
      facets[1].outer_loop.vertex.elements[1].vy.value.should == 116.377952755906
      facets[1].outer_loop.vertex.elements[1].vz.value.should == 0.0
      facets[1].outer_loop.vertex.elements[2].vx.value.should == 116.377952755906
      facets[1].outer_loop.vertex.elements[2].vy.value.should == 0.0
      facets[1].outer_loop.vertex.elements[2].vz.value.should == 0.0
    end
  end
end
