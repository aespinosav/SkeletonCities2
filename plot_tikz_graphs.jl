using LightGraphs, Colors


"""
Saves a .tex file that contains a tikz image.

Usage is as follows:

    `save_graph_tikz(g, node_coords, filename)`

Where g is a LightGraphs Graph, node_coords a 2D array  and filename is the name of the target file as a string.

The optional variable 'standalone_doc' is by default set to true. Setting it to false just generates the tikzpicture code.
"""
function save_graph_tikz(g::AbstractGraph, node_coords::Array{Float64,2}, filename::String; scale=10, standalone_doc=true)

    #scale = 10
    
    n = nv(g) # Nodes
    m = ne(g) # Edges

    # Begin tikz picture #####################################################################

    drawing ="\n\\begin{tikzpicture}\n"
    
    #Begin node scope (toggle comment for nodes or no nodes)
    drawing *= "\\begin{scope}\n\\tikzstyle{every node}=[draw=none,fill=none,inner sep=0]\n"
    #drawing *= "\\begin{scope}\n\\tikzstyle{every node}=[draw,circle,fill=gray,minimum size=0.1cm]\n"
    for i in 1:n
        x, y = node_coords[i,1], node_coords[i,2]
        drawing *= "\\node ($i) at ($(x*scale),$(y*scale)) {};\n"
    end
    drawing *= "\\end{scope}\n"
    
    #Begin dashed frame scope
    drawing *="\\begin{scope}\n\\draw[gray,thin,dashed] (0,0) rectangle ($(scale),$(scale));\n\\end{scope}\n\n"
    
    #Begin edge scope
    if m != 0   #If there are no edges, adding an empty scope is likely to cause problems
        drawing *= "\\begin{scope}\n"
        for edge in edges(g)
            s = edge.src
            t = edge.dst
            drawing *= "\\draw[thick] ($(s).center) -- ($(t).center);\n"
        end
        drawing *= "\\end{scope}\n\n"
    end
    
    #End tikzpicture
    drawing *="\\end{tikzpicture}"

    ##########################################################################################    
    
    #Add header and footer to file
    if standalone_doc 
        head = """
\\documentclass{article}
\\usepackage{tikz}
\\usepackage[active,tightpage]{preview}
\\PreviewBorder=2pt
\\PreviewEnvironment{tikzpicture}
\\begin{document}\n"""
                  
        tail = "\n\\end{document}"
        drawing = head*drawing*tail
    end

    #Write figure
    open(filename, "w") do f
        write(f, drawing)
    end
end


"""
Experimental function that includes option to draw some nodes differently to mark them out...
for example, origin and destinations, the idea is that it should be flexible enough, 
so maybe include a way of setting markers and colours easily?

    save_paths_tikz_exp(g::AbstractGraph,
                             paths,
                             node_coords::Array{Float64,2},
                             filename::String;
                             imp_nodes=[],
                             imp_labels::Array{Union{String,Nothing},1}=[],
                             scale=10,
                             standalone_doc=true)
"""
function save_paths_tikz(g::AbstractGraph,
                         paths,
                         node_coords::Array{Float64,2},
                         filename::String;
                         imp_nodes=[],
                         imp_labels::Array{String,1}=String[],
                         scale=10,
                         standalone_doc=true)

    #scale = 10
    
    n = nv(g) # Nodes
    m = ne(g) # Edges
    
    M = length(paths) # number of paths
    
    color_array = distinguishable_colors(M, [RGB(1,1,1), RGB(0,0,0)], dropseed=true)
    color_array = convert.(RGB{Float64}, color_array)

    # Begin tikz picture #####################################################################

    drawing ="\n\\begin{tikzpicture}\n"
    
    #Begin node scope (toggle comment for nodes or no nodes)
    drawing *= "\\begin{scope}\n\\tikzstyle{every node}=[draw=none,fill=none,inner sep=0]\n"
    #drawing *= "\\begin{scope}\n\\tikzstyle{every node}=[draw,circle,fill=gray,minimum size=0.1cm]\n"
    for i in 1:n
        x, y = node_coords[i,1], node_coords[i,2]
        drawing *= "\\node ($i) at ($(x*scale),$(y*scale)) {};\n"
    end
    drawing *= "\\end{scope}\n"
    
    #Begin dashed frame scope
    drawing *="\\begin{scope}\n\\draw[gray,thin,dashed] (0,0) rectangle ($(scale),$(scale));\n\\end{scope}\n\n"
    
    #Begin edge scope
    if m != 0   #If there are no edges, adding an empty scope is likely to cause problems
        drawing *= "\\begin{scope}\n"
        for edge in edges(g)
            s = edge.src
            t = edge.dst
            drawing *= "\\draw[thick,opacity=0.1] ($(s).center) -- ($(t).center);\n"
        end
        drawing *= "\\end{scope}\n\n"
    end
    
    ### 
    ### Draw paths
    ###
    for i in 1:M
        drawing *= "\\begin{scope}\n"
        
        edge_color=color_array[i]
        color_str = "{rgb,255:red,$(edge_color.r*255);green,$(edge_color.g*255);blue,$(edge_color.b*255)}"
       
        p = paths[i]
        for j in 1:length(p)-1
            s = p[j]
            t = p[j+1]
            drawing *= "\\draw[thick,color=$(color_str),opacity=0.7] ($(s).center) -- ($(t).center);\n"
            
        end
        drawing *= "\\end{scope}\n\n"
    end
    
    ###
    ### Scope for highlighted nodes
    ###
    
    if length(imp_nodes) > 0
        if length(imp_labels) == 0
            for i in 1:length(imp_nodes)
                push!(imp_labels, "")
            end
        end
    
        drawing *= "\\begin{scope}\n"
        
        #nodes should be indices...
        for (i,v) in enumerate(imp_nodes)
            x, y = node_coords[v,1], node_coords[v,2]
            drawing *= "\\node (imp$i) [black,fill,circle,minimum size=0.5] at ($(x*scale),$(y*scale)) {$(imp_labels[i])};\n"
        end
        
        drawing *= "\\end{scope}\n\n"
    end    

    ### End tikzpicture
    drawing *="\\end{tikzpicture}"
        
    ###
    ### Add header and footer to file
    ###
    if standalone_doc 
        head = """
\\documentclass{article}
\\usepackage{tikz}
\\usepackage[active,tightpage]{preview}
\\PreviewBorder=2pt
\\PreviewEnvironment{tikzpicture}
\\begin{document}\n"""
                  
        tail = "\n\\end{document}"
        drawing = head*drawing*tail
    end

    #Write figure
    open(filename, "w") do f
        write(f, drawing)
    end
