function [p,plb,pub]=F2p(CtrlVar,F)

% p is the vector of the control variables, currenty p=[A,b,C]
% with A, b or C here only being nonempty when inverted for,
% This mapping between A, b and C into the control variable is done by
% InveValues2o

pA=[];
lbA=[];
ubA=[];

pC=[];
lbC=[];
ubC=[];

pb=[];
lbb=[];
ubb=[];

if contains(lower(CtrlVar.Inverse.InvertFor),'-logaglen-')
    
    pA=log10(F.AGlen);
    
    lbA=log10(F.AGlenmin)+zeros(size(pA));
    ubA=log10(F.AGlenmax)+zeros(size(pA));
    
    
elseif contains(lower(CtrlVar.Inverse.InvertFor),'-aglen-')
    
    pA=F.AGlen;
    lbA=F.AGlenmin+zeros(size(pA));
    ubA=F.AGlenmax+zeros(size(pA));
    
end


if contains(lower(CtrlVar.Inverse.InvertFor),'-logc-')
    
    pC=log10(F.C);
    lbC=log10(F.Cmin)+zeros(size(pC));
    ubC=log10(F.Cmax)+zeros(size(pC));
    
elseif contains(lower(CtrlVar.Inverse.InvertFor),'-c-')
    
    pC=F.C;
    lbC=F.Cmin+zeros(size(pC));
    ubC=F.Cmax+zeros(size(pC));
    
end

if contains(lower(CtrlVar.Inverse.InvertFor),'-b-')
    
    pb=F.b;
    lbb=F.bmin+zeros(size(pb));
    ubb=F.bmax+zeros(size(pb));
    
end


p=[pA;pb;pC];
plb=[lbA;lbb;lbC];
pub=[ubA;ubb;ubC];


end
