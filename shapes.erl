-module(shapes).
-export([is_inside/2,move/2]).

%% Shape primitives are:
%% {circle,Mid_point,Radius}
%% {polygon, List_of_vertices}
%% {union, List_of_shapes}
%% {intersection, List_of_shapes}

%% Exported functions are:
%% is_inside(Point,Shape) -> Bool
%% move(Vector, Shape) -> Shape


is_inside({X1,Y1},Shape) ->
    case Shape of
        {circle,{X2,Y2},Radius} -> 
            (X2 - X1) * (X2 - X1) + (Y2 - Y1) * (Y2 - Y1) =< Radius;
        {polygon,Vertex_List} ->
            Normalize = fun({X,Y}) -> {X - X1, Y - Y1} end,
            [V|Vertices] = lists:map(Normalize,Vertex_List),
            folder(lists:append([V|Vertices],[V])) /= 0;
	{union,Shapes} -> lists:any(fun(X) -> is_inside({X1,Y1},X) end, Shapes);
	{intersection, Shapes} -> 
	    lists:all(fun(X) -> is_inside({X1,Y1},X) end, Shapes)
    end.


move(Point,Shape) ->
    {X1,Y1} = Point,
    case Shape of
	{circle, Pos, Radius} -> {circle, Pos + Point, Radius};
	{polygon,Vertices} -> {polygon, list:map(fun({X,Y}) -> {X - X1, Y - Y1} end, Vertices)};
	{union,Shapes} -> {union, list:map(fun(X) -> move(Point,X) end, Shapes)};
	{intersection,Shapes} -> {intersection, list:map(fun(X) -> move(Point,X) end, Shapes)}
    end.


folder([]) -> 0;
folder([_]) -> 0;
folder([H1,H2|T]) -> winding(H1,H2) + folder([H2|T]).
              
to_quarter({X,Y}) ->
    case {X > 0, Y > 0} of
        {true,true} -> 0;
        {true,false} -> 1;
        {false,false} -> 2;
        {false,true} -> 3
    end.

         
winding(P1,P2) ->
    {X1,Y1} = P1,
    {X2,Y2} = P2,
    X = if Y2 /= Y1 -> X2 + Y2 * (X1 - X2) / (Y2 - Y1);
	   true -> 0
	end,
    SIGN = if X > 0 -> 1;
              true  -> -1
           end,
    case {to_quarter(P1) , to_quarter(P2)} of
        {0,2} -> -2 * SIGN;
        {1,3} -> -2 * SIGN;
        {2,0} -> 2 * SIGN;
        {3,1} -> 2 * SIGN;
        {N,K} -> if N == (K + 3) rem 4 -> -1;
                    N == (K + 1) rem 4 -> 1;
                    N == K -> 0
                 end
    end.
                              
    
