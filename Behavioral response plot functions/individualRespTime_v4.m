function [] = individualRespTime_v4(rawFile, rawData, plotType)
% INDIVIDUALRESPTIME_V1 generates a smoothed time series of the raw
% response times using a the robust version (less weight applied to outliers)
% local regression with weighted linear least squares and a 2nd degree
% polynomial model ('rloess') in addition to the best fit line for
% the response times for each block.
%
%
% The function will require the input_matrix used to generate the session
% in addition to the output struct.
%
% INPUTS:
% 'fName' - string/character of the file name used for the output .mat file
% generated by the paradigm code. Example: 'JD_Oct20.mat'
%
% Example usage: individualRespTime_v2('rData_PT1.mat','rData_PT1')
% Example usage: individualRespTime_v2('rData_PT2.mat','rData_PT2')
% Example usage: individualRespTime_v2('AT_Oct20.mat','AT_Oct20')

if nargin < 3
    plotType = 0;
end

load(rawFile, rawData)

if ~iscell(eval(rawData))
    tmpRD = eval(rawData);
    tmpActual = {tmpRD.actual};
    tmpResp = {tmpRD.Response};
    rData = struct2table(tmpRD);
    rData.actual = transpose(tmpActual);
    rData.Response = transpose(tmpResp);
else
    rData = struct2table(eval(rawData));
end


varNames = rData.Properties.VariableNames;
for ci = 1:width(rData)
    
    if ~iscell(rData.(varNames{ci}))
        rData.(varNames{ci}) = num2cell(rData.(varNames{ci}));
    end
    
end



% check for missing values
if iscell(rData.rtime)
    isEm = cellfun(@(x) ~isempty(x), rData.rtime);
    func = @iscell;
    bOUT = varfun(func, rData);
    bBIN = table2array(bOUT);
    rows = find(~isEm);
    cols = find(bBIN);
    
    for i = 1:sum(~isEm)
        for j = 1:sum(bBIN)
            rData{rows(i),cols(j)} = {nan};
        end
    end
    
    fillO = ceil(length(isEm)/9)*9;
    
    rData{length(isEm)+1:fillO,:} = {nan};
    
else
    rData.rtime = num2cell(rData.rtime);
end

blockNUM = height(rData)/9;

rTime = [rData.rtime];

rTimeMat = cell2mat(reshape(rTime,blockNUM,9));

xAxS = 1:9;
plotCell = cell(blockNUM,1);
mTpoints = zeros(1,blockNUM);
SGData = [];
IGData = [];
for ri = 1:blockNUM
    y = rTimeMat(ri,:);
    hold on
    if mod(ri,2) ~= 0
        
        switch plotType
            case 0
                yy2 = smooth(xAxS,y,0.75,'rloess');
                plotCell{ri} = plot(xAxS , yy2 , 'k-');
                mTpoints(ri) = median(xAxS);
                xAxS = xAxS + 10;
            case 1
                yy2 = smooth(xAxS,y,0.75,'rloess');
                plotCell{ri} = plot(xAxS , yy2 , 'k-');
            case 2
                yy2 = smooth(xAxS,y,0.75,'rloess');
                SGData = [SGData ; transpose(yy2)];
                
        end
    else
        switch plotType
            case 0
                yy2 = smooth(xAxS,y,0.75,'rloess');
                plotCell{ri} = plot(xAxS , yy2 , 'r-');
                mTpoints(ri) = median(xAxS);
                xAxS = xAxS + 10;
            case 1
                yy2 = smooth(xAxS + 10,y,0.75,'rloess');
                plotCell{ri} = plot(xAxS + 10 , yy2 , 'r-');
            case 2
                yy2 = smooth(xAxS,y,0.75,'rloess');
                IGData = [SGData ; transpose(yy2)];
                
                
                
        end
    end
    
end

if plotType == 2
    sgM = nanmean(SGData);
    sgS = nanstd(SGData);
    igM = nanmean(IGData);
    igS = nanstd(IGData);
    
    xAxSg = [xAxS , fliplr(xAxS)];
    yAxSg = [sgM - sgS , fliplr(sgM + sgS)];
    patch(xAxSg, yAxSg, 'k', 'EdgeColor', 'none', 'FaceAlpha', 0.5)
    line(xAxS,sgM,'Color','k','LineWidth',3)
    
    hold on
    
    xAxSg = [xAxS + 10 , fliplr(xAxS + 10)];
    yAxSg = [igM - igS , fliplr(igM + igS)];
    patch(xAxSg, yAxSg, 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.5)
    line(xAxS + 10,igM,'Color','r','LineWidth',3)

end


yVals = get(gca,'YTick');
yticks([min(yVals) max(yVals)/2 max(yVals)]);
ylabel('Reaction time (seconds)')

switch plotType
    case 0
        xticks(mTpoints);
        xticklabels(cellfun(@(x) ['B' , num2str(x)] , num2cell(1:16),'UniformOutput',false))
        legend([plotCell{1} , plotCell{2}],'SG','IG');
        xlabel('Block #')
        set(gcf,'Position',[519 316 932 420])
    case 1
        xticks([5 15]);
        xticklabels({'SG','IG'})
        axis square
    case 2
        xticks([5 15]);
        xticklabels({'SG','IG'})
        axis square
end

title('Summary of Reaction Times Across Full Session')


end

