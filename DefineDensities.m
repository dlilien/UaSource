function [rho,rhow,g]=DefineDensities(Experiment,CtrlVar,MUA,time,s,b,h,S,B)

%%
%  Define ice and ocean densities, as well as the gravitational acceleration.
%
% [rho,rhow,g]=DefineDensities(Experiment,CtrlVar,MUA,time,s,b,h,S,B)
%
%  rhow    :  ocean density (scalar variable)
%  rho     :  ice density (nodal variable)
%  g       :  gravitational acceleration
% 
%%  
    warning('Ua:DefaultDefine','Using default DefineDensities \n')
        
    rho=900+zeros(MUA.Nnodes,1) ; 
    rhow=1030; 
    g=9.81/1000;
    
    
end
