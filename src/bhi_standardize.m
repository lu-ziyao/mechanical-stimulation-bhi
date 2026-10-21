function z = bhi_standardize(x)
% Standardize each row across its finite samples.
x(~isfinite(x)) = NaN;
scale = std(x,0,2,'omitnan');
scale(scale == 0) = NaN;
z = (x - mean(x,2,'omitnan')) ./ scale;
end
