function values = simulation_indices(amplitude,cardiac,time,cfg)
% Estimate both directions using the model functions.
h2b = bhi_arx(amplitude,cardiac,time,cfg);
b2h = bhi_ratio(amplitude,cardiac,time,cfg.minimum_amplitude(1),cfg);
values = [median(b2h.coefficient(:),'omitnan'), ...
    median(h2b.coefficient(:),'omitnan')];
end
