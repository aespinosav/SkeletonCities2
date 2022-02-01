"""
Returns the indices i,j of the position of the k-th point in the lattice
"""
function indices_of_lattice_point(k, n) 
        i = floor(k/n) # which row (from top to bottom) 0-start I think
        j = mod(k, n)
        indices = [Int(i),Int(j)]
end

"""
Make rectangular lattice of (n_root)^2 points in an (a x a) square.
The clearance is the padding between the "outer" points of the lattice
and the unit (a) square boundary.
"""
function square_lattice(n, a=1)
    N = n^2

    gap = a/n # number of gaps + 1 since clearance is 1/2 of the gap
    clearance = 0.5*gap

    points = zeros(N,2)
    for k in 0:N-1 #because index function starts at 0
        i, j = indices_of_lattice_point(k, n)
        p_k = [j*gap, i*gap] + clearance*[1,1]
        points[k+1,:] = p_k
    end
    points
end

"""
Returns the corners (as a 4x2 array) of the re-sampling box for point p in anticlockwise order starting at bottom left corner

For α = 0 all the corners coincide with p. For α = 1 the corners coincide
coincide with the corners of the unit square (given scale a=1).
"""
function corners(p, α, a=1)
    c = [0.0  0.0;
         1.0  0.0;
         1.0  1.0;
         0.0  1.0]
    c *= a # Scale the box by a (i.e an a x a box)

    k = zeros(Float64, 4, 2)
    for i in 1:4
        k[i,:] = p + α*(c[i,:][:] - p)
    end
    k
end

"""
Genereates a uniformly random point inside the rectangle defined by the four
points given as the corners array. (if not square it might not stretched a bit)

This should be an Array{Array{Float64,1},1}
"""
function drop_point(corner_array)
    xmin = corner_array[1,1]
    xmax = corner_array[2,1]
    ymin = corner_array[1,2]
    ymax = corner_array[4,2]

    xlength = xmax - xmin
    ylength = ymax - ymin

    x = rand()*xlength
    y = rand()*ylength

    p = [x,y] + corner_array[1,:][:]
end


"""
Returns a set of perturbed lattice points. For α=0 a square lattice is generated. For α=1 a set of uniformly distribued random points.
"""
function α_set(n, α, a=1)
    N = n^2
    lattice_points = square_lattice(n, a)

    if α == 0.0
        points = lattice_points
    else
        points = Array{Float64}(undef,N,2)
        for i in 1:N
            ks = corners(lattice_points[i,:][:], α, a)
            points[i,:] = drop_point(ks)
        end
    end
    points
end
