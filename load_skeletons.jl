"""
Loads graph from file (saved in MetaGraph format)
returns a road network.

    `load_rn(filename)`

"""
function load_rn(filename)
    mg = loadgraph(filename, MGFormat())
    g = skel2rn(mg)
end

