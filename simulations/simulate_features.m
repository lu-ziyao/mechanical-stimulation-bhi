function [amplitude,cardiac,time] = simulate_features(condition,strength,noise,seed,cfg)
% Generate lagged interactions between two feature signals.
rng(seed,'twister');
switch condition
    case 'No coupling', coupling = [0,0];
    case 'Brain-to-heart', coupling = [strength,0];
    case 'Heart-to-brain', coupling = [0,strength];
    case 'Bidirectional', coupling = [strength,strength];
end
nkeep = round(cfg.duration_seconds*cfg.feature_rate);
burn = round(cfg.burn_in_seconds*cfg.feature_rate);
n = nkeep+burn;
t = (0:n-1)/cfg.feature_rate;
brain_drive = 0.70*sin(2*pi*0.07*t)+0.35*sin(2*pi*0.17*t+0.45) + ...
    pulses(t,[13,31,52,67],0.8,[0.9,-0.7,1.0,-0.8]);
heart_drive = 0.65*sin(2*pi*0.05*t+1.10)+0.30*sin(2*pi*0.13*t+2) + ...
    pulses(t,[20,39,58],1.0,[0.8,-1.0,0.7]);
brain_drive = bhi_standardize(brain_drive);
heart_drive = bhi_standardize(heart_drive);
state = zeros(1,n);
amplitude = cfg.amplitude_offset*ones(1,n);
cardiac = zeros(1,n);
for j = 2:n
    state(j) = 0.5*state(j-1)+0.3*brain_drive(j) + ...
        coupling(2)*cardiac(j-1)+noise*randn;
    amplitude(j) = max(cfg.amplitude_offset+cfg.amplitude_scale*state(j),0.20);
    cardiac(j) = coupling(1)*amplitude(j-1)+0.3*heart_drive(j)+noise*randn;
end
amplitude = amplitude(burn+1:end);
cardiac = cardiac(burn+1:end);
time = (0:nkeep-1)'/cfg.feature_rate;
end

function y = pulses(t,centers,width,heights)
y = zeros(size(t));
for j = 1:numel(centers)
    y = y+heights(j)*exp(-0.5*((t-centers(j))/width).^2);
end
end
