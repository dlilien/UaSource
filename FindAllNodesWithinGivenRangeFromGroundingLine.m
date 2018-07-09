function [ID,idx,D,KdTree]=FindAllNodesWithinGivenRangeFromGroundingLine(CtrlVar,MUA,xGL,yGL,ds,KdTree)

%%
% Finds all nodes within a given range from the grounding line.
%
% A very simple wrapper around the use of the rangesearch routine from the
% `Statistics and Machine Learnig Toolbox'
%
%
%    [ID,idx,KdTree]=FindAllNodesWithinGivenRangeFromGroundingLine(CtrlVar,MUA,xGL,yGL,ds,KdTree)
%
%  Inputs:
%  ds     :   distance
%  KdTree :   a Kd-tree of nodal point locations
%             (output from KDTreeSearcher([MUA.coordinates(:,1) MUA.coordinates(:,2)])
%
% Outputs:
%
%  ID          : List of ALL nodes within the distance ds from ANY of the points
%                (xGL,yGL) defining the grouning line
%  idx and D   : outputs from rangsearch see `doc rangsearch'
%  KdTree      : Kd-tree as generated by `KDTreeSearcher'
%
%
%
% *Examples:*
%
% Find all nodes within a distance of 1000 from the grounding line and plot those nodes.
%
%   load('MUA-PIG-TWG-Example.mat','MUA','BCs','CtrlVar','GF') 
%   ds=1000;
%   ID=FindAllNodesWithinGivenRangeFromGroundingLine([],MUA,xGL,yGL,ds) ;   
%   x=MUA.coordinates(:,1); y=MUA.coordinates(:,2);
%   figure ; plot(x(ID)/CtrlVar.PlotXYscale,y(ID)/CtrlVar.PlotXYscale,'*r')
%
%
% Find all nodes within a distance of 5000 from the grounding line.
% Plot the grounding lines anda those nodes over the FE mesh.
%
%   load('MUA-PIG-TWG-Example.mat','MUA','BCs','CtrlVar','GF') 
%   figure
%   CtrlVar.PlotNodes=0; CtrlVar.WhenPlottingMesh_PlotMeshBoundaryCoordinatesToo=0;
%   PlotMuaMesh(CtrlVar,MUA)
%   hold on 
%   [xGL,yGL,GLgeo]=PlotGroundingLines(CtrlVar,MUA,GF,[],[],[],'LineWidth',2);
%   ds=5000;
%   ID=FindAllNodesWithinGivenRangeFromGroundingLine([],MUA,xGL,yGL,ds) ;
%   hold on
%   x=MUA.coordinates(:,1); y=MUA.coordinates(:,2);
%   plot(x(ID)/CtrlVar.PlotXYscale,y(ID)/CtrlVar.PlotXYscale,'*r')
%%


if isempty(xGL)
    ID=[] ;
    idx=[] ;
    D=[] ;
    KdTree=[];
    return
end

if exist('KDTreeSearcher','file') == 3

    fprintf('KDTreeSearcher not found. Requires the Statistics and Machine Learning Toolbox.\')
    ID=[];
    idx=[];
    D=[];
    KdTree=[];
    return
    
end
    
    
cooA=[MUA.coordinates(:,1) MUA.coordinates(:,2)];
cooB=[xGL yGL];

if nargin<6 || isempty(KdTree)
    KdTree=KDTreeSearcher(cooA) ;
end

if ~isempty(cooB)
    
    [idx,D]=rangesearch(KdTree,cooB,ds,'Distance','euclidean');
    
end


ID=zeros(sum(cellfun(@length,idx)),1)+NaN; k=1;
for I=1:numel(idx)
    n=numel(idx{I});
    if n>0
        ID(k:k+n-1)=idx{I};
        k=k+n;
    end
end

end