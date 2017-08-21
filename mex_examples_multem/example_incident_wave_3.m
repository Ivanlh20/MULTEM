clear all; clc;

input_multislice = multem_default_values();         % Load default values;

system_conf.precision = 1;                     % eP_Float = 1, eP_double = 2
system_conf.device = 2;                        % eD_CPU = 1, eD_GPU = 2
system_conf.cpu_ncores = 1; 
system_conf.cpu_nthread = 4; 
system_conf.gpu_device = 0;
system_conf.gpu_nstream = 1;

input_multislice.E_0 = 200;                          % Acceleration Voltage (keV)
input_multislice.theta = 0.00;
input_multislice.phi = 0.0;

input_multislice.spec_lx = 50*4.078;
input_multislice.spec_ly = 50*4.078;

input_multislice.nx = 1024; 
input_multislice.ny = 1024;

%%%%%%%%%%%%%%%%%%%%%%%%%%% Incident wave %%%%%%%%%%%%%%%%%%%%%%%%%%
input_multislice.iw_type = 3;   % 1: Plane_Wave, 2: Convergent_wave, 3:User_Define, 4: auto
input_multislice.iw_psi = read_psi_0_multem(input_multislice.nx, input_multislice.ny);    % user define incident wave
sum(abs(input_multislice.iw_psi(:)).^2)
input_multislice.iw_x = 0.0;    % x position 
input_multislice.iw_y = 0.0;    % y position

%%%%%%%%%%%%%%%%%%%%%%%% condenser lens %%%%%%%%%%%%%%%%%%%%%%%%
input_multislice.cond_lens_m = 0;                  % Vortex momentum
input_multislice.cond_lens_c_10 = 0;             % Defocus (Å)
input_multislice.cond_lens_c_30 = 0.001;            % Third order spherical aberration (mm)
input_multislice.cond_lens_c_50 = 0.00;             % Fifth order spherical aberration (mm)
input_multislice.cond_lens_c_12 = 0;             % Twofold astigmatism (Å)
input_multislice.cond_lens_phi_12 = 0.0;             % Azimuthal angle of the twofold astigmatism (°)
input_multislice.cond_lens_c_23 = 0.0;             % Threefold astigmatism (Å)
input_multislice.cond_lens_phi_23 = 0.0;             % Azimuthal angle of the threefold astigmatism (°)
input_multislice.cond_lens_inner_aper_ang = 0.0;       % Inner aperture (mrad) 
input_multislice.cond_lens_outer_aper_ang = 21.0;      % Outer aperture (mrad)
input_multislice.cond_lens_sf = 32;                % Defocus Spread (Å)
input_multislice.cond_lens_nsf = 10;               % Number of integration steps for the defocus Spread
input_multislice.cond_lens_beta = 0.2;             % Divergence semi-angle (mrad)
input_multislice.cond_lens_nbeta = 10;             % Number of integration steps for the divergence semi-angle

input_multislice.iw_x = 0.5*input_multislice.spec_lx;
input_multislice.iw_y = 0.5*input_multislice.spec_ly;

df0 = -15.836;
ax = 0:input_multislice.spec_lx/input_multislice.nx:input_multislice.spec_lx;
ay = 0:input_multislice.spec_ly/input_multislice.ny:input_multislice.spec_ly;
for df = 0
    input_multislice.cond_lens_c_10 = df;      %Angs

    tic;
    output_incident_wave = il_incident_wave(system_conf, input_multislice); 
    toc;
    psi_0 = output_incident_wave.psi_0;
    sum(abs(psi_0(:)).^2)
    
    figure(2);
    subplot(1, 2, 1);
    
    imagesc(ax, ay, abs(psi_0).^2);
    title(strcat('intensity - df = ', num2str(df)));
    axis image;
    colormap gray;

    subplot(1, 2, 2);
    imagesc(ax, ay, angle(psi_0));
    title(strcat('phase - df = ', num2str(df)));
    axis image;
    colormap gray;
    pause(0.5);
end