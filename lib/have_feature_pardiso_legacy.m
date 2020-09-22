function [TorF, vstr, rdate] = have_feature_pardiso_legacy()
%HAVE_FEATURE_PARDISO_LEGACY  Detect availability/version info for PARDISO (legacy interface)
%
%   Used by HAVE_FEATURE.

%   MP-Opt-Model
%   Copyright (c) 2004-2020, Power Systems Engineering Research Center (PSERC)
%   by Ray Zimmerman, PSERC Cornell
%
%   This file is part of MP-Opt-Model.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See https://github.com/MATPOWER/mp-opt-model for more info.

TorF = exist('pardisoinit', 'file') == 3 && ...
        exist('pardisoreorder', 'file') == 3 && ...
        exist('pardisofactor', 'file') == 3 && ...
        exist('pardisosolve', 'file') == 3 && ...
        exist('pardisofree', 'file') == 3;
vstr = '';
rdate = '';
if TorF
    try
        A = sparse([1 2; 3 4]);
        b = [1;1];
        info = pardisoinit(11, 0);
        info = pardisoreorder(A, info, false);
%         % Summary PARDISO 5.1.0: ( reorder to reorder )
%         pat = 'Summary PARDISO (\.*\d)+:';
%         [s,e,tE,m,t] = regexp(evalc('info = pardisoreorder(A, info, true);'), pat);
%         if ~isempty(t)
%             vstr = t{1}{1};
%         end
        info = pardisofactor(A, info, false);
        [x, info] = pardisosolve(A, b, info, false);
        pardisofree(info);
        if any(x ~= [-1; 1])
            TorF = 0;
        end
    catch
        TorF = 0;
    end
end
