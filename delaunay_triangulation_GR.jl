using GR

function triangulation_edges_gr(points_alpha)
    n_triangles, triangles = delaunay(points_alpha[:,1], points_alpha[:,2])
    n_edges = 3*n_triangles 
    
    edges = Array{Tuple{Int64,Int64}}(undef, n_edges)
    e_counter = 0
    for i in 1:n_triangles
        
        t = triangles[i,:]    
        
        e_counter += 1
        ed = (t[1], t[2])
        edges[e_counter] = ed
        
        e_counter += 1
        ed = (t[2], t[3])
        edges[e_counter] = ed
        
        e_counter += 1
        ed = (t[3], t[1])
        edges[e_counter] = ed
    end
    edges
end
