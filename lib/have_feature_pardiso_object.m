function [TorF, vstr, rdate] = have_feature_pardiso_object()
%HAVE_FEATURE_PARDISO_OBJECT  Detect availability/version info for PARDISO (object interface)
%
%   Used by HAVE_FEATURE.

%   MP-Opt-Model
%   Copyright (c) 2004-2020, Power Systems Engineering Research Center (PSERC)
%   by Ray Zimmerman, PSERC Cornell
%
%   This file is part of MP-Opt-Model.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See https://github.com/MATPOWER/mp-opt-model for more info.

TorF = exist('pardiso', 'file') == 2;
vstr = '';
rdate = '';
if TorF
    try
        id = 1;
        A = sparse([1 2; 3 4]);
        b = [1;1];
        p = pardiso(id, 11, 0);
        p.factorize(id, A);
        x = p.solve(id, A, b);
        p.free(id);
        p.clear();
        if any(x ~= [-1; 1])
            TorF = 0;
        end
    catch
        TorF = 0;
    end
end
