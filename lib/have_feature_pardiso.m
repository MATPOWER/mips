function [TorF, vstr, rdate] = have_feature_pardiso()
%HAVE_FEATURE_PARDISO  Detect availability/version info for PARDISO
%
%   Used by HAVE_FEATURE.

%   MP-Opt-Model
%   Copyright (c) 2004-2020, Power Systems Engineering Research Center (PSERC)
%   by Ray Zimmerman, PSERC Cornell
%
%   This file is part of MP-Opt-Model.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See https://github.com/MATPOWER/mp-opt-model for more info.

TorF = have_feature('pardiso_object') || have_feature('pardiso_legacy');
vstr = '';
rdate = '';
