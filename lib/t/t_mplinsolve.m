function t_mplinsolve(quiet)
% t_mplinsolve - Tests of mplinsolve, MIPS/|MATPOWER| linear solvers.
% ::
%
%   t_mplinsolve
%   t_mplinsolve(quiet)

%   MIPS
%   Copyright (c) 2015-2024, Power Systems Engineering Research Center (PSERC)
%   by Ray Zimmerman, PSERC Cornell
%
%   This file is part of MIPS.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See https://github.com/MATPOWER/mips for more info.

if nargin < 1
    quiet = 0;
end

t_begin(180, quiet);

isoctave = exist('OCTAVE_VERSION', 'builtin') == 5;
if isoctave
    lu_warning_id = 'Octave:lu:sparse_input';
    s = warning('query', lu_warning_id);
    warning('off', lu_warning_id);
end

%% non-sparse A matrix crashes some MATLAB lu() calls on certain
%% combinations of MATLAB and macOS versions
mlv = have_feature('matlab', 'vnum');
skipcrash = ~isempty(mlv) && mlv < 8.003 && mlv > 7.013 && ...
    strcmp(computer, 'MACI64');

ijs = [
    1 1 1205.63;
    4 1 -1205.63;
    25 1 17.3611;
    28 1 -17.3611;
    43 1 1;
    2 2 1024;
    8 2 -1024;
    26 2 16;
    32 2 -16;
    3 3 1164.84;
    6 3 -1164.84;
    27 3 17.0648;
    30 3 -17.0648;
    1 4 -1205.63;
    4 4 2201.34;
    5 4 -453.695;
    9 4 -542.009;
    13 4 0.776236;
    14 4 -0.451721;
    18 4 -0.324515;
    25 4 -17.3611;
    28 4 39.4759;
    29 4 -10.5107;
    33 4 -11.6041;
    37 4 -3.30738;
    38 4 1.94219;
    42 4 1.36519;
    4 5 -453.695;
    5 5 581.372;
    6 5 -127.677;
    13 5 -0.451721;
    14 5 0.568201;
    15 5 -0.11648;
    28 5 -10.5107;
    29 5 16.0989;
    30 5 -5.58824;
    37 5 1.94219;
    38 5 -3.2242;
    39 5 1.28201;
    3 6 -1164.84;
    5 6 -127.677;
    6 6 1676.74;
    7 6 -384.227;
    14 6 -0.11648;
    15 6 0.163059;
    16 6 -0.0465791;
    27 6 -17.0648;
    29 6 -5.58824;
    30 6 32.4374;
    31 6 -9.78427;
    38 6 1.28201;
    39 6 -2.4371;
    40 6 1.15509;
    6 7 -384.227;
    7 7 1141.16;
    8 7 -756.935;
    15 7 -0.0465791;
    16 7 0.371828;
    17 7 -0.325249;
    30 7 -9.78427;
    31 7 23.4822;
    32 7 -13.698;
    39 7 1.15509;
    40 7 -2.77221;
    41 7 1.61712;
    2 8 -1024;
    7 8 -756.935;
    8 8 1925.77;
    9 8 -144.836;
    16 8 -0.325249;
    17 8 0.844105;
    18 8 -0.518855;
    26 8 -16;
    31 8 -13.698;
    32 8 35.6731;
    33 8 -5.97513;
    40 8 1.61712;
    41 8 -2.80473;
    42 8 1.1876;
    4 9 -542.009;
    8 9 -144.836;
    9 9 686.845;
    13 9 -0.324515;
    17 9 -0.518855;
    18 9 0.84337;
    28 9 -11.6041;
    32 9 -5.97513;
    33 9 17.5792;
    37 9 1.36519;
    41 9 1.1876;
    42 9 -2.55279;
    10 10 1207.63;
    13 10 -1205.63;
    34 10 17.3611;
    37 10 -17.3611;
    11 11 1026;
    17 11 -1024;
    35 11 16;
    41 11 -16;
    12 12 1166.84;
    15 12 -1164.84;
    36 12 17.0648;
    39 12 -17.0648;
    4 13 0.776236;
    5 13 -0.451721;
    9 13 -0.324515;
    10 13 -1205.63;
    13 13 2190.83;
    14 13 -447.892;
    18 13 -535.137;
    28 13 3.30738;
    29 13 -1.94219;
    33 13 -1.36519;
    34 13 -17.3611;
    37 13 39.1419;
    38 13 -10.5107;
    42 13 -11.6041;
    4 14 -0.451721;
    5 14 0.568201;
    6 14 -0.11648;
    13 14 -447.892;
    14 14 573.221;
    15 14 -122.862;
    28 14 -1.94219;
    29 14 3.2242;
    30 14 -1.28201;
    37 14 -10.5107;
    38 14 15.5829;
    39 14 -5.58824;
    5 15 -0.11648;
    6 15 0.163059;
    7 15 -0.0465791;
    12 15 -1164.84;
    14 15 -122.862;
    15 15 1669.87;
    16 15 -379.651;
    29 15 -1.28201;
    30 15 2.4371;
    31 15 -1.15509;
    36 15 -17.0648;
    38 15 -5.58824;
    39 15 31.8704;
    40 15 -9.78427;
    6 16 -0.0465791;
    7 16 0.371828;
    8 16 -0.325249;
    15 16 -379.651;
    16 16 1131.92;
    17 16 -750.073;
    30 16 -1.15509;
    31 16 2.77221;
    32 16 -1.61712;
    39 16 -9.78427;
    40 16 23.1242;
    41 16 -13.698;
    7 17 -0.325249;
    8 17 0.844105;
    9 17 -0.518855;
    11 17 -1024;
    16 17 -750.073;
    17 17 1914.92;
    18 17 -138.499;
    31 17 -1.61712;
    32 17 2.80473;
    33 17 -1.1876;
    35 17 -16;
    40 17 -13.698;
    41 17 35.2181;
    42 17 -5.97513;
    4 18 -0.324515;
    8 18 -0.518855;
    9 18 0.84337;
    13 18 -535.137;
    17 18 -138.499;
    18 18 676.012;
    28 18 -1.36519;
    32 18 -1.1876;
    33 18 2.55279;
    37 18 -11.6041;
    41 18 -5.97513;
    42 18 17.0972;
    19 19 1.88667;
    25 19 -1;
    20 20 1.54931;
    26 20 -1;
    21 21 1.78346;
    27 21 -1;
    22 22 0.666667;
    34 22 -1;
    23 23 0.666667;
    35 23 -1;
    24 24 0.666667;
    36 24 -1;
    1 25 17.3611;
    4 25 -17.3611;
    19 25 -1;
    2 26 16;
    8 26 -16;
    20 26 -1;
    3 27 17.0648;
    6 27 -17.0648;
    21 27 -1;
    1 28 -17.3611;
    4 28 39.4759;
    5 28 -10.5107;
    9 28 -11.6041;
    13 28 3.30738;
    14 28 -1.94219;
    18 28 -1.36519;
    4 29 -10.5107;
    5 29 16.0989;
    6 29 -5.58824;
    13 29 -1.94219;
    14 29 3.2242;
    15 29 -1.28201;
    3 30 -17.0648;
    5 30 -5.58824;
    6 30 32.4374;
    7 30 -9.78427;
    14 30 -1.28201;
    15 30 2.4371;
    16 30 -1.15509;
    6 31 -9.78427;
    7 31 23.4822;
    8 31 -13.698;
    15 31 -1.15509;
    16 31 2.77221;
    17 31 -1.61712;
    2 32 -16;
    7 32 -13.698;
    8 32 35.6731;
    9 32 -5.97513;
    16 32 -1.61712;
    17 32 2.80473;
    18 32 -1.1876;
    4 33 -11.6041;
    8 33 -5.97513;
    9 33 17.5792;
    13 33 -1.36519;
    17 33 -1.1876;
    18 33 2.55279;
    10 34 17.3611;
    13 34 -17.3611;
    22 34 -1;
    11 35 16;
    17 35 -16;
    23 35 -1;
    12 36 17.0648;
    15 36 -17.0648;
    24 36 -1;
    4 37 -3.30738;
    5 37 1.94219;
    9 37 1.36519;
    10 37 -17.3611;
    13 37 39.1419;
    14 37 -10.5107;
    18 37 -11.6041;
    4 38 1.94219;
    5 38 -3.2242;
    6 38 1.28201;
    13 38 -10.5107;
    14 38 15.5829;
    15 38 -5.58824;
    5 39 1.28201;
    6 39 -2.4371;
    7 39 1.15509;
    12 39 -17.0648;
    14 39 -5.58824;
    15 39 31.8704;
    16 39 -9.78427;
    6 40 1.15509;
    7 40 -2.77221;
    8 40 1.61712;
    15 40 -9.78427;
    16 40 23.1242;
    17 40 -13.698;
    7 41 1.61712;
    8 41 -2.80473;
    9 41 1.1876;
    11 41 -16;
    16 41 -13.698;
    17 41 35.2181;
    18 41 -5.97513;
    4 42 1.36519;
    8 42 1.1876;
    9 42 -2.55279;
    13 42 -11.6041;
    17 42 -5.97513;
    18 42 17.0972;
    1 43 1;
];
A = sparse(ijs(:, 1), ijs(:, 2), ijs(:, 3));
b = [
    0;
    0;
    0;
    0;
    0;
    0;
    0;
    0;
    0;
    0;
    0;
    0;
    -0.00896054;
    -0.0617829;
    -0.0772931;
    -0.0230638;
    -0.0185934;
    -0.02;
    -0.336;
    -0.2755;
    -0.353;
    0;
    0;
    0;
    1.3;
    1.55;
    1.4;
    0;
    -0.9;
    0;
    -1;
    0;
    -1.25;
    0;
    0;
    0;
    0.167;
    -0.042;
    0.2835;
    -0.171;
    0.2275;
    -0.259;
    0;
];
% ex = [      %% for original symmetrical system
% 0;
% 0.04612219791119214;
% 0.0509334351882598;
% -0.05953571031927305;
% -0.09461814898578046;
% -0.008909854578010561;
% -0.05785829019394401;
% -0.02232729212460287;
% -0.1137760871247425;
% -0.03062777824802364;
% -0.01013282572376477;
% -0.005330939680091628;
% -0.02914165388753019;
% -0.03376073204420303;
% 4.021341450281111e-05;
% -0.01727289094763518;
% -0.008382063634320435;
% -0.04854008812629265;
% -0.2663945795760685;
% -0.4548081594272799;
% -0.3787862287965494;
% -0.02580075363496279;
% -0.02801219343110931;
% -0.09165765332863518;
% -0.1665986614487812;
% -0.4291388294822789;
% -0.3225500876094941;
% 3.967864472606993;
% 5.577372159790927;
% 3.762341481664236;
% 5.858342308599034;
% 3.951628532808602;
% 6.471657726723339;
% -0.01720051102355974;
% -0.01867480495813735;
% -0.06110513277164123;
% -0.1239317474796463;
% -0.1848327901217308;
% -0.4283638085291988;
% 0.07640167050820651;
% -0.1319901818980452;
% 0.4366406661538687;
% 0.0007894844305239289;
% ];
A(8, 2) = -500;     %% make non-symmetrical
ex = [
   0.000000000000000
   0.015818764480650
   0.028627515055857
  -0.066470494209706
  -0.106338553472755
  -0.029556247483918
  -0.080778493974592
  -0.046876059940052
  -0.126748712178182
  -0.032582479109501
  -0.010646589107665
  -0.006489850319503
  -0.030082640379903
  -0.034809123585434
  -0.001497869375252
  -0.018761742104354
  -0.009797350675461
  -0.049351378784847
  -0.145999102975876
  -0.546882809268771
  -0.407105729011254
  -0.043399950168419
  -0.013587814915265
  -0.085187156417456
   0.060547872388504
  -0.571791005228199
  -0.373056783462411
   4.199136375632448
   5.730774734397821
   3.598555773194044
   5.477255481510613
   3.440677757696717
   6.533433414753445
  -0.028933314578930
  -0.009058547806115
  -0.056791466007356
  -0.206286450370091
  -0.246526980342321
  -0.398303747647950
   0.132430861414235
  -0.064740631105635
   0.368923140091142
  -8.288373070379230
];

