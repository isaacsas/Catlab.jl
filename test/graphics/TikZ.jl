module TestTikZ

using Test
using Catlab.Graphics.TikZ

# Pretty-print
##############

spprint(expr::Expression) = sprint(pprint, expr)

# Properties
@test spprint(Property("circle")) == "circle"
@test spprint(Property("fill","red")) == "fill=red"
@test spprint(Property("style",[Property("circle"),Property("fill","red")])) ==
  "style={circle,fill=red}"

# Node statement
@test spprint(Node("f")) == "\\node (f) {};"
@test spprint(Node("f"; props=[Property("circle")])) == 
  "\\node[circle] (f) {};"
@test spprint(Node("f"; props=[Property("circle"),Property("fill","red")])) ==
  "\\node[circle,fill=red] (f) {};"
@test spprint(Node("f"; coord=Coordinate("0","1"))) ==
  "\\node (f) at (0,1) {};"
@test spprint(Node("f"; coord=Coordinate("1","0"), content="fun")) ==
  "\\node (f) at (1,0) {fun};"

# Edge statement
const PathOp = PathOperation
@test spprint(Edge("f", PathOp("to"), "g")) == "\\draw (f) to (g);"
@test spprint(Edge("f", PathOp("to"), "g"; props=[Property("red")])) ==
  "\\draw[red] (f) to (g);"
@test spprint(Edge("f", PathOp("to"), EdgeNode(), "g")) ==
  "\\draw (f) to node (g);"
@test spprint(Edge("f", PathOp("to"),
              EdgeNode(; props=[Property("circle")], content="e"), "g")) ==
  "\\draw (f) to node[circle] {e} (g);"
@test spprint(Edge("f", PathOp("to"; props=[Property("out","0")]), "g")) ==
  "\\draw (f) to[out=0] (g);"
@test spprint(Edge("f", PathOp("--"), "g", PathOp("--"), "h")) ==
  "\\draw (f) -- (g) -- (h);"

# Picture statement
@test spprint(Picture(Node("f"), Node("g"), Edge("f",PathOp("to"),"g"))) == """
\\begin{tikzpicture}
  \\node (f) {};
  \\node (g) {};
  \\draw (f) to (g);
\\end{tikzpicture}"""

@test spprint(Picture(Edge("f",PathOp("--"),"g"; props=[Property(">-Stealth")]),
  libraries=["arrows.meta"])) == """
\\usetikzlibrary{arrows.meta}
\\begin{tikzpicture}
  \\draw[>-Stealth] (f) -- (g);
\\end{tikzpicture}"""

@test spprint(Picture(Node("f");
  props=[Property("node distance","1cm")])) == """
\\begin{tikzpicture}[node distance=1cm]
  \\node (f) {};
\\end{tikzpicture}"""

# Scope statement
@test spprint(
Picture(
  Scope(Node("f"); props=[Property("red")]),
  Scope(Node("g"); props=[Property("blue")]),
  Edge("f",PathOp("to"),"g")
)) == """
\\begin{tikzpicture}
  \\begin{scope}[red]
    \\node (f) {};
  \\end{scope}
  \\begin{scope}[blue]
    \\node (g) {};
  \\end{scope}
  \\draw (f) to (g);
\\end{tikzpicture}"""

# Graph statements
@test spprint(
Graph(
  GraphNode("f";content="fun"),
  GraphEdge("f","g")
)) == """
\\graph{
  f/\"fun\";
  f -> g;
};"""

@test spprint(
Graph(
  GraphNode("f";props=[Property("circle")]),
  GraphEdge("f","g";props=[Property("edge label","X")])
)) == """
\\graph{
  f [circle];
  f ->[edge label=X] g;
};"""

@test spprint(
Graph(
  GraphScope(
    GraphEdge("a","b"); props=[Property("same layer")]
  ),
  GraphScope(
    GraphEdge("c","d"); props=[Property("same layer")]
  )
)) == """
\\graph{
  {[same layer]
    a -> b;
  };
  {[same layer]
    c -> d;
  };
};"""

# Matrix statement
@test spprint(
MatrixNode(
  [ [[Node("f")]]              [[Edge("g1",PathOp("to"),"g2")]];
    [[Node("h1"),Node("h2")]]  [[Node("i1"),Node("i2")]] ];
  props=[Property("draw","red")]
)) == """
\\matrix[draw=red]{
  \\node (f) {}; &
  \\draw (g1) to (g2); \\\\
  \\node (h1) {};
  \\node (h2) {}; &
  \\node (i1) {};
  \\node (i2) {}; \\\\
};"""

end
