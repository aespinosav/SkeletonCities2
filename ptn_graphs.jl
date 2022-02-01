    # There is a question about what to do with the original lables of the vertices... if using metagraphs, then maybe keep a dictionary of the labeling correspondence?

#=
using MetaGraphs
=#


"""
Converts a collection of paths (PT routes) into the L-space representation, returns MetaGraph of PT network
"""
function to_l_space(g, lines)

    num_lines = length(lines)
    edges_per_line = Array{Int64,1}(undef, num_lines)

    L_vertices = sort(unique(vcat(lines...)))
    n_verts = length(L_vertices)

    vertex_labels = Dict(zip(L_vertices, 1:n_verts))
    reverse_labels = Dict(zip(1:n_verts, L_vertices))

    L_edges = Set{Tuple{Int64,Int64}}()
    for (i,l) in enumerate(lines)
        num_edges = length(l)-1
        for j in 1:num_edges
            ed_tup = (l[j], l[j+1])
            push!(L_edges, ed_tup)
        end
    end
    n_edges = length(L_edges)

    edges_new_labels = Array{Tuple{Int64,Int64},1}(undef, n_edges)
    for (i,edge) in enumerate(L_edges)
        s, t = edge
        s_new =  vertex_labels[s]
        t_new =  vertex_labels[t]
        edges_new_labels[i] = (s_new, t_new)
    end

    mg = MetaGraph()
    #Dictionary with labels referring back to g
    set_prop!(mg, :node_labels, reverse_labels)
    weightfield!(mg, :length)

    for v in 1:n_verts
        add_vertex!(mg)

        r_lab = reverse_labels[v]
        pos = get_prop(g, r_lab, :position)
        set_prop!(mg, v, :position, pos)
    end
    for j in 1:n_edges
        ed_new = edges_new_labels[j]
        ed = (reverse_labels[ed_new[1]], reverse_labels[ed_new[2]])
        len = get_prop(g, ed..., :length)
        add_edge!(mg, ed_new)
        set_prop!(mg, ed..., :length, len)
    end
    mg
end


"""
Converts a collection of paths (PT routes) into the P-space representation
of a PTN.
"""
function to_p_space(g, lines)
    num_lines = length(lines) 

    L_vertices = sort(unique(vcat(lines...)))
    n_verts = length(L_vertices)

    vertex_labels = Dict(zip(L_vertices, 1:n_verts))
    reverse_labels = Dict(zip(1:n_verts, L_vertices))

    lines_new_labels = copy(lines)
    for i in 1:num_lines
        lines_new_labels[i] = map(x -> vertex_labels[x], lines[i])
    end

    mg = MetaGraph()
    #Dictionary with labels referring back to g
    set_prop!(mg, :node_labels, reverse_labels)
    weightfield!(mg, :length)

    for v in 1:n_verts
        add_vertex!(mg)
        r_lab = reverse_labels[v]
        pos = get_prop(g, r_lab, :position)
        set_prop!(mg, v, :position, pos)
    end

    #L_edges = Set{Tuple{Int64,Int64}}()
    for l in lines_new_labels
        for (i, v1) in enumerate(l)
            for j in i+1:length(l)
                v2 = l[j]

                add_edge!(mg, v1, v2)
                #ed_tup = (v1, v2)
                #rev_ed_tup = (v2, v1)
                #if !in(rev_ed_tup, L_edges)
                #    push!(L_edges, ed_tup)
                #end
            end
        end
    end
    #for ed_new in L_edges
    #    add_edge!(mg, ed_new)
    #end
    mg
end
