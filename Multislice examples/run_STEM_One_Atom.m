clear all; clc;

global TEM;
DefaultValues;% Load default values;

TEM.gpu = 0;            % Gpu card
TEM.SimType = 1;        % 1: STEM, 2: CBED, 3: HRTEM, 4: ED, 5: PED, 6: HCI, ... 10: EW real, 11: EW Fourier
TEM.MulOrder = 2;       % 1: First order MS, 2: Second Order MS
TEM.nConfFP = 10;        % Number of frozen phonon configurations
TEM.DimFP = 111;        % Dimensions phonon configurations
TEM.SeedFP = 1983;      % Frozen phonon random seed
TEM.PotPar = 6;         % Parameterization of the potential 1: Doyle(0-4), 2: Peng(0-4), 3: peng(0-12), 4: Kirkland(0-12), 5:Weickenmeier(0-12) adn 6: Lobato(0-12)
TEM.MEffect = 1;        % 1: Exit wave Partial coherente mode, 2: Transmission cross coefficient
TEM.STEffect = 1;       % 1: Spatial and temporal, 2: Temporal, 3: Spatial
TEM.ZeroDefTyp = 3;     % 1: First atom, 2: middle point, 3: last atom, 4: Fix Plane
TEM.ZeroDefPlane = 0;   % Zero defocus plane
TEM.ApproxModel = 3;    % 1: Mulstilice, 2: Projection approximation, 3: Phase object approximation, 4: Weak phase object approximation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TEM.E0 = 300;
TEM.theta = 0.0; TEM.phi = 0; % Till ilumination (degrees)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TEM.MC.m = 0;       %mm
TEM.MC.f = 88.7414; %Angs
TEM.MC.Cs3 = 0.04;	%mm
TEM.MC.Cs5 = 0.00;	%mm
TEM.MC.mfa2 = 0.0; TEM.MC.afa2 = 0.0; %(Angs, degrees)
TEM.MC.mfa3 = 0.0; TEM.MC.afa3 = 0.0; %(Angs, degrees)
TEM.MC.aobjl = 0.0; TEM.MC.aobju = 21.0659; %(mrad, mrad)
TEM.MC.sf = 32; TEM.MC.nsf = 10; % (Angs, number of steps)ne
TEM.MC.beta = 0.2; TEM.MC.nbeta = 10; %(mrad, half number of steps)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
na = 1; nb = 1; nc = 10; ncu = 8; rmsAu3D = 0.2; sigma = sqrt(rmsAu3D^2/3);
[TEM.Atoms, TEM.lx, TEM.ly, lz, a, b, c, TEM.dz] = PrimitiveCrystal(na, nb, nc, ncu, sigma);
TEM.nx = 2048; TEM.ny = 2048; nxh = TEM.nx/2; nyh = TEM.ny/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TEM.STEM.line = 1;
TEM.STEM.FastCal = 0;
TEM.STEM.ns = 50;
TEM.STEM.x1u = 0.25*TEM.lx; TEM.STEM.y1u = 0.5*TEM.ly;
TEM.STEM.x2u = 0.75*TEM.lx; TEM.STEM.y2u = 0.5*TEM.ly;
TEM.STEM.nDet = 7;
TEM.STEM.DetCir(1).InnerAng = 10; TEM.STEM.DetCir(1).OuterAng = 170;	% Inner angle(mrad) and Outer angle(mrad)
TEM.STEM.DetCir(2).InnerAng = 20; TEM.STEM.DetCir(2).OuterAng = 170;	% Inner angle(mrad) and Outer angle(mrad)
TEM.STEM.DetCir(3).InnerAng = 40; TEM.STEM.DetCir(3).OuterAng = 170;	% Inner angle(mrad) and Outer angle(mrad)
TEM.STEM.DetCir(4).InnerAng = 60; TEM.STEM.DetCir(4).OuterAng = 170;	% Inner angle(mrad) and Outer angle(mrad)
TEM.STEM.DetCir(5).InnerAng = 80; TEM.STEM.DetCir(5).OuterAng = 170;	% Inner angle(mrad) and Outer angle(mrad)
TEM.STEM.DetCir(6).InnerAng = 100; TEM.STEM.DetCir(6).OuterAng = 170;	% Inner angle(mrad) and Outer angle(mrad)
TEM.STEM.DetCir(7).InnerAng = 120; TEM.STEM.DetCir(7).OuterAng = 170;	% Inner angle(mrad) and Outer angle(mrad)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
clear MULTEMMat;
STEM = MULTEMMat(TEM);
toc;

for i=1:7
    figure(i); %clf;
    subplot(1, 2, 1);
    hold on;
    plot(STEM.DetInt(i).Tot, '-k');
%     ylim([0 1.1*max(STEM.DetInt(i).Tot)]);
    subplot(1, 2, 2);
    hold on;
    plot(STEM.DetInt(i).Coh, '-k');
%     ylim([0 1.1*max(STEM.DetInt(i).Tot)]);
%     sum(STEM.DetInt(i).Coh(:))/sum(STEM.DetInt(i).Tot(:))
%     xlim([42 60])
end;
% close all
