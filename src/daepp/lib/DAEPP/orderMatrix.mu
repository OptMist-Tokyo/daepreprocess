// MuPAD implementation for orderMatrix.m

daepp::orderMatrix := proc(eqs, vars)
local m, n, sub;
begin
    // check number of arguments
    if testargs() then
        if args(0) <> 2 then
            error("List of equations and list of variables expected.");
        end_if;
    end_if;
    
    // convert to lists
    [eqs, vars] := map([eqs, vars], symobj::tolist);
    
    // check input
    if testargs() then
        [eqs, vars] := daepp::checkDAEInput(eqs, vars)[[1, 2]];
    end_if;
    
    [m, n] := [nops(eqs), nops(vars)];
    
    // extract subexpressions with 'diff' operator
    sub := map(eqs, eq -> misc::subExpressions(eq, "diff"));
    
    matrix(m, n, proc(i, j)
        local orders;
        begin
            orders := map(select(sub[i], v -> op(v, 1) = vars[j]), v -> nops(v) - 1);
            if nops(orders) > 0 then
                max(orders);
            else
                if has(eqs[i], vars[j]) then 0 else -infinity end_if;
            end_if;
        end_proc)
end_proc;
