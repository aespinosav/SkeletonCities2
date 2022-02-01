#=
using LinearAlgebra, LightGraphs, MetaGraphs
=#

"""
Checks if point 'p' is in the circle based region of points u and v
for given beta <= 1
"""
function in_C_1(p, u, v, β)
    axis_vector = v - u
    mag = norm(axis_vector)
    perp = [-vect[2], vect[1]] # perpendicular vector to axis_vector

    d = mag/β
    r = 0.5*d

    c1 = u + 0.5*axis_vector + sqrt(r^2 - (mag^2)/4)*(perp/mag)
    c2 = u + 0.5*axis_vector - sqrt(r^2 - (mag^2)/4)*(perp/mag)

    incircle_1 = norm(p - c1) < r
    incircle_2 = norm(p - c2) < r

    incircle_1 && incircle_2
end

"""
Checks if point 'p' is in the lune based region of points u and v,
for beta > 1.
"""
function in_C_2(p, u, v, beta)

    vect = v - u
    mag = norm(vect)

    unit_vect = vect/mag    #Unit vector that points from u -> v.

    perp = [-vect[2], vect[1]]

    r = beta*mag*0.5

    c1 = v - r*unit_vect    #Centre of circle that has u in its interior
    c2 = u + r*unit_vect    #Centre of circle that has v in its interior

    onright = sign(dot(perp, p - u)) > 0
    incircles = norm(p - c1) < r && norm(p - c2) < r
end

"""
Makes a beta skeleton from a set of points given as a 2D array of coordinates.
Function uses GR.delaunay for building triangulation
Default is for set of points to be given as a 2D array.
"""
function β_skeleton(points::Array{Float64,2}, β)

    if β <= 1
        in_C = in_C_1
    else
        in_C = in_C_2
    end

    N = size(points)[1] 
    g = SimpleGraph(N)

    possible_edges = triangulation_edges_gr(points)

    for ed in possible_edges
        index_u, index_v = ed
        u, v = points[index_u,:], points[index_v,:]

        isempty = true
        for index_p in 1:N
            if index_p != index_u && index_p != index_v

                p = points[index_p,:]
                if in_C(p,u,v,β)
                    isempty = false
                    break
                end
            end
        end
        if isempty
            add_edge!(g, index_u, index_v)
        end
    end
    g
end

function β_skeleton_meta(points::Array{Float64,2}, β)

    if β <= 1
        in_C = in_C_1
    else
        in_C = in_C_2
    end

    N = size(points)[1]
    g = SimpleGraph(N)

    possible_edges = triangulation_edges_gr(points)

    for ed in possible_edges
        index_u, index_v = ed
        u, v = points[index_u,:], points[index_v,:]

        isempty = true
        for index_p in 1:N
            if index_p != index_u && index_p != index_v

                p = points[index_p,:]
                if in_C(p,u,v,β)
                    isempty = false
                    break
                end
            end
        end
        if isempty
            add_edge!(g, index_u, index_v)
        end
    end

    #This really doenst seem like the most efficient way to do this...
    mg = MetaGraph(g)
    edge_lengths = zeros(ne(g))
    for (i,ed) in enumerate(edges(mg))
        pos_s = points[ed.src,:]
        pos_t = points[ed.dst, :]

        e_len = norm(pos_t - pos_s)

        edge_lengths[i] = e_len
        set_prop!(mg, ed, :length, e_len)
    end
    for v in vertices(mg)
        set_prop!(mg, v, :position, points[v, :])
    end
    weightfield!(mg, :length)
    mg
end



"""
Makes a beta skeleton from a set of points given as a 2D array of coordinates.
Function uses GR.delaunay for building triangulation
Default is for set of points to be given as a 2D array.
"""
function β_skeleton_directed(points::Array{Float64,2}, β)

    if β <= 1
        in_C = in_C_1
    else
        in_C = in_C_2
    end

    N = size(points)[1] 
    g = SimpleDiGraph(N)

    possible_edges = triangulation_edges_gr(points)

    for ed in possible_edges
        index_u, index_v = ed
        u, v = points[index_u,:], points[index_v,:]

        isempty = true
        for index_p in 1:N
            if index_p != index_u && index_p != index_v

                p = points[index_p,:]
                if in_C(p,u,v,β)
                    isempty = false
                    break
                end
            end
        end
        if isempty
            add_edge!(g, index_u, index_v)
            add_edge!(g, index_v, index_u)
        end
    end
    g
end

function αβ_network(n, α, β)
    nodes_pos = α_set(n, α)
    g = β_skeleton(nodes_pos, β)
end

function αβ_network_meta(n, α, β)
    nodes_pos = α_set(n, α)
    g = β_skeleton_meta(nodes_pos, β)
end

###
### Auxiliary functions for convenience
###

"""
Returns 2D array of node coordinates of metagraph g

    get_node_pos(g::MetaGraph)
"""
function get_node_pos(g::MetaGraph)
    N = nv(g)
    nodes_pos = zeros(Float64, N, 2)
    for v in vertices(g)
        coords = g.vprops[v][:position]
        nodes_pos[v,:] = coords
    end
    nodes_pos
end

function get_node_pos(rn)
    rn.node_params[:pos]
end

"""
Returns an array with the length of the edges.

    edge_lengths(g, node_positions)

`node_positions` has to be given as a nx2 2D array
"""
function edge_lengths(g, node_positions)
    a = []
    for (i, e) in enumerate(edges(g))
        s, t = e.src, e.dst
        xs, ys = node_positions[s,:]
        xt, yt = node_positions[t,:]

        r_len = norm([xt, yt] - [xs, ys])

        push!(a, r_len)
    end
    a
end
