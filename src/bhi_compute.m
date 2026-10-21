function result = bhi_compute(data,cfg)
% Compute four directional indices across all configured bands.
assert(cfg.lag_samples==1);
assert(all(cfg.minimum_amplitude>0) && all(isfinite(cfg.minimum_amplitude)));
features = bhi_align(data,cfg);
result.config = cfg;
result.channel_labels = features.channel_labels;
result.rois = bhi_rois;
result.feature_time = features.time;
for b = 1:numel(cfg.bands)
    band = cfg.bands{b};
    h2b = bhi_arx(features.amplitude.(band),features.hrv,features.time,cfg);
    b2h = bhi_ratio(features.amplitude.(band),features.modulation, ...
        features.time,cfg.minimum_amplitude(b),cfg);
    indices.LToB = h2b.coefficient(:,:,1);
    indices.HToB = h2b.coefficient(:,:,2);
    indices.BToL = b2h.coefficient(:,:,1);
    indices.BToH = b2h.coefficient(:,:,2);
    indices.heart_to_brain_time = h2b.time;
    indices.brain_to_heart_time = b2h.time;
    result.channel.(band) = indices;
    directions = {'LToB','HToB','BToL','BToH'};
    for d = 1:numel(directions)
        name = directions{d};
        result.roi.(band).(name) = bhi_roi_average(indices.(name),features.channel_labels);
    end
    result.roi.(band).heart_to_brain_time = h2b.time;
    result.roi.(band).brain_to_heart_time = b2h.time;
    result.model.(band).heart_to_brain = h2b;
    result.model.(band).brain_to_heart = b2h;
end
end