end


###
### Old function... It is being kept here temporarily for now in case new one turns out
### to be fundamentally flawed (9 feb 2021)
### 
### I guess the julian solution is to have a method that deals with this case rather
### than just rename it...
###


"""
Plot graph as well as a set of paths given as an array of arrays

    save_paths_tikz(g::AbstractGraph, paths, node_coords::Array{Float64,2}, filename::String; scale=10, standalone_doc=true)
"""
function save_paths_tikz_old(g::AbstractGraph, paths, node_coords::Array{Float64,2}, filename::String; scale=10, standalone_doc=true)

    #scale = 10
    
    n = nv(g) # Nodes
    m = ne(g) # Edges
    
    M = length(paths) # number of paths
    
    color_array = distinguishable_colors(M, [RGB(1,1,1), RGB(0,0,0)], dropseed=true)
    color_array = convert.(RGB{Float64}, color_array)

    # Begin tikz picture #####################################################################

    drawing ="\n\\begin{tikzpicture}\n"
    
    #Begin node scope (toggle comment for nodes or no nodes)
    drawing *= "\\begin{scope}\n\\tikzstyle{every node}=[draw=none,fill=none,inner sep=0]\n"
    #drawing *= "\\begin{scope}\n\\tikzstyle{every node}=[draw,circle,fill=gray,minimum size=0.1cm]\n"
    for i in 1:n
        x, y = node_coords[i,1], node_coords[i,2]
        drawing *= "\\node ($i) at ($(x*scale),$(y*scale)) {};\n"
    end
    drawing *= "\\end{scope}\n"
    
    #Begin dashed frame scope
    drawing *="\\begin{scope}\n\\draw[gray,thin,dashed] (0,0) rectangle ($(scale),$(scale));\n\\end{scope}\n\n"
    
    #Begin edge scope
    if m != 0   #If there are no edges, adding an empty scope is likely to cause problems
        drawing *= "\\begin{scope}\n"
        for edge in edges(g)
            s = edge.src
            t = edge.dst
            drawing *= "\\draw[thick,opacity=0.1] ($(s).center) -- ($(t).center);\n"
        end
        drawing *= "\\end{scope}\n\n"
    end
    
    ### 
    ### Draw paths
    ###
    for i in 1:M
        drawing *= "\\begin{scope}\n"
        
        edge_color=color_array[i]
        color_str = "{rgb,255:red,$(edge_color.r*255);green,$(edge_color.g*255);blue,$(edge_color.b*255)}"
       
        p = paths[i]
        for j in 1:length(p)-1
            s = p[j]
            t = p[j+1]
            drawing *= "\\draw[thick,color=$(color_str),opacity=0.7] ($(s).center) -- ($(t).center);\n"
            
        end
        drawing *= "\\end{scope}\n\n"
    end
   
    #End tikzpicture
    drawing *="\\end{tikzpicture}"
        
    ###
    ### Add header and footer to file
    ###
    if standalone_doc 
        head = """
\\documentclass{article}
\\usepackage{tikz}
\\usepackage[active,tightpage]{preview}
\\PreviewBorder=2pt
\\PreviewEnvironment{tikzpicture}
\\begin{document}\n"""
                  
        tail = "\n\\end{document}"
        drawing = head*drawing*tail
    end

    #Write figure
    open(filename, "w") do f
        write(f, drawing)
    end
end
