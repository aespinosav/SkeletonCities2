# Function `resource_allocation` requires RoadNetwork from TrafficNetworks2, but the is no longer
# type parametrised

"""
Endogenous definition of congestible term for affine cost functions
"""
function resource_allocation(g, lens; constant=1.0)
    M = ne(g)
    N = nv(g)

    inc_mat = incidence_matrix(g)
    in_edges_array = [findall(x->x>0, inc_mat[i,:]) for i in 1:N]
    in_degrees = indegree(g)
    sums_of_as = []
    for i in 1:N
        in_edges = in_edges_array[i]
        suma_of_a = sum(lens[in_edges])
        push!(sums_of_as, suma_of_a)
    end

    lamb = constant / ((1 ./ in_degrees) ⋅ sums_of_as)

    bs = zeros(Float64, M)
    suma = 0
    for n in 1:N
        b = in_degrees[n] / lamb
        for j in in_edges_array[n]
            bs[j] = b
        end
    end
    bs
end

"""
Allocate congestible parameters for affine cost functions
based on resource allocation heuristic.

rn should be a RoadNetwrok
"""
function resource_allocation(rn; constant=1.0)
    g = rn.g
    lens = rn.edge_params[:a]
    resource_allocation(g, lens, constant=constant)
end
