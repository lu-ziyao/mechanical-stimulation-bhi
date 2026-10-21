function values = bhi_roi_average(channel_values,channel_labels)
% Average channel coefficients within each scalp region.
rois = bhi_rois;
labels = lower(string(channel_labels));
values = nan(numel(rois.names),size(channel_values,2));
for r = 1:numel(rois.names)
    [found,indices] = ismember(lower(string(rois.electrodes{r})),labels);
    assert(all(found),'Missing electrodes for ROI %s.',rois.names{r});
    values(r,:) = mean(channel_values(indices,:),1,'omitnan');
end
end
