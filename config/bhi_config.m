function cfg = bhi_config(minimum_amplitude)
% Set model parameters; default amplitude threshold is 0.20 for all six bands.
arguments
    minimum_amplitude (1,6) double {mustBeFinite,mustBePositive} = 0.20*ones(1,6)
end
cfg.feature_rate = 4;
cfg.window_seconds = 5;
cfg.step_seconds = 1;
cfg.rr_window_seconds = 15;
cfg.rr_step_seconds = 1;
cfg.lf_frequency = 0.1;
cfg.hf_frequency = 0.25;
cfg.gamma_tolerance = 1e-9;
cfg.lag_samples = 1;
cfg.minimum_rcond = 1e-10;
cfg.bands = {'delta','theta','alpha','beta','high_beta','gamma'};
cfg.frequency_limits = [0 4;4 8;8 12;13 20;20 35;45 90];
cfg.minimum_amplitude = minimum_amplitude;
cfg.diagnostic_stride = 5;
cfg.diagnostic_max_lag_seconds = 10;
end
