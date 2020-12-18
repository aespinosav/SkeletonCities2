using GeometricalPredicates, VoronoiDelaunay

####################################################
# Custom pointtype from pbeville from discussion https://discourse.julialang.org/t/delaunay-triangularization/36172/19 to keep trackl of node index
# Seems to be more efficient for larger sets of points (>1000) than the GR triangulation

mutable struct Point2DI <: AbstractPoint2D
  _x::Float64
  _y::Float64
  _i::Int64
end

Point2DI(x::Float64, y::Float64) = Point2DI(x, y, 0)

import GeometricalPredicates.getx
import GeometricalPredicates.gety
import VoronoiDelaunay.isexternal

getx(p::Point2DI) = p._x
gety(p::Point2DI) = p._y
geti(p::Point2DI) = p._i

function isexternal(p::Point2DI)
  getx(p) < VoronoiDelaunay.min_coord || getx(p) > VoronoiDelaunay.max_coord
end

###################################################

function triangulation_delaunay(points_alfa)
    N = size(points_alfa)[1]
    
    tess = DelaunayTessellation2D{Point2DI}(N)
    
    point_array = Point2DI[]
    for i in 1:size(points_alfa)[1]
    	# Shift points for GeometryPredicates
    	p = points_alfa[i,:] + GeometricalPredicates.min_coord*[1,1]
	push!(point_array, Point2DI(p[1], p[2], i))    
    end
    push!(tess, point_array)

    tess
end

function triangulation_edges(points_alfa)
    
    tess = triangulation_delaunay(points_alfa)
    
    edges = []
    for edge in delaunayedges(tess)
	a = geta(edge)
	b = getb(edge)
	
	j = geti(a) 
	k = geti(b)
	
	push!(edges, (j,k))
    end
    edges
end

