function [x, info] = mplinsolve(A, b, solver, opt)
%MPLINSOLVE  Solves A * x = b using specified solver
%   X = MPLINSOLVE(A, B)
%   X = MPLINSOLVE(A, B, SOLVER)
%   X = MPLINSOLVE(A, B, SOLVER, OPT)
%   [X, INFO] = MPLINSOLVE(...)
%
%   Solves the linear system of equations A * x = b, using the selected
%   solver.
%
%   Inputs:
%       A      : sparse matrix
%       B      : full vector or matrix
%       SOLVER : ('') selected linear system solver
%           ''  - use default solver, currently this is
%                   always the built-in backslash operator
%           '\' - built-in backslash operator
%           'LU' - use explicit LU decomposition and back substitution
%               The following are also provided as short-cuts, with less
%               overhead and thus better performance on small systems, as
%               alternatives for 'LU' with the following options:
%                           OPT.lu.nout     OPT.lu.vec      OPT.lu.thresh
%                   'LU3'       3               1               1.0
%                   'LU3a'      3               1
%                   'LU4'       4               1
%                   'LU5'       5               1
%                   'LU3m'      3               0               1.0
%                   'LU3am'     3               0
%                   'LU4m'      4               0
%                   'LU5m'      5               0
%           'PARDISO' - PARDISO
%       OPT    : struct of options for certain solvers (e.g. LU and PARDISO)
%           lu : struct of options to determine form of call to LU solver,
%                 with the following possible fields (default value in parens):
%               nout (4) - number of output args for call to LU, UMFPACK is
%                   used for 4 or 5 output args, Gilbert-Peierls algorithm
%                   with AMD ordering for 3 output args.
%               vec (1)  - use permutation vectors instead of matrices
%                   (permutation matrices used by default for MATLAB < 7.3)
%               thresh   - pivot threshold, see 'help lu' for details
%           lu_factors - struct with factors from previous LU factorization
%               (overrides provided A matrix), consisting of one of the
%               following sets of fields:
%                   L, U, p, qa     - 3 output Gilbert-Peierls, perm vectors
%                   L, U, P, Qa     - 3 output Gilbert-Peierls, perm matrices
%                   L, U, p, q      - 4 output UMFPACK, perm vectors
%                   L, U, P, Q      - 4 output UMFPACK, perm matrices
%                   L, U, p, q, R   - 5 output UMFPACK, perm vec, row scaling
%                   L, U, P, Q, R   - 5 output UMFPACK, perm mat, row scaling
%           pardiso : struct of PARDISO options (default shown in parens),
%                 see PARDISO documentation for details
%               verbose (0) - true or false
%               mtype (11)  - matrix type (default is real and nonsymmetric)
%               solver (0)  - solver method (default is sparse direct)
%               iparm ([])  - n x 2 matrix of integer parameters
%                   1st, 2nd columns are index, value of parameter respectively
%               dparm ([])  - n x 2 matrix of double parameters
%                  1st, 2nd columns are index, value of parameter respectively

%   MIPS
%   Copyright (c) 2015-2022, Power Systems Engineering Research Center (PSERC)
%   by Ray Zimmerman, PSERC Cornell
%
%   This file is part of MIPS.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See https://github.com/MATPOWER/mips for more info.

if nargin < 4
    opt = [];
    if nargin < 3
        solver = '';
    end
end

info = [];

