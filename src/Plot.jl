import LightGraphs
import GraphPlot
using Colors

colors = [colorant"lightseagreen", colorant"orange", colorant"orangered2",
             colorant"darkgoldenrod2", colorant"darkslategray2"]

nodetype(::PowerDynBase.AbstractNodeDynamics{T}) where T = T

function colorizenodes(g::PowerDynBase.GridDynamics)
    # Return an array of colors with nodes of a common type
    # sharing a color. 
    nodetypes  = Nodes(g) .|> nodetype
    colorset    = Dict(type => i for 
                           (i, type) in enumerate(Set(nodetypes)))
    nodefillc   = [colors[colorset[i]] for i in nodetypes] 
end

function generate_label_size(g::PowerDynBase.GridDynamics, label::Symbol=:P, resize::Bool=true)
    nodesize  = ones(length(Nodes(g)))
    for (i,node) in enumerate(Nodes(g)) #TODO: Write getters for node parameters []
                            # that would make this much less convoluted
        if nodetype(node) == FourthEq
            nodesize[i] = node.ode_dynamics.parameters.P
        end
    end
    return nodesize
end


function gplot(g::PowerDynBase.GridDynamics,label::Symbol=:nodetypes, resize::Bool=true)
    nodesize = ones(length(Nodes(g)))
    nodefillc = colorizenodes(g)
    nodesize = generate_label_size(g) 
    GraphPlot.gplot(LightGraphs.Graph(Array(g.rhs.LY)),
                                        nodelabel=nodetype.(g.rhs.nodes),
                                        nodefillc=nodefillc,
                                        nodesize=nodesize)

end
# Plot solutions
function gplot(g::PowerDynBase.GridDynamics,time::Real,label::Symbol=:nodetypes, resize::Bool=true)
    g
end



#

#plot(g::PowerDynSolve.GridSolution, time) = gplot(Array(g.griddynamics.rhs.LY),nodelabel=nodetype.(g.griddynamics.rhs.nodes))
#
#
#nodesize = [Graphs.out_degree(v, g) for v in Graphs.vertices(g)]
#gplot(g, nodesize=nodesize)
#






