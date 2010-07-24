STL Treetop Parser
==================

A nice little example of parsing nested multiline files with Treetop.

An STL file format represents 3D objects.

The treetop grammar doesn't yet return anything but `text_value` for each node but this could be extended to be a nicer structure.

File format
-----------

This is what an STL file looks like:

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
          vertex 116.377952755906 66.1023622047244 0.0
          vertex 116.377952755906 0.0 0.0
       endloop
    endfacet
    endsolid rect

[The STL file format spec](http://en.wikipedia.org/wiki/STL_%28file_format%29)

Specs
-----

Run the specs with

    spec stl_spec.rb --format specdoc