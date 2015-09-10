function [xPolygon,yPolygon]=LineUpEdges2(CtrlVar,xa,xb,ya,yb,LineMax)


% [xPolygon,yPolygon]=LineUpEdges2(CtrlVar,xa,xb,ya,yb,LineMax)
%
% Lines up edges.
% Takes edges (i.e. line segments) and lines them up to form continous lines, with NaN where there is a gap between edges
%
%
%  xa,  xb, ya, yb     : vectors defining the start and end x,y coordinates of the edges
%                        for example: the n-th edge goes from [xa(n) ya(n)] to [xb(n) yb(n)]
%  LineMax             : maximum number of lined-up edges returned. Edges are returned in the order of the number of points in each edge.
%                        If, for example, LineMax=1, then only the single longest line is returned
%
%
% Note: As a part of the Mapping Toolbox there is a matlab routine `polymerge' that
%       can also be used to do this, but this routine is
%       hoplessly slow and memory hungry for a large number of line segments.
%
%
%
%
%  To plot:   plot(xPolygon,yPolygon)
%
%  To plot in different colours showing individual line segments
% figure ;
% i=0;
% I=find(isnan(xPolygon)) ;
% I=[1;I(:)];
% col=['b','r','c','g','k','m'];
% for ii=1:numel(I)-1
%     i=i+1;
%     plot(xPolygon(I(ii):I(ii+1)),yPolygon(I(ii):I(ii+1)),col(i)) ; axis equal ; hold on ;
%     if i==numel(col) ; i=0 ; end
% end

%aCase=0; bCase=0;


%Tolerance=100*eps;

if isempty(CtrlVar)
    CtrlVar.InfoLevel=0;
    CtrlVar.LineUpTolerance=100*eps ;
    
end

if ~isfield(CtrlVar,'InfoLevel') ; CtrlVar.InfoLevel=0 ; end
if ~isfield(CtrlVar,'LineUpTolerance') ; CtrlVar.LineUpTolerance=100*eps ; end

% Tolerance controls how close endpoints of edges must be for them to be considered to be a part of the 
% same polygon.
% Tolerance2 is a numerical tolerance used to determine if a x,y coordinate is identical to another
% x,y coordinate.

Tolerance=CtrlVar.LineUpTolerance;
Tolerance2=100*eps;

if nargin<6
    LineMax=inf;
end

Theta=atan2(ya-mean(ya),xa-mean(xa));
[~,I]=sort(Theta);
xa=xa(I) ; ya=ya(I) ; xb=xb(I) ; yb=yb(I);

N=length(xa);
xPolygon=zeros(3*N,1)+inf ; yPolygon=zeros(3*N,1)+inf; % upper estimate, all edges are seperate lines segments

i=1;
l=i; % l is the starting point of the current segment
xPolygon(i)=xa(1) ;  yPolygon(i)=ya(1) ;  i=i+1 ;
xPolygon(i)=xb(1) ;  yPolygon(i)=yb(1)  ; i=i+1 ;
xa(1)=NaN ; ya(1)=NaN ; xb(1)=NaN ; yb(1)=NaN ;


k=i-1;  % k is index of the current end of the merged line
flipped=0;

while ~all(isnan(xa))
    
    
    
    
    % find input GL location closest to last included output GL pos
    % the current endpoint of the polygone is
    % (xPolygon(k),yPolygon(k))
    sa=(xPolygon(k)-xa).^2+(yPolygon(k)-ya).^2;  % distance to all the `a' end points of remaining edges to the current end point of the merged line
    sb=(xPolygon(k)-xb).^2+(yPolygon(k)-yb).^2;  % distance to all the `b' end points of remaining edges to the current end point of the merged line
    [dista,ia]=min(sa);   % this ignores all NaN (of which there could be many)
    [distb,ib]=min(sb);
    
    %[xPolygon(:) yPolygon(:)]
    % if the distance is zero, then I am on the same GL
    % otherwise start a new GL
    
    %
    % Algorithm:
    % -Take edge points as defined by [xa ya ; xb yb] and add to Polygon
    % Find endpoints of edges closest to last added point in Polygon. If distance to either end points of 
    % some edges is within a given tolerance, add those to Polygon and delete the edge.
    % If no such point is found, consider the possibility that there are some such edges close to the
    % other end of current Polygon and therefore flip the polygon once.
    % If no such edges are found, start a new polygon, and define the new starting point.
    %
    if dista< Tolerance || distb<Tolerance
        
        if dista<= distb
            %fprintf('dista %f \n',dista)
            if dista>Tolerance2
                xPolygon(i)=xa(ia) ;  yPolygon(i)=ya(ia) ;  i=i+1;
            end
            xPolygon(i)=xb(ia) ;  yPolygon(i)=yb(ia) ;  i=i+1;
            k=i-1;
            xa(ia)=NaN ; ya(ia)=NaN ; xb(ia)=NaN ; yb(ia)=NaN ; % get rid of this edge as it now is a part of the merged line
            
            while ia<=(numel(xa)-1)
                %aCase=aCase+1;
                Test=abs(xa(ia+1)-xPolygon(k))+abs(ya(ia+1)-yPolygon(k));
                if Test<Tolerance2
                    ia=ia+1;
                    xPolygon(i)=xb(ia) ;  yPolygon(i)=yb(ia) ;  i=i+1;
                    k=i-1;
                    xa(ia)=NaN ; ya(ia)=NaN ; xb(ia)=NaN ; yb(ia)=NaN ;
                else
                    break
                end
            end
        else
            %fprintf('distb==0\n')
            %xPolygon(i)=xb(ib) ;  yPolygon(i)=yb(ib) ;  i=i+1;
            
            if dista>Tolerance2
                xPolygon(i)=xb(ib) ;  yPolygon(i)=yb(ib) ;  i=i+1;
            end
            
            xPolygon(i)=xa(ib) ;  yPolygon(i)=ya(ib) ;  i=i+1;
            k=i-1;
            xa(ib)=NaN ; ya(ib)=NaN ; xb(ib)=NaN ; yb(ib)=NaN ;
            
            while ia<=(numel(xa)-1)
                %bCase=bCase+1;
                Test=abs(xa(ib+1)-xPolygon(k))+abs(ya(ib+1)-yPolygon(k));
                if Test<Tolerance2
                    ib=ib+1;
                    xPolygon(i)=xa(ib) ;  yPolygon(i)=ya(ib) ;  i=i+1;
                    k=i-1;
                    xa(ib)=NaN ; ya(ib)=NaN ; xb(ib)=NaN ; yb(ib)=NaN ;
                else
                    break
                end
            end
        end
        
    elseif ~flipped   % flipp once
        
        flipped=1;
        % Now flip the line segment and transverse in the oposite direction
        xPolygon(l:k)=flipud(xPolygon(l:k));
        yPolygon(l:k)=flipud(yPolygon(l:k));
        
        
        
    else  % dist larger than tolerance, must start a new line-segment.
          % Put NaN to mark the division between line segments, and find a starting point
          % for the next line segment.
        
        
        flipped=0;
        xPolygon(i)=NaN ;  yPolygon(i)=NaN ;  i=i+1; % NaN put between GLs
        
        l=i ; % l is the starting point of the current segment
        if dista<distb
            %fprintf('dista smaller\n')
            
            xPolygon(i)=xa(ia) ;  yPolygon(i)=ya(ia) ;  i=i+1;
            xPolygon(i)=xb(ia) ;  yPolygon(i)=yb(ia) ;  i=i+1;
            k=i-1;
            xa(ia)=NaN ; ya(ia)=NaN ; xb(ia)=NaN ; yb(ia)=NaN ;
        else
            %fprintf('distb smaller\n')
            
            xPolygon(i)=xb(ib) ;  yPolygon(i)=yb(ib) ;  i=i+1;
            xPolygon(i)=xa(ib) ;  yPolygon(i)=ya(ib) ;  i=i+1;
            k=i-1;
            xa(ib)=NaN ; ya(ib)=NaN ; xb(ib)=NaN ; yb(ib)=NaN ;
        end
    end
    
%     figure(10) ; hold on  ; plot(xPolygon,yPolygon,'o-')
%     prompt = 'Do you want more? Y/N [Y]: ';
%     [xa(:) ya(:) xb(:) yb(:)]
%     str = input(prompt,'s');
%     if isempty(str)
%         str = 'Y';
%     end

end

I=isinf(xPolygon);
xPolygon(I)=[] ; yPolygon(I)=[];

%% rearange GLs in order of total number of points withing each GL


xPolygon=[xPolygon;NaN] ; yPolygon=[yPolygon;NaN];
temp=sort(find(isnan(xPolygon))) ; temp=[0;temp;numel(xPolygon)];
[~,I]=sort(diff(temp),'descend');

NGL=min([numel(I),LineMax]);

if CtrlVar.InfoLevel>=10;
    fprintf('LineUpEdges: Found %-i grounding lines. Returning %-i.  \n',numel(I),NGL)
end
xx=[] ; yy=[];
for l=1:NGL
    
    n1=temp(I(l))+1 ; n2=temp(I(l)+1) ;
    xx=[xx;xPolygon(n1:n2)] ; yy=[yy;yPolygon(n1:n2)];
    
    
end

xx(end)=[] ;yy(end)=[];

xPolygon=xx; yPolygon=yy;


%[aCase bCase]



end