t = ''''' : ';
x = mplinsolve(A, b, '');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
x = mplinsolve(full(A), b, '');
t_is(x, ex, 12, [t 'x (full A)']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);

t = '\ : ';
x = mplinsolve(A, b, '\');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
x = mplinsolve(full(A), b, '\');
t_is(x, ex, 12, [t 'x (full A)']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);

t = '\ (transpose) : ';
opt = struct('tr', 1);
x = mplinsolve(A', b, '\', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
x = mplinsolve(full(A'), b, '\', opt);
t_is(x, ex, 12, [t 'x (full A)']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);

t = 'LU : ';
x = mplinsolve(A, b, 'LU');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    x = mplinsolve(full(A), b, 'LU');
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'LU (transpose) : ';
opt = struct('tr', 1);
x = mplinsolve(A', b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    x = mplinsolve(full(A'), b, 'LU', opt);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'LU3 : ';
x = mplinsolve(A, b, 'LU3');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    x = mplinsolve(full(A), b, 'LU3');
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end
t = 'LU, nout = 3, vec = 1, thresh = 1 : ';
opt = struct('nout', 3, 'vec', 1, 'thresh', 1);
x = mplinsolve(A, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    x = mplinsolve(full(A), b, 'LU', opt);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'LU3a : ';
x = mplinsolve(A, b, 'LU3a');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    x = mplinsolve(full(A), b, 'LU3a');
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end
t = 'LU, nout = 3, vec = 1 : ';
opt = struct('nout', 3, 'vec', 1);
x = mplinsolve(A, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    x = mplinsolve(full(A), b, 'LU', opt);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'LU4 : ';
x = mplinsolve(A, b, 'LU4');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
t = 'LU, nout = 4, vec = 1 : ';
opt = struct('nout', 4, 'vec', 1);
x = mplinsolve(A, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);

t = 'LU5 : ';
x = mplinsolve(A, b, 'LU5');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
t = 'LU, nout = 5, vec = 1 : ';
opt = struct('nout', 5, 'vec', 1);
x = mplinsolve(A, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);

t = 'LU3m : ';
x = mplinsolve(A, b, 'LU3m');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    x = mplinsolve(full(A), b, 'LU3m');
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end
t = 'LU, nout = 3, vec = 0, thresh = 1 : ';
opt = struct('nout', 3, 'vec', 0, 'thresh', 1);
x = mplinsolve(A, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    x = mplinsolve(full(A), b, 'LU', opt);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'LU3am : ';
x = mplinsolve(A, b, 'LU3am');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    x = mplinsolve(full(A), b, 'LU3am');
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end
t = 'LU, nout = 3, vec = 0 : ';
opt = struct('nout', 3, 'vec', 0);
x = mplinsolve(A, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    x = mplinsolve(full(A), b, 'LU', opt);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'LU4m : ';
x = mplinsolve(A, b, 'LU4m');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
t = 'LU, nout = 4, vec = 0 : ';
opt = struct('nout', 4, 'vec', 0);
x = mplinsolve(A, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);

t = 'LU5m : ';
x = mplinsolve(A, b, 'LU5m');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
t = 'LU, nout = 5, vec = 0 : ';
opt = struct('nout', 5, 'vec', 0);
x = mplinsolve(A, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);

%%-----  repeat all LU tests with saved factors  -----
t = 'pre-factored LU : ';
f = mplinsolve(A);
x = mplinsolve(f, b);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    f = mplinsolve(full(A));
    x = mplinsolve(f, b);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'pre-factored LU3 : ';
f = mplinsolve(A, [], 'LU3');
x = mplinsolve(f, b, 'LU3');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    f = mplinsolve(full(A), [], 'LU3');
    x = mplinsolve(f, b, 'LU3');
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end
t = 'pre-factored LU, nout = 3, vec = 1, thresh = 1 : ';
opt = struct('nout', 3, 'vec', 1, 'thresh', 1);
[x, f] = mplinsolve(A, b, 'LU', opt);
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    opt = struct('nout', 3, 'vec', 1, 'thresh', 1);
    [x, f] = mplinsolve(full(A), b, 'LU', opt);
    x = mplinsolve(f, b, 'LU', opt);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'pre-factored LU3a : ';
[x1, f] = mplinsolve(A, b, 'LU3a');
x = mplinsolve(f, b, 'LU3a');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    [x1, f] = mplinsolve(full(A), b, 'LU3a');
    x = mplinsolve(f, b, 'LU3a');
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end
t = 'pre-factored LU, nout = 3, vec = 1 : ';
opt = struct('nout', 3, 'vec', 1);
f = mplinsolve(A, [], 'LU', opt);
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    opt = struct('nout', 3, 'vec', 1);
    f = mplinsolve(full(A), [], 'LU', opt);
    x = mplinsolve(f, b, 'LU', opt);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'pre-factored LU4 : ';
[x, f] = mplinsolve(A, b, 'LU4');
x = mplinsolve(f, b, 'LU4');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
t = 'pre-factored LU, nout = 4, vec = 1 : ';
opt = struct('nout', 4, 'vec', 1);
f = mplinsolve(A, [], 'LU', opt);
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);

t = 'pre-factored LU5 : ';
f = mplinsolve(A, [], 'LU5');
x = mplinsolve(f, b, 'LU5');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
t = 'pre-factored LU, nout = 5, vec = 1 : ';
opt = struct('nout', 5, 'vec', 1);
[x, f] = mplinsolve(A, b, 'LU', opt);
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);

t = 'pre-factored LU3m : ';
f = mplinsolve(A, [], 'LU3m');
x = mplinsolve(f, b, 'LU3m');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    f = mplinsolve(full(A), [], 'LU3m');
    x = mplinsolve(f, b, 'LU3m');
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end
t = 'pre-factored LU, nout = 3, vec = 0, thresh = 1 : ';
opt = struct('nout', 3, 'vec', 0, 'thresh', 1);
[x, f] = mplinsolve(A, b, 'LU', opt);
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    opt = struct('nout', 3, 'vec', 0, 'thresh', 1);
    f = mplinsolve(full(A), [], 'LU', opt);
    x = mplinsolve(f, b, 'LU', opt);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'pre-factored LU3am : ';
f = mplinsolve(A, [], 'LU3am');
x = mplinsolve(f, b, 'LU3am');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    f = mplinsolve(full(A), [], 'LU3am');
    x = mplinsolve(f, b, 'LU3am');
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end
t = 'pre-factored LU, nout = 3, vec = 0 : ';
opt = struct('nout', 3, 'vec', 0);
f = mplinsolve(A, [], 'LU', opt);
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    opt = struct('nout', 3, 'vec', 0);
    [x, f] = mplinsolve(full(A), b, 'LU', opt);
    x = mplinsolve(f, b, 'LU', opt);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'pre-factored LU4m : ';
[x1, f] = mplinsolve(A, b, 'LU4m');
x = mplinsolve(f, b, 'LU4m');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
t = 'pre-factored LU, nout = 4, vec = 0 : ';
opt = struct('nout', 4, 'vec', 0);
f = mplinsolve(A, [], 'LU', opt);
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);

t = 'pre-factored LU5m : ';
f = mplinsolve(A, [], 'LU5m');
x = mplinsolve(f, b, 'LU5m');
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
t = 'pre-factored LU, nout = 5, vec = 0 : ';
opt = struct('nout', 5, 'vec', 0);
[x, f] = mplinsolve(A, b, 'LU', opt);
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);

%%-----  repeat all LU tests with saved factors AND transpose  -----
t = 'transposed LU : ';
f = mplinsolve(A');
x = mplinsolve(f, b, 'LU', struct('tr', 1));
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    f = mplinsolve(full(A'));
    x = mplinsolve(f, b, 'LU', struct('tr', 1));
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'transposed LU3 : ';
f = mplinsolve(A', [], 'LU3');
x = mplinsolve(f, b, 'LU3', struct('tr', 1));
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    [x1, f] = mplinsolve(full(A'), b, 'LU3');
    x = mplinsolve(f, b, 'LU3', struct('tr', 1));
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end
t = 'transposed LU, nout = 3, vec = 1, thresh = 1 : ';
opt = struct('nout', 3, 'vec', 1, 'thresh', 1);
[x, f] = mplinsolve(A', b, 'LU', opt);
opt.tr = 1;
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    opt = struct('nout', 3, 'vec', 1, 'thresh', 1);
    [x, f] = mplinsolve(full(A'), b, 'LU', opt);
    opt.tr = 1;
    x = mplinsolve(f, b, 'LU', opt);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'transposed LU3a : ';
f = mplinsolve(A', [], 'LU3a');
x = mplinsolve(f, b, 'LU3a', struct('tr', 1));
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    f = mplinsolve(full(A'), [], 'LU3a');
    x = mplinsolve(f, b, 'LU3a', struct('tr', 1));
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end
t = 'transposed LU, nout = 3, vec = 1 : ';
opt = struct('nout', 3, 'vec', 1);
f = mplinsolve(A', [], 'LU', opt);
opt.tr = 1;
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    opt = struct('nout', 3, 'vec', 1);
    [x, f] = mplinsolve(full(A'), b, 'LU', opt);
    opt.tr = 1;
    x = mplinsolve(f, b, 'LU', opt);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'transposed LU4 : ';
[x1, f] = mplinsolve(A', b, 'LU4');
x = mplinsolve(f, b, 'LU4', struct('tr', 1));
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
t = 'transposed LU, nout = 4, vec = 1 : ';
opt = struct('nout', 4, 'vec', 1);
f = mplinsolve(A', [], 'LU', opt);
opt.tr = 1;
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);

t = 'transposed LU5 : ';
f = mplinsolve(A', [], 'LU5');
x = mplinsolve(f, b, 'LU5', struct('tr', 1));
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
t = 'transposed LU, nout = 5, vec = 1 : ';
opt = struct('nout', 5, 'vec', 1);
f = mplinsolve(A', [], 'LU', opt);
opt.tr = 1;
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);

t = 'transposed LU3m : ';
[x1, f] = mplinsolve(A', b, 'LU3m');
x = mplinsolve(f, b, 'LU3m', struct('tr', 1));
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    f = mplinsolve(full(A'), [], 'LU3m');
    x = mplinsolve(f, b, 'LU3m', struct('tr', 1));
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end
t = 'transposed LU, nout = 3, vec = 0, thresh = 1 : ';
opt = struct('nout', 3, 'vec', 0, 'thresh', 1);
f = mplinsolve(A', [], 'LU', opt);
opt.tr = 1;
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    opt = struct('nout', 3, 'vec', 0, 'thresh', 1);
    [x, f] = mplinsolve(full(A'), b, 'LU', opt);
    opt.tr = 1;
    x = mplinsolve(f, b, 'LU', opt);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'transposed LU3am : ';
[x1, f] = mplinsolve(A', b, 'LU3am');
x = mplinsolve(f, b, 'LU3am', struct('tr', 1));
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    f = mplinsolve(full(A'), [], 'LU3am');
    x = mplinsolve(f, b, 'LU3am', struct('tr', 1));
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end
t = 'transposed LU, nout = 3, vec = 0 : ';
opt = struct('nout', 3, 'vec', 0);
f = mplinsolve(A', [], 'LU', opt);
opt.tr = 1;
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
if skipcrash
    t_skip(2, [t 'potential MATLAB crash with non-sparse A']);
else
    opt = struct('nout', 3, 'vec', 0);
    f = mplinsolve(full(A'), [], 'LU', opt);
    opt.tr = 1;
    x = mplinsolve(f, b, 'LU', opt);
    t_is(x, ex, 12, [t 'x (full A)']);
    t_is(norm(b - A*x), 0, 12, [t '||b - A*x|| (full A)']);
end

t = 'transposed LU4m : ';
f = mplinsolve(A', [], 'LU4m');
x = mplinsolve(f, b, 'LU4m', struct('tr', 1));
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
t = 'transposed LU, nout = 4, vec = 0 : ';
opt = struct('nout', 4, 'vec', 0);
f = mplinsolve(A', [], 'LU', opt);
opt.tr = 1;
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);

t = 'transposed LU5m : ';
[x1, f] = mplinsolve(A', b, 'LU5m');
x = mplinsolve(f, b, 'LU5m', struct('tr', 1));
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);
t = 'transposed LU, nout = 5, vec = 0 : ';
opt = struct('nout', 5, 'vec', 0);
[x, f] = mplinsolve(A', b, 'LU', opt);
opt.tr = 1;
x = mplinsolve(f, b, 'LU', opt);
t_is(x, ex, 12, [t 'x']);
t_is(norm(b - A*x), 0, 12, [t '||b - A*x||']);

%% PARDISO
if have_feature('pardiso')
    if have_feature('pardiso_object')
        tols = [6 5 12 12 6 5];     %% tolerances for PARDISO v6
    else
        tols = [13 13 12 12 1 2];   %% tolerances for PARDISO v5
    end
    vb = false;

    t = 'PARDISO (direct) : ';
    opt = struct('pardiso', struct('solver', 0, 'verbose', vb));
    x = mplinsolve(A, b, 'PARDISO', opt);
    t_is(x, ex, tols(1), [t 'x']);
    t_is(norm(b - A*x), 0, tols(2), [t '||b - A*x||']);

    t = 'PARDISO (direct, transpose) : ';
    opt = struct('pardiso', struct('solver', 0, 'tr', 1, 'verbose', vb));
    x = mplinsolve(A', b, 'PARDISO', opt);
    t_is(x, ex, tols(1), [t 'x']);
    t_is(norm(b - A*x), 0, tols(2), [t '||b - A*x||']);

    t = 'PARDISO (direct, symmetric indefinite) : ';
    opt = struct('pardiso', struct('solver', 0, 'mtype', -2, 'verbose', vb));
    x = mplinsolve(A, b, 'PARDISO', opt);
    t_is(x, ex, tols(3), [t 'x']);
    t_is(norm(b - A*x), 0, tols(4), [t '||b - A*x||']);

    t = 'PARDISO (iterative) : ';
    opt = struct('pardiso', struct('solver', 1, 'verbose', vb));
    [x, info] = mplinsolve(A, b, 'PARDISO', opt);
    t_is(x, ex, tols(5), [t 'x']);
    t_is(norm(b - A*x), 0, tols(6), [t '||b - A*x||']);
else
    t_skip(8, ['PARDISO not available']);
end

if isoctave
    warning(s.state, lu_warning_id);
end

t_end;
