function [wint,M,xint,yint] = VertVelMatrix(h,B,u,v,coordinates,connectivity,nip)
    %
    % Calculates vertical velocities at integration points by setting up M where w=M [u;v]
    % (needs to be vectorized)
    %  M has size Nele*nip x Nodes
    %
    % w=-h (\p_x u + \p_u v)+ \p_x B u + \p_y B u
    
    Nnodes=max(connectivity(:)); [Nele,nod]=size(connectivity); ndim=2;
    nzmax=2*nod*nip*Nele;
    
    Iind=zeros(nzmax,1); Jind=zeros(nzmax,1) ; Xval=zeros(nzmax,1);
    xint=zeros(Nele*nip,1); yint=xint;
    
    
    funInt=cell(1,3); derInt=cell(1,3);
    
    [points]=sample('triangle',nip,ndim);
    for Iint=1:nip
        funInt{Iint}=shape_fun(Iint,ndim,nod,points) ; % nod x 1   : [N1 ; N2 ; N3] values of form functions at integration points
        derInt{Iint}=shape_der(Iint,ndim,nod,points);  % dof x nod : dNj/dXi=[dN1/dx dN2/dx dN3/dx; dN1/dy dN2/dy dN3/dy]
    end
    
    istak=1;
    
     for Iele=1:Nele
            
            con=connectivity(Iele,:);  % nodes of element
            coo=coordinates(con,:) ; % nod x dof =[x1 y1 ; x2 y2 ; x3 y3]
            h_l=h(con) ; B_l=B(con);
            gx_l=con; gy_l=Nnodes+con;
            
           
            
            for Iint=1:nip                           % loop over integration points
              
                            
                fun=funInt{Iint}; % nod x 1 
                der=derInt{Iint}; %dof x nod
                
                J=der*coo; % (dof x nod) x (nod x dof) = dof x dof
               % detJ=det(J);  % det(dof x dof) matrix
                deriv=J\der; % (dof x dof) x (dof x nod) = dof x nod
                
                hI=h_l'*fun ; % scalar
                
                dBdx=deriv(1,:)*B_l; % scalar 
                dBdy=deriv(2,:)*B_l; % scalar
                mx=-hI*deriv(1,:)+ dBdx*fun' ;  %; % 1 x nod
                my=-hI*deriv(2,:)+ dBdy*fun' ;  %; % 1 x nod
                %mx=dBdx*fun' ;  %; % 1 x nod
                %my= dBdy*fun' ;  %; % 1 x nod
                
    % integration points # is Iint+(Iele-1)*nip 
   
                Iind(istak:istak+2*nod-1)=Iint+(Iele-1)*nip; 
                Jind(istak:istak+2*nod-1)=[gx_l';gy_l'];
                Xval(istak:istak+2*nod-1)=[mx';my'];
                istak=istak+2*nod;  %
    
                xint(Iint+(Iele-1)*nip)=coo(:,1)'*fun ; 
                yint(Iint+(Iele-1)*nip)=coo(:,2)'*fun ;
            end
            % I got nip pairs of 1 x nod vectors
            % nip x 2*nod
     end
    
     
     M=sparse(Iind,Jind,Xval,Nele*nip,2*Nnodes,nzmax);
     
     wint=M*[u;v];
     

end

