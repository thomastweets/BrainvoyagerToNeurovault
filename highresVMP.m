subjNames= {'S01', 'S02'};

p = struct();
p.Path = '/DATA/experiment1';
p.pruneMaps = [1,2,4,5,6,7,9,10,11,12,14,15,16,17,19,20,21,22,24,25,26,27,29,30];
p.lags = {'-1', '0', '1', '2', '3', '4'};


for subj = subjNames
    vmp = xff(fullfile(p.Path,subj{1},'dataAnalysis',[subj{1},'.vmp']));

    % iso-voxel the vmp data to a 1 standard resolution
    scale = vmp.Resolution;
    vmp.Resolution = 1;
    fields = {...
        'XStart',...
        'XEnd',...
        'YStart',...
        'YEnd',...
        'ZStart',...
        'ZEnd',...
        'VMRDimX',...
        'VMRDimY',...
        'VMRDimZ'...
    };

    for f = fields
        vmp.(f) = floor(vmp.(f)/scale);
    end

    % prune maps
    vmp.Map(p.pruneMaps) = [];

    % save the file
    vmp.SaveAs(fullfile(p.Path,subj{1},'dataAnalysis',[subj{1},'_1p1mm.vmp']));
end
