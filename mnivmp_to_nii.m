subjNames= {'S01', 'S02'};

mniRes = [91*2, 109*2, 91*2];

p = struct();
p.Path = '/DATA/experiment1';
p.lags = {'-1', '0', '1', '2', '3', '4'};
p.resultFolder = 'results';

for s = 1:numel(subjNames)
    vmp = xff(fullfile(p.Path,subjNames{1,s},'dataAnalysis',[subjNames{1,s},'_1mm_MNI.vmp']));

    for l = 1:numel(p.lags)
        % delete all but one maps
        vmpTemp = vmp.CopyObject();
        prune = [1:numel(p.lags)];
        prune(l) = [];
        vmpTemp.Map(prune) = [];

        % reframe the VMP to the full framing cube (of the VMR)
        sizeVMR = [vmpTemp.VMRDimX, vmpTemp.VMRDimY, vmpTemp.VMRDimZ];
        data = single(zeros(sizeVMR));
        data(vmpTemp.XStart:vmpTemp.XEnd-1,vmpTemp.YStart:vmpTemp.YEnd-1,vmpTemp.ZStart:vmpTemp.ZEnd-1) = vmpTemp.Map(1).VMPData;
        vmpTemp.Map(1).VMPData = dataNew;

        % reset offsets
        vmpTemp.XStart = 0;
        vmpTemp.YStart = 0;
        vmpTemp.ZStart = 0;
        vmpTemp.XEnd = vmpTemp.VMRDimX;
        vmpTemp.YEnd = vmpTemp.VMRDimY;
        vmpTemp.ZEnd = vmpTemp.VMRDimZ;

        % export nifti
        vmpTemp.ExportNifti(fullfile(p.Path,p.resultFolder, [subjNames{1,s}, '_lag_', p.lags{1,l}, '.nii']));

        % re-open nifti to change some header fields
        nii = xff(fullfile(p.Path,p.resultFolder, [subjNames{1,s}, '_lag_', p.lags{1,l}, '.nii']));
        nii.DataHist.NIftI1.QFormCode = 4;
        nii.DataHist.NIftI1.SFormCode = 4;
        nii.ImgDim.CalMinDisplay = 0;
        nii.ImgDim.CalMaxDisplay = 0.05;
        nii.SaveAs(fullfile(p.Path,p.resultFolder, [subjNames{1,s}, '_lag_', p.lags{1,l}, '.nii']));

        % rotate to standard FSL orientation
        unix(['/usr/local/fsl/bin/fslreorient2std ',...
            fullfile(p.Path,p.resultFolder,[subjNames{1,s}, '_lag_', p.lags{1,l}, '.nii']),...
            ' ',...
            fullfile(p.Path,p.resultFolder,[subjNames{1,s}, '_lag_', p.lags{1,l}, '.nii.gz'])]);

        % remove the non-gzipped file
        unix(['rm ',...
            fullfile(p.Path,p.resultFolder,[subjNames{1,s}, '_lag_', p.lags{1,l}, '.nii']),...
            ' ',...
            fullfile(p.Path,p.resultFolder, [subjNames{1,s}, '_lag_', p.lags{1,l}, '.rtv'])]);
    end
end
