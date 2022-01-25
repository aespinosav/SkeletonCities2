"""
Convert αβ-network in metagraph format to 
RoadNetwork type.

Returns RoadNetwork
"""
function skel2rn(mg::MetaGraph, res_constant=1)
    
    pos = get_node_pos(mg)
    
    g = SimpleDiGraph(mg.graph)
    
    as = zeros(ne(g))
    for (i,ed) in enumerate(edges(g))
        len = get_prop(mg, ed.src, ed.dst, :length)
        as[i] = len
    end
    
    edge_params = Dict()
    node_params = Dict()
    
    edge_params[:a] = as
    edge_params[:b] = resource_allocation(g, as, constant=res_constant)
    
    node_params[:pos] = pos
    
    RoadNetwork(g, edge_params, node_params)
end
