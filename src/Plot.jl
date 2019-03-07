import LightGraphs
import GraphPlot
using Colors

colors = [colorant"lightseagreen", colorant"orange", colorant"orangered2",
             colorant"darkgoldenrod2", colorant"darkslategray2"]

nodetype(::PowerDynBase.AbstractNodeDynamics{T}) where T = T

"Compressor for plot sizes. Adjusts dynamics range of an array for better visualizations"
function compressor(min_plot_size::Real,max_plot_size::Real,input::Array)
    # compressor for plot with sizes in range min_plot_size to max_plot_size 
    # TODO: should this be a perceptual area scaling rather than linear? 
    max_node_size = maximum(input)
    min_node_size = minimum(input)
    scale(x) = (max_plot_size - min_plot_size) / (max_node_size - min_node_size) * x +
                                                    (min_plot_size - min_node_size)
    output = scale.(input) 
end

"Return a colorized array with nodes of a common type sharing a color"
function colorizenodes(g::PowerDynBase.GridDynamics)
    nodetypes  = Nodes(g) .|> nodetype
    colorset    = Dict(type => i for 
                           (i, type) in enumerate(Set(nodetypes)))
    nodefillc   = [colors[colorset[i]] for i in nodetypes] 
end

"Generates labels and sizes for gplot"
function generate_label_size(g::PowerDynBase.GridDynamics; label::Symbol=:P, resize::Bool=true)
    nodesize  = ones(length(Nodes(g)))
    if label == :nodetypes
        nodelabel = nodetype.(Nodes(g))
    else
        nodelabel = [i for (i,type) in enumerate(Nodes(g))]
    end
    if resize == true
        for (i,node) in enumerate(Nodes(g)) #TODO: Write getters for node parameters []
                                # that would make this less convoluted
            if nodetype(node) == FourthEq
            nodesize[i] = abs(node.ode_dynamics.parameters.P)
            end
        end
        # compressor for plot with sizes in range 
        max_plot_size = 5
        min_plot_size = 2
        nodesize = compressor(min_plot_size,max_plot_size,nodesize) 
    end 
    
    return nodesize, nodelabel
end

"Plot a GridDynamics object"
function gplot(g::PowerDynBase.GridDynamics;label::Symbol=:nodetypes, resize::Bool=true)
    nodefillc = colorizenodes(g)
    nodesize, nodelabel = generate_label_size(g,resize=resize,label=label) 
    GraphPlot.gplot(LightGraphs.Graph(Array(g.rhs.LY)),
                                        nodelabel       = nodelabel, 
                                        nodelabeldist   = 1,
                                        nodelabelangleoffset= 3*π/2,
                                        nodefillc       = nodefillc,
                                        nodesize        = nodesize,
                                        nodelabelsize   = nodesize)
end


