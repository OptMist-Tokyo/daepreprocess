function varargout = preprocessDAE(eqs, vars, varargin)

% preprocessDAE    Preprocess DAE system for structural analysis.
%
%   Convert DAE system to which structural analysis methods (Mattsson--
%   Soederlind's index-reduction method, Sigma method) fail into an amenable
%   form, using the substitution or the augmentation method.
%
%   This method returns [newEqs, newVars, value], where
%     - newEqs and newVars are vectors of equations and variables, resp., in the
%       new DAE.
%     - value is the optimal value of the assignment problem. This represents
%       the dimension of the solution manifold.
%   Also returns the vector of constants if 'Constants' is set to 'sym'.
%
%   Parameters:
%     - Method : 'augmentation' (default) or 'substitution'
%           The method which we use. The substitution method repeatedly solves
%           nonlinear equations. The augmentatioin method enlarges the number of
%           equations and variables, and introduces constants.
%           
%     - Constants   : 'sym' (default) or 'zero'
%           Designate how represent constants which will be introduced in the
%           augmentation method. If Constants is 'sym', the contants are
%           represented by symbolic objects and returns a vector of introduced
%           constants as the fourth return value. If Constants is 'zero', 0 will
%           be substituted for all constants. Designating 'zero' would return
%           a simplier DAE but may cause a failure if 0 as the constants is out
%           of the domain of DAEs.
%
%   Reference:
%     Taihei Oki. Improved structural methods for nonlinear differential-
%     algebraic equations via combinatorial relaxation. In Proceedings of the
%     44th International Symposium on Symbolic and Algebraic Computation
%     (ISSAC 2019).

% check input
narginchk(2, Inf);
[eqs, vars, t] = checkInput(eqs, vars);

% parse parameters
parser = inputParser;
addParameter(parser, 'Method', 'augmentation', @(x) any(validatestring(x, {'substitution', 'augmentation'})));
addParameter(parser, 'Constants', 'sym', @(x) any(validatestring(x, {'zero', 'sym'})));
parser.parse(varargin{:});
options = parser.Results;

% pack options into MuPAD table
entries = evalin(symengine, ['Constants = "', options.Constants, '", Method = "', options.Method, '"']);
table = feval(symengine, 'table', entries);

% call MuPAD
loadMuPADPackage;
try
    out = feval(symengine, 'daepp::preprocessDAE', eqs, vars, t, table);
catch ME
    throw(ME);
end

% restore return values
varargout{1} = out(1).';
varargout{2} = out(2);
varargout{3} = double(out(3));

if strcmp(options.Constants, "sym")
    varargout{4} = out(4);
end