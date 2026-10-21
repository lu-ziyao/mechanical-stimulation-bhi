function [modulation,time] = bhi_ipfm(rr,rr_time,cfg)
% Estimate LF and HF modulation from trailing RR windows.
% SPDX-License-Identifier: GPL-3.0-or-later
% Adapted from Catrambone and Valenza, copyright 2019.
rr = double(rr(:));
rr_time = double(rr_time(:));
assert(numel(rr)==numel(rr_time) && all(isfinite(rr)) && all(rr>0));
assert(all(isfinite(rr_time)) && all(diff(rr_time)>0));
first = rr_time(1)-rr(1)+cfg.rr_window_seconds;
first = ceil(first/cfg.rr_step_seconds)*cfg.rr_step_seconds;
last = floor(rr_time(end)/cfg.rr_step_seconds)*cfg.rr_step_seconds;
time = (first:cfg.rr_step_seconds:last)';
assert(numel(time)>=2,'RR coverage must include at least two parameter windows.');
modulation = nan(2,numel(time));
wlf = 2*pi*cfg.lf_frequency;
whf = 2*pi*cfg.hf_frequency;
previous = [0;0];
for k = 1:numel(time)
    local = rr(rr_time>time(k)-cfg.rr_window_seconds & rr_time<=time(k));
    if numel(local)<2, continue; end
    rate = 1/mean(local);
    slf = sin(wlf/(2*rate));
    shf = sin(whf/(2*rate));
    gamma = shf-slf;
    descriptors = [max(local)-min(local);sqrt(2)*max(abs(diff(local)))];
    transform = [shf*wlf*rate/(4*slf), -sqrt(2)*wlf*rate/(8*slf); ...
        -slf*whf*rate/(4*shf), sqrt(2)*whf*rate/(8*shf)];
    if abs(gamma)>=cfg.gamma_tolerance
        previous = transform*descriptors/gamma;
    end
    modulation(:,k) = previous;
end
end
