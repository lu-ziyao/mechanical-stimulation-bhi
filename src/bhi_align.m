function features = bhi_align(data,cfg)
% Interpolate features onto their common physical time grid.
[modulation,modulation_time] = bhi_ipfm(data.rr_intervals,data.rr_time,cfg);
eeg_time = double(data.eeg_time(:));
hrv_time = double(data.hrv_time(:));
assert(all(isfinite(eeg_time)) && all(diff(eeg_time)>0));
assert(all(isfinite(hrv_time)) && all(diff(hrv_time)>0));
first = max([eeg_time(1),hrv_time(1),modulation_time(1)]);
last = min([eeg_time(end),hrv_time(end),modulation_time(end)]);
time = (ceil(first*cfg.feature_rate):floor(last*cfg.feature_rate))'/cfg.feature_rate;
assert(numel(time)>=2*round(cfg.window_seconds*cfg.feature_rate));
features.time = time;
features.channel_labels = cellstr(string(data.channel_labels(:)));
assert(numel(unique(lower(string(features.channel_labels))))==numel(features.channel_labels));
for b = 1:numel(cfg.bands)
    band = cfg.bands{b};
    power = double(data.eeg_power.(band));
    assert(isequal(size(power),[numel(features.channel_labels),numel(eeg_time)]));
    assert(all(power(:)>=0 | isnan(power(:))));
    features.amplitude.(band) = sqrt(interp1(eeg_time,power',time,'linear')');
end
hrv = [double(data.lf_power(:)),double(data.hf_power(:))];
assert(size(hrv,1)==numel(hrv_time));
features.hrv = interp1(hrv_time,hrv,time,'linear')';
features.modulation = bhi_standardize(interp1(modulation_time,modulation',time,'spline')');
end
