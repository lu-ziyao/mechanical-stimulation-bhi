function results = run_simulation(cfg,output_dir)
% Run directional validation and independent null calibration.
if nargin==0, cfg = simulation_config; end
root = fileparts(fileparts(mfilename('fullpath')));
calibration = nan(cfg.calibration_repetitions,2,numel(cfg.noise_levels));
for s = 1:numel(cfg.noise_levels)
    for r = 1:cfg.calibration_repetitions
        seed = cfg.random_seed+9000000+s*10000+r;
        [a,c,t] = simulate_features('No coupling',0,cfg.noise_levels(s),seed,cfg);
        calibration(r,:,s) = simulation_indices(a,c,t,cfg);
    end
end
ngroups = 1+3*numel(cfg.coupling_strengths);
rows = cell(ngroups*numel(cfg.noise_levels)*cfg.repetitions,11);
row = 0;
for condition = 1:numel(cfg.conditions)
    strengths = cfg.coupling_strengths;
    if condition==1, strengths = 0; end
    for strength = strengths
        for s = 1:numel(cfg.noise_levels)
            for r = 1:cfg.repetitions
                seed = cfg.random_seed+condition*100000+round(strength*1000)*100+s*10000+r;
                [a,c,t] = simulate_features(cfg.conditions{condition},strength,cfg.noise_levels(s),seed,cfg);
                observed = simulation_indices(a,c,t,cfg);
                surrogate = nan(cfg.surrogates,2);
                limits = [round(0.2*numel(a)),round(0.8*numel(a))];
                for j = 1:cfg.surrogates
                    shift = randi(limits);
                    b = bhi_ratio(circshift(a,shift),c,t,cfg.minimum_amplitude(1),cfg);
                    h = bhi_arx(a,circshift(c,shift),t,cfg);
                    surrogate(j,:) = [median(b.coefficient(:),'omitnan'), ...
                        median(h.coefficient(:),'omitnan')];
                end
                p_null = empirical_p(observed,calibration(:,:,s));
                p_shift = empirical_p(observed,surrogate);
                row = row+1;
                rows(row,:) = {cfg.conditions{condition},strength,cfg.noise_levels(s),r,seed, ...
                    observed(1),observed(2),p_null(1),p_null(2),p_shift(1),p_shift(2)};
            end
        end
    end
    fprintf('Completed %s\n',cfg.conditions{condition});
end
results = cell2table(rows,'VariableNames',{'Condition','CouplingStrength','NoiseSD', ...
    'Repetition','Seed','BrainToHeart','HeartToBrain','NullPBrainToHeart', ...
    'NullPHeartToBrain','ShiftPBrainToHeart','ShiftPHeartToBrain'});
if nargin<2, output_dir = fullfile(root,'outputs'); end
out = output_dir;
if ~isfolder(out), mkdir(out); end
writetable(results,fullfile(out,'simulation_results.csv'));
save(fullfile(out,'simulation_results.mat'),'results','calibration','cfg','-v7');
end

function p = empirical_p(observed,reference)
valid = isfinite(reference);
p = (1+sum(abs(reference)>=abs(observed),1))./(1+sum(valid,1));
p(~isfinite(observed) | sum(valid,1)==0) = NaN;
end
