function metrics = bhi_diagnostics(model,cfg)
% Summarize residuals on the configured diagnostic time grid.
stride = cfg.diagnostic_stride;
dt = cfg.step_seconds*stride;
metrics = struct;
names = {'N','NMR','R2','ACF','LjungBoxP','RPC'};
for field = names, metrics.(field{1}) = nan(size(model.residual,1),size(model.residual,3)); end
for ch = 1:size(model.residual,1)
    for input = 1:size(model.residual,3)
        e = model.residual(ch,1:stride:end,input)';
        y = model.observed(ch,1:stride:end,input)';
        x = model.predictor(ch,1:stride:end,input)';
        good = isfinite(e) & isfinite(y) & isfinite(x);
        n = nnz(good);
        lag = min(round(cfg.diagnostic_max_lag_seconds/dt),numel(e)-2);
        if n<8 || lag<1, continue; end
        centered = e-mean(e,'omitnan');
        denominator = sum(centered.^2,'omitnan');
        acf = nan(lag,1);
        for k = 1:lag
            acf(k) = sum(centered(1:end-k).*centered(1+k:end),'omitnan')/denominator;
        end
        Q = n*(n+2)*sum(acf.^2./(n-(1:lag)'));
        metrics.N(ch,input) = n;
        metrics.NMR(ch,input) = mean(e(good))/std(e(good));
        metrics.R2(ch,input) = 1-sum(e(good).^2)/sum((y(good)-mean(y(good))).^2);
        metrics.ACF(ch,input) = acf(1);
        metrics.LjungBoxP(ch,input) = gammainc(Q/2,lag/2,'upper');
        metrics.RPC(ch,input) = corrcoef_value(e(good),x(good));
    end
end
metrics.sampling_interval_seconds = dt;
end

function r = corrcoef_value(a,b)
a = a-mean(a);
b = b-mean(b);
r = sum(a.*b)/sqrt(sum(a.^2)*sum(b.^2));
end
