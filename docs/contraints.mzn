% C1 
constraint forall(b in 1..n)(sum(t in 1..m)(P[t,b]) <= 1);
% C2 
constraint sum(b in 1..n)(P[t, b]) == nbBlocks;
% window constraints 
struct Window {
    int: start;
    int: end;
    int: penalty;
}
array[1..m] of array[int] of Window: windows;
% start needs to be before end 
constraint forall(t in 1..m, w in 1..length(windows[t]))(
    windows[t][w].start < windows[t][w].end
);
% no overlap between tuples in the windows 
constraint forall(t in 1..m)(
    forall(i, j in 1..length(windows[t]) where i < j)(
        windows[t][i].end < windows[t][j].start \/
        windows[t][j].end < windows[t][i].start
    )
);
% window penalty : penalize every time a block bb is assigned to task tt and falls inside a window (s,e)
var int: total_penalty = sum(t in 1..m, b in 1..n)(
    let {
        array[int] of int: penalties = 
            [windows[t][w].penalty | w in 1..length(windows[t]) 
                where b >= windows[t][w].start /\ b <= windows[t][w].end]
    } in
    P[t,b] * sum(w in 1..length(penalties))(penalties[w])
);



solve minimize total_penalty;