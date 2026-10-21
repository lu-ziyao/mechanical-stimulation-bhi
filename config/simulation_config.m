function cfg = simulation_config
% Set directional simulation parameters.
cfg = bhi_config(0.20*ones(1,6));
cfg.random_seed = 20260928;
cfg.duration_seconds = 60;
cfg.burn_in_seconds = 10;
cfg.coupling_strengths = [0,0.15,0.30,0.45];
cfg.noise_levels = [0.25,0.50,1.00];
cfg.repetitions = 40;
cfg.calibration_repetitions = 40;
cfg.surrogates = 25;
cfg.amplitude_offset = 2.5;
cfg.amplitude_scale = 0.35;
cfg.conditions = {'No coupling','Brain-to-heart','Heart-to-brain','Bidirectional'};
end
