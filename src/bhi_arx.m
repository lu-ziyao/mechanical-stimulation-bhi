function out = bhi_arx(amplitude,cardiac,time,cfg)
% Fit standardized ARX(1,1,1) coefficients in each window.
y = bhi_standardize(double(amplitude));
u = bhi_standardize(double(cardiac));
width = round(cfg.window_seconds*cfg.feature_rate);
hop = round(cfg.step_seconds*cfg.feature_rate);
starts = 1:hop:size(y,2)-width+1;
nchannels = size(y,1);
ninputs = size(u,1);
shape = [nchannels,numel(starts),ninputs];
out.coefficient = nan(shape);
out.autoregressive = nan(shape);
out.observed = nan(shape);
out.fitted = nan(shape);
out.predictor = nan(shape);
out.residual = nan(shape);
out.time = time(starts+width-1);
for ch = 1:nchannels
    for input = 1:ninputs
        for w = 1:numel(starts)
            idx = starts(w):starts(w)+width-1;
            target = y(ch,idx(2:end))';
            X = [y(ch,idx(1:end-1))',u(input,idx(1:end-1))'];
            valid = all(isfinite(X),2) & isfinite(target);
            Xfit = X(valid,:);
            if nnz(valid)<3 || rcond(Xfit'*Xfit)<=cfg.minimum_rcond, continue; end
            theta = Xfit\target(valid);
            fitted = X(end,:)*theta;
            out.coefficient(ch,w,input) = theta(2);
            out.autoregressive(ch,w,input) = theta(1);
            out.observed(ch,w,input) = target(end);
            out.fitted(ch,w,input) = fitted;
            out.predictor(ch,w,input) = X(end,2);
            out.residual(ch,w,input) = target(end)-fitted;
        end
    end
end
end
