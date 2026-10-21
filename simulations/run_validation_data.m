function [summary,models] = run_validation_data(output_dir)
% Run the saved known-direction signals through the BHI estimators.
root = fileparts(fileparts(mfilename('fullpath')));
if nargin==0, output_dir = fullfile(root,'outputs'); end
saved = load(fullfile(root,'simulations','simulation_results.mat'),'examples','cfg');
cfg = bhi_config(0.20*ones(1,6));
signals = saved.examples;
models = repmat(struct('condition','','heart_to_brain',[], ...
    'brain_to_heart',[]),1,numel(signals));
rows = cell(numel(signals),4);
for j = 1:numel(signals)
    a = signals(j).brain_amplitude(:)';
    c = signals(j).cardiac_modulation(:)';
    t = signals(j).time_seconds(:);
    models(j).condition = signals(j).condition;
    models(j).heart_to_brain = bhi_arx(a,c,t,cfg);
    models(j).brain_to_heart = bhi_ratio(a,c,t,cfg.minimum_amplitude(1),cfg);
    strength = max(saved.cfg.coupling_strengths)*~strcmp(signals(j).condition,'No coupling');
    rows(j,:) = {signals(j).condition,strength, ...
        median(models(j).brain_to_heart.coefficient(:),'omitnan'), ...
        median(models(j).heart_to_brain.coefficient(:),'omitnan')};
end
summary = cell2table(rows,'VariableNames', ...
    {'Condition','CouplingStrength','BrainToHeart','HeartToBrain'});
if ~isfolder(output_dir), mkdir(output_dir); end
writetable(summary,fullfile(output_dir,'validation_summary.csv'));
save(fullfile(output_dir,'validation_models.mat'),'models','cfg','summary','-v7');
disp(summary);
end
