function out = bhi_ratio(amplitude,modulation,time,threshold,cfg)
% Estimate modulation per preceding local EEG amplitude.
width = round(cfg.window_seconds*cfg.feature_rate);
hop = round(cfg.step_seconds*cfg.feature_rate);
local_amplitude = movmedian(double(amplitude),[width-1,0],2,'Endpoints','fill');
starts = width+1:hop:size(amplitude,2)-width+1;
shape = [size(amplitude,1),numel(starts),size(modulation,1)];
out.coefficient = nan(shape);
out.observed = nan(shape);
out.fitted = nan(shape);
out.predictor = nan(shape);
out.residual = nan(shape);
out.time = time(starts+width-1);
for ch = 1:size(amplitude,1)
    for input = 1:size(modulation,1)
        for w = 1:numel(starts)
            idx = starts(w):starts(w)+width-1;
            denominator = local_amplitude(ch,idx-1);
            numerator = modulation(input,idx);
            valid = isfinite(numerator) & isfinite(denominator) & denominator>threshold;
            if ~any(valid), continue; end
            coefficient = median(numerator(valid)./denominator(valid));
            out.coefficient(ch,w,input) = coefficient;
            if valid(end)
                out.observed(ch,w,input) = numerator(end);
                out.predictor(ch,w,input) = denominator(end);
                out.fitted(ch,w,input) = coefficient*denominator(end);
                out.residual(ch,w,input) = numerator(end)-out.fitted(ch,w,input);
            end
        end
    end
end
end
