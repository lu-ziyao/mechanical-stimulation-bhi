function run_tests
% Check the saved validation signals and shared model functions.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root); setup;
saved = load(fullfile(root,'simulations','simulation_results.mat'),'examples');
cfg = bhi_config(0.20*ones(1,6));
assert(numel(saved.examples)==4);
for j = 1:numel(saved.examples)
    signal = saved.examples(j);
    a = signal.brain_amplitude(:)';
    c = signal.cardiac_modulation(:)';
    t = signal.time_seconds(:);
    h = bhi_arx(a,c,t,cfg);
    b = bhi_ratio(a,c,t,0.20,cfg);
    assert(all(isfinite(h.coefficient(:))) && all(isfinite(b.coefficient(:))));
    assert(max(abs(diff(h.time)-1))<1e-12 && max(abs(diff(b.time)-1))<1e-12);
    assert(h.time(1)==t(20) && b.time(1)==t(40));
    scaled_h = bhi_arx(10*a,7*c,t,cfg);
    scaled_b = bhi_ratio(10*a,c,t,2,cfg);
    assert(max(abs(h.coefficient(:)-scaled_h.coefficient(:)))<1e-10);
    assert(max(abs(b.coefficient(:)-10*scaled_b.coefficient(:)))<1e-10);
    repeat = bhi_arx(a,c,t,cfg);
    assert(isequaln(h,repeat));
    long_cfg = cfg; long_cfg.window_seconds = 15; long_cfg.step_seconds = 3;
    longer = bhi_arx(a,c,t,long_cfg);
    assert(all(abs(diff(longer.time)-3)<1e-12));
    assert(numel(longer.time)<numel(h.time));
    fprintf('PASS: %s (coefficients, timing, scaling, repeatability, windows)\n',signal.condition);
end
rois = bhi_rois;
labels = [rois.electrodes{:}];
assert(numel(labels)==59 && numel(unique(lower(string(labels))))==59);
assert(isequal(cellfun(@numel,rois.electrodes),[6,9,7,7,7,6,7,10]));
values = reshape(1:177,59,3);
reference = bhi_roi_average(values,labels);
order = 59:-1:1;
assert(isequal(reference,bhi_roi_average(values(order,:),labels(order))));
fprintf('PASS: 59-electrode ROI mapping and channel order\n');
fprintf('ALL VALIDATION-DATA CHECKS PASSED\n');
end
