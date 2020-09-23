function [TorF, vstr, rdate] = have_feature_pardiso()
%HAVE_FEATURE_PARDISO  Detect availability/version info for PARDISO
%
%   Feature detection function implementing 'pardiso' tag for HAVE_FEATURE
%   to detect availability/version of PARDISO, Parallel Sparse Direct &
%   Iterative Linear Solver (https://pardiso-project.org).
%
%   See also HAVE_FEATURE, HAVE_FEATURE_PARDISO_LEGACY,
%   HAVE_FEATURE_PARDISO_OBJECT.

%   MIPS
%   Copyright (c) 2004-2020, Power Systems Engineering Research Center (PSERC)
%   by Ray Zimmerman, PSERC Cornell
%
%   This file is part of MIPS.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See https://github.com/MATPOWER/mips for more info.

if have_feature('pardiso_object')
    TorF = 1;
    vstr = have_feature('pardiso_object', 'vstr');
elseif have_feature('pardiso_legacy')
    TorF = 1;
    vstr = have_feature('pardiso_legacy', 'vstr');
else
    TorF = 0;
    vstr = '';
end
rdate = '';
