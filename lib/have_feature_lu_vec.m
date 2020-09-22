function [TorF, vstr, rdate] = have_feature_lu_vec()
%HAVE_FEATURE_LU_VEC  Detect availability/version info for LU vector support
%
%   Used by HAVE_FEATURE.

%   MP-Opt-Model
%   Copyright (c) 2004-2020, Power Systems Engineering Research Center (PSERC)
%   by Ray Zimmerman, PSERC Cornell
%
%   This file is part of MP-Opt-Model.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See https://github.com/MATPOWER/mp-opt-model for more info.

vstr = '';
rdate = '';
if have_feature('matlab') && have_feature('matlab', 'vnum') < 7.003
    TorF = 0;     %% lu(..., 'vector') syntax not supported
else
    TorF = 1;
end
