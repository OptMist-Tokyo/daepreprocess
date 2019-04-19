// MuPAD implementation for systemJacobian.m

daepp::systemJacobian := proc(eqs, vars, p, q /*, t */)
local t, m, n, D, i, J, dxJp, dummy, subseqs, backsubseqs, eq, k;
begin
    // convert to list
    [p, q] := [daepp::toList(p), daepp::toList(q)];
    
    // check input
    if testargs() then
        if args(0) < 4 || 5 < args(0) then
            error("Four or five arguments expected.");
        end_if;
        [eqs, vars, t] := daepp::checkInput(eqs, vars);
        if args(0) = 5 && t <> args(5) then
            error("Inconsistency of time variable.");
        end_if;
        if nops(eqs) <> nops(p) then
            error("Inconsistency between sizes of eqs and p.");
        end_if;
        if not _and((testtype(pi, DOM_INT) && pi >= 0) $ pi in p) then
            error("Entries in p are expected to be nonnegative integers.");
        end_if;
        if nops(vars) <> nops(q) then
            error("Inconsistency between sizes of vars and q.");
        end_if;
        if not _and((testtype(qj, DOM_INT) && qj >= 0) $ qj in q) then
            error("Entries in q are expected to be nonnegative integers.");
        end_if;
    end_if;
    
    // retrive t
    if args(0) = 4 then
        [eqs, vars, t] := daepp::checkInput(eqs, vars);
    end_if;
    
    [m, n] := [nops(eqs), nops(vars)];
    D := matrix(m, n);
    
    for i from 1 to m do
        // create dummy variables
        J := [select(j $ j = 1..n, j -> q[j] >= p[i])];
        dxJp := [symobj::diff(vars[j], t, q[j] - p[i]) $ j in J];
        dummy := [genident() $ j in J];
        subseqs := [dxJp[k] = dummy[k] $ k = 1..nops(J)];
        backsubseqs := map(subseqs, s -> op(s, 2) = op(s, 1));
        
        // change symbolic functions to variables
        eq := subs(eqs[i], subseqs);
        
        // differentiate and substitute back
        for k from 1 to nops(J) do
            D[i, J[k]] := diff(eq, dummy[k]);
            D[i, J[k]] := subs(D[i, J[k]], backsubseqs);
        end_for;
    end_for;
    
    D;
end_proc;
