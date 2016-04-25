function [ub,vb,ud,vd,l,Kuv,Ruv,RunInfo,ubvbL]=uv(CtrlVar,MUA,BCs,s,b,h,S,B,ub,vb,ud,vd,l,AGlen,C,n,m,alpha,rho,rhow,g,GF)

narginchk(22,22)

tdiagnostic=tic;

if ~isreal(ub) ; save TestSave ; error('uv:ubNotReal','ub not real!') ; end
if ~isreal(vb) ; save TestSave ; error('uv:vbNotReal','vb not real!') ; end
if ~isreal(ud) ; save TestSave ; error('uv:udNotReal','db not real!') ; end
if ~isreal(vb) ; save TestSave ; error('uv:vdNotReal','vb not real!') ; end
if ~isreal(l.ubvb) ; save TestSave ; error('uv:ubvbLambdaNotReal','ubvbLambda not real!') ; end
if ~isreal(l.udvd) ; save TestSave ; error('uv:udvdLambdaNotReal','udvdLambda not real!') ; end


if any(h<0)
    
    indh0=find(h<0);
    fprintf('uv: Found negative ice thicknesses in a diagnostic forward run.\n')
    fprintf('In total %-i negative ice thickness values found, with min ice thickness of %f. \n ',numel(indh0),min(h));
    
    if CtrlVar.ResetThicknessToMinThickness==0
        CtrlVar.ResetThicknessToMinThickness=1; 
    end
    
    
    if CtrlVar.ThickMin<0;
        CtrlVar.ThickMin=0;
    end
    
    fprintf('These thicknes values will be set to %f \n',CtrlVar.ThickMin)
    
    [b,s,h]=Calc_bs_From_hBS(h,S,B,rho,rhow,CtrlVar,MUA.coordinates);
    
end


ubvbL=[];

%% force C and AGlen to be within given max and min limits
[C,iU,iL]=kk_proj(C,CtrlVar.Cmax,CtrlVar.Cmin);
[AGlen,iU,iL]=kk_proj(AGlen,CtrlVar.AGlenmax,CtrlVar.AGlenmin);

if CtrlVar.InfoLevel>=10
    if any(iU)
        fprintf(CtrlVar.fidlog,' SSTREAM2dNR:  on input %-i C values greater than Cmax=%-g \n ',numel(find(iU)),CtrlVar.Cmax) ;
    end
    
    if any(iL)
        fprintf(CtrlVar.fidlog,' SSTREAM2dNR:  on input %-i C values less than Cmin=%-g \n ',numel(find(iL)),CtrlVar.Cmin) ;
    end
    
    if any(iU)
        fprintf(CtrlVar.fidlog,' SSTREAM2dNR:  on input %-i AGlen values greater than AGlenmax=%-g \n ',numel(find(iU)),CtrlVar.AGlenmax) ;
    end
    
    if any(iL)
        fprintf(CtrlVar.fidlog,' SSTREAM2dNR:  on input %-i AGlen values less than AGlenmin=%-g \n ',numel(find(iL)),CtrlVar.AGlenmin) ;
    end
end


switch lower(CtrlVar.FlowApproximation)
    
    
    case 'sstream';
        
        if CtrlVar.InfoLevel >= 1 ; fprintf(CtrlVar.fidlog,' Starting SSTREAM diagnostic step. \n') ;  end
        
        [ub,vb,l.ubvb,Kuv,Ruv,RunInfo,ubvbL]=SSTREAM2dNR(CtrlVar,MUA,BCs,s,S,B,h,ub,vb,l.ubvb,AGlen,C,n,m,alpha,rho,rhow,g);

        
    case 'ssheet'
        
        if CtrlVar.InfoLevel >= 1 ; fprintf(CtrlVar.fidlog,' start SSHEET diagnostic. \n') ;  end
        [b,s,h]=Calc_bs_From_hBS(h,S,B,rho,rhow,CtrlVar,MUA.coordinates);
        
        [ud,vd]=uvSSHEET(CtrlVar,MUA,BCs,AGlen,n,rho,g,s,h);
        l.ubvb=[] ; Kuv=[] ; Ruv=[];
        RunInfo.converged=1; RunInfo.Iterations=NaN;  RunInfo.residual=NaN;
        
    case 'hybrid'
        if CtrlVar.InfoLevel >= 1 ; fprintf(CtrlVar.fidlog,'Start hybrid: 1:SSTREAM-Step \n') ;  end
        [ub,vb,l.ubvb,Kuv,Ruv,RunInfo]=SSTREAM2dNR(CtrlVar,MUA,BCs,s,S,B,h,ub,vb,l.ubvb,AGlen,C,n,m,alpha,rho,rhow,g);
        
        if CtrlVar.InfoLevel >= 1 ; fprintf(CtrlVar.fidlog,' 2:Basal stress, ') ;  end
        [txzb,tyzb]=CalcNodalStrainRatesAndStresses(CtrlVar,MUA,AGlen,n,C,m,GF,s,b,ub,vb);
        if CtrlVar.InfoLevel >= 1 ; fprintf(CtrlVar.fidlog,' 3:SSHEET.') ;  end
        [ud,vd]=uvSSHEETplus(CtrlVar,MUA,BCs,AGlen,n,h,txzb,tyzb);
        if CtrlVar.InfoLevel >= 1 ; fprintf(CtrlVar.fidlog,' Hybrid done \n') ;  end
        
    otherwise
        
        fprintf('CtrlVar.FlowApproximation %s \n',CtrlVar.FlowApproximation)
        error('what case')
        
        
end

tdiagnostic=toc(tdiagnostic);
if CtrlVar.InfoLevel >= 1 ; fprintf(CtrlVar.fidlog,' Ended diagnostic in %-f sec \n ',tdiagnostic) ;
    
end

if ~isreal(ub) ; save TestSave ; error('uv:ubNotReal','ub not real!') ; end
if ~isreal(vb) ; save TestSave ; error('uv:vbNotReal','vb not real!') ; end
if ~isreal(ud) ; save TestSave ; error('uv:udNotReal','ud not real!') ; end
if ~isreal(vd) ; save TestSave ; error('uv:vdNotReal','vd not real!') ; end
if ~isreal(l.ubvb) ; save TestSave ; error('uv:ubvbLambdaNotReal','ubvbLambda not real!') ; end
if ~isreal(l.udvd) ; save TestSave ; error('uv:udvdLambdaNotReal','udvdLambda not real!') ; end
if ~isreal(Kuv) ; save TestSave ; error('uv:kvNotReal','kv not real!') ; end
if ~isreal(Ruv) ; save TestSave ; error('uv:rhNotReal','rh not real!') ; end

end