/*
  Check whether
  point = [y(t) = 0.5, diff(y(t), t) = 0.2, g = 0.8, ...]
  or
  pointKeys = [y(t), diff(y(t), t), g, ...]
  pointValues = [0.5, 0.2, 0.8, ...]
*/

daepp::checkPointInput := proc() // proc(point) or proc(pointKeys, pointValues)
local point, pointKeys, pointValues, isValidFunc, tVar;
begin
    // check number of arguments
    if args(0) < 1 || 2 < args(0) then
        error("One or two argument expected.");
    end_if;
    
    if args(0) = 1 then
        // daepp::checkPointInput(point)
        point := args(1);
        
        // format check
        point := symobj::tolist(point);
        if not _and(type(v) = "_equal" $ v in point) then
            error("Equations expected.");
        end_if;
        
        // check LHS
        pointKeys := lhs(point);
        if nops(pointKeys) <> nops({op(pointKeys)}) then
            error("Duplicated variables in left hand sides.");
        end_if;
        
        pointValues := float(rhs(point));
    else
        // daepp::checkPointInput(pointKeys, pointValues)
        pointKeys := symobj::tolist(args(1));
        pointValues := float(symobj::tolist(args(2)));
        if nops(pointKeys) <> nops(pointValues) then
            error("Inconsistency between lengths of pointKeys and pointValues.");
        end_if;
        if nops(pointKeys) <> nops({op(pointKeys)}) then
            error("Duplicated variables in left hand sides.");
        end_if;
    end_if;
    
    // check LHS
    isValidFunc := f ->
        type(f) = "function" &&
        type(op(f, 0)) in {DOM_IDENT, "index"} &&
        nops(f) = 1 &&
        type(op(f, 1)) = DOM_IDENT &&
        freeIndets(f) <> {};
    
    if not _and((
        type(l) in {DOM_IDENT, "_index"} ||
        isValidFunc(l) ||
        (type(l) = "diff" && isValidFunc(op(l)))
    ) $ l in pointKeys) then
        error("Invalid keys (left hand side).");
    end_if;
    
    // check RHS
    if not _and(testtype(r, Type::Real) $ r in pointValues) then
        error("Real values expected in values (right hand side).");
    end_if;
    
    // check the consistency of time variables
    tVar := {op(l, nops(l)) $ l in select(pointKeys, l -> testtype(l, "function"))};
    if nops(tVar) > 1 then
        error("Multiple time variables are not allowed."); 
    end_if;
    
    // return
    zip(pointKeys, pointValues, (l, r) -> l = float(r));
end_proc;