if length(solver) >= 2 && all(solver(1:2) == 'LU') && ...
        isfield(opt, 'lu_factors') && ~isempty(opt.lu_factors)
    f = opt.lu_factors;
    if isfield(f, 'p')          %% permutation vectors
        x = zeros(size(f.L, 1), 1);
        if isfield(f, 'R')      %% 5 output LU: UMFPACK w/row scaling
            x(f.q) = f.U \ ( f.L \ (f.R(:, f.p) \ b));
        elseif isfield(f, 'qa') %% 3 output LU: Gilbert-Peierls alg
            x(f.qa) = f.U \ ( f.L \ b(f.qa(f.p)) );
        else                    %% 4 output LU: UMFPACK
            x(f.q) = f.U \ ( f.L \ b(f.p) );
        end
    else                        %% permutation matrices
        if isfield(f, 'R')      %% 5 output LU: UMFPACK w/row scaling
            x = f.Q * ( f.U \ (f.L \ (f.P * (f.R \ b))) );
        elseif isfield(f, 'Qa') %% 3 output LU: Gilbert-Peierls alg
            x = f.Qa * ( f.U \ (f.L \ (f.P * f.Qa' * b)) );
        else                    %% 4 output LU: UMFPACK
            x = f.Q * ( f.U \ (f.L \ (f.P * b)) );
        end
    end
else
    switch solver
        case {'', '\'}  %% use built-in \ operator
            x = A \ b;
        case 'LU3'      %% 3 output LU: Gilbert-Peierls alg, perm vec, 1.0 piv thresh
            q = amd(A);     %% permutation vector for AMD reordering
            if issparse(A)
                [L, U, p] = lu(A(q,q), 1.0, 'vector');
            else
                [L, U, p] = lu(A(q,q), 'vector');
            end
            x = zeros(size(A, 1), 1);
            x(q) = U \ ( L \ b(q(p)) );
            if nargout > 1
                info = struct('L', L, 'U', U, 'p', p, 'qa', q);
            end
        case 'LU3a'     %% 3 output LU: Gilbert-Peierls alg, permutation vectors
            q = amd(A);     %% permutation vector for AMD reordering
            [L, U, p] = lu(A(q,q), 'vector');
            x = zeros(size(A, 1), 1);
            x(q) = U \ ( L \ b(q(p)) );
            if nargout > 1
                info = struct('L', L, 'U', U, 'p', p, 'qa', q);
            end
        case 'LU4'      %% 4 output LU: UMFPACK, permutation vectors
            [L, U, p, q] = lu(A, 'vector');
            x = zeros(size(A, 1), 1);
            x(q) = U \ ( L \ b(p));
            if nargout > 1
                info = struct('L', L, 'U', U, 'p', p, 'q', q);
            end
        case 'LU5'      %% 5 output LU: UMFPACK w/row scaling, permutation vectors
            [L, U, p, q, R] = lu(A, 'vector');
            x = zeros(size(A, 1), 1);
            x(q) = U \ ( L \ (R(:, p) \ b));
            if nargout > 1
                info = struct('L', L, 'U', U, 'p', p, 'q', q, 'R', R);
            end
        case 'LU3m'     %% 3 output LU: Gilbert-Peierls alg, perm mat, 1.0 piv thresh
            Q = sparse(amd(A), 1:size(A, 1), 1);    %% permutation matrix for AMD reordering
            if issparse(A)
                [L, U, P] = lu(Q'*A*Q, 1.0);
            else
                [L, U, P] = lu(Q'*A*Q);
            end
            x = Q * ( U \ ( L \ (P * Q' * b)) );
            if nargout > 1
                info = struct('L', L, 'U', U, 'P', P, 'Qa', Q);
            end
        case 'LU3am'    %% 3 output LU: Gilbert-Peierls alg, permutation matrices
            Q = sparse(amd(A), 1:size(A, 1), 1);  %% permutation matrix for AMD reordering
            [L, U, P] = lu(Q'*A*Q);
            x = Q * ( U \ ( L \ (P * Q' * b)) );
            if nargout > 1
                info = struct('L', L, 'U', U, 'P', P, 'Qa', Q);
            end
        case 'LU4m'     %% 4 output LU: UMFPACK, permutation matrices
            [L, U, P, Q] = lu(A);
            x = Q * (U \ (L \ (P * b)));
            if nargout > 1
                info = struct('L', L, 'U', U, 'P', P, 'Q', Q);
            end
        case 'LU5m'     %% 5 output LU: UMFPACK w/row scaling, permutation matrices
            [L, U, P, Q, R] = lu(A);
            x = Q * (U \ (L \ (P * (R \ b))));
            if nargout > 1
                info = struct('L', L, 'U', U, 'P', P, 'Q', Q, 'R', R);
            end
        case 'LU'       %% explicit LU, with options struct
            %% default options
            nout = 4;               %% 4 output args, UMFPACK
            if ~issparse(A)
                nout = 3;
            end
            vec = have_feature('lu_vec');   %% use permulation vectors, if available
            thresh = [];                    %% use default pivot threshold
            if isfield(opt, 'lu')
                opt_lu = opt.lu;
                if isfield(opt_lu, 'nout')
                    nout = opt_lu.nout;
                end
                if isfield(opt_lu, 'vec')
                    vec = opt_lu.vec;
                end
                if isfield(opt_lu, 'thresh')
                    thresh = opt_lu.thresh;
                end
            end
            %% call the appropriate form
            switch nout
                case 3      %% 3 output args: Gilbert-Peierls algorithm, with AMD reordering
                    q = amd(A);         %% permutation vector for AMD reordering
                    n = size(A, 1);
                    if vec
                        if isempty(thresh)
                            [L, U, p] = lu(A(q,q), 'vector');
                        else
                            [L, U, p] = lu(A(q,q), thresh, 'vector');
                        end
                        x = zeros(n, 1);
                        x(q) = U \ ( L \ b(q(p)) );
                        if nargout > 1
                            info = struct('L', L, 'U', U, 'p', p, 'qa', q);
                        end
                    else
                        Q = sparse(q, 1:n, 1);  %% permutation matrix for AMD reordering
                        if isempty(thresh)
                            [L, U, P] = lu(Q'*A*Q);
                        else
                            [L, U, P] = lu(Q'*A*Q, thresh);
                        end
                        x = Q * ( U \ ( L \ (P * Q' * b)) );
                        if nargout > 1
                            info = struct('L', L, 'U', U, 'P', P, 'Qa', Q);
                        end
                    end
                case 4      %% 4 output args: UMFPACK
                    if vec
                        [L, U, p, q] = lu(A, 'vector');
                        x = zeros(size(A, 1), 1);
                        x(q) = U \ ( L \ b(p));
                        if nargout > 1
                            info = struct('L', L, 'U', U, 'p', p, 'q', q);
                        end
                    else
                        [L, U, P, Q] = lu(A);
                        x = Q * (U \ (L \ (P * b)));
                        if nargout > 1
                            info = struct('L', L, 'U', U, 'P', P, 'Q', Q);
                        end
                    end
                case 5      %% 5 output args: UMFPACK w/row scaling
                    if vec
                        [L, U, p, q, R] = lu(A, 'vector');
                        x = zeros(size(A, 1), 1);
                        x(q) = U \ ( L \ (R(:, p) \ b));
                        if nargout > 1
                            info = struct('L', L, 'U', U, 'p', p, 'q', q, 'R', R);
                        end
                    else
                        [L, U, P, Q, R] = lu(A);
                        x = Q * (U \ (L \ (P * (R \ b))));
                        if nargout > 1
                            info = struct('L', L, 'U', U, 'P', P, 'Q', Q, 'R', R);
                        end
                    end
            end
        case {'PARDISO'}
            %% set default options
            verbose = false;
            mtype = 11;
            pardiso_solver = 0;

            %% override if provided via opt
            if ~isempty(opt) && isfield(opt, 'pardiso')
                if isfield(opt.pardiso, 'verbose') && opt.pardiso.verbose
                    verbose = true;
                end
                if isfield(opt.pardiso, 'mtype')
                    mtype = opt.pardiso.mtype;
                end
                if isfield(opt.pardiso, 'solver')
                    pardiso_solver = opt.pardiso.solver;
                end
            end

            %% begin setup and solve
            v6 = have_feature('pardiso_object');
            if v6               %% PARDISO v6+
                id = 1;
                p = pardiso(id, mtype, pardiso_solver);
                if verbose
                    p.verbose();
                end
            else                %% PARDISO v5
                p = pardisoinit(mtype, pardiso_solver);
            end
            if ~isempty(opt) && isfield(opt, 'pardiso')
                if isfield(opt.pardiso, 'iparm') && ~isempty(opt.pardiso.iparm)
                    p.iparm(opt.pardiso.iparm(:, 1)) = opt.pardiso.iparm(:, 2);
                end
                if isfield(opt.pardiso, 'dparm') && ~isempty(opt.pardiso.dparm)
                    p.dparm(opt.pardiso.dparm(:, 1)) = opt.pardiso.dparm(:, 2);
                end
            end
            if v6 || abs(mtype) == 2 || mtype == 6  %% need non-zero diagonal
                nx = size(A, 1);
                if abs(mtype) == 2 || mtype == 6    %% symmetric
                    myeps = 1e-14;
                    A = tril(A);
                else                                %% non-symmetric
                    myeps = 1e-8;
                end
                A = A + myeps * speye(nx, nx);
            end
            if v6
                p.factorize(id, A);
                x = p.solve(id, A, b);
                p.free(id);
                p.clear();
            else
                p = pardisoreorder(A, p, verbose);
                p = pardisofactor(A, p, verbose);
                [x, p] = pardisosolve(A, b, p, verbose);
                pardisofree(p);
            end
        otherwise
            warning('mplinsolve: ''%s'' is not a valid value for SOLVER, using default.', solver);
            x = A \ b;
    end
end
