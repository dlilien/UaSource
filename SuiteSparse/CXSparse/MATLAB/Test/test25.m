function test25
%TEST25 test cs_nd
%
% Example:
%   test25
% See also: testall

% Copyright 2006-2012, Timothy A. Davis, http://www.suitesparse.com

clear functions

index = UFget ;
[ignore f] = sort (max (index.nrows, index.ncols)) ;
f = f (1:400) ;

clf
% f = f(1)

for k = 1:length (f)
    
    i = f (k) ;
    Prob = UFget (i) ;
    disp (Prob) ;
    A = real (Prob.A) ;
    [m n] = size (A) ;
    if (m ~= n)
        continue
    end

    A = A|A' ;

    S = A ;
    if (~ispc)
        if (mod (k,2) == 0)
            S = S + 1i * sprand (A) ;
        end
    end

    tic ;
    p1 = symrcm (A) ;
    t1 = toc ;

    tic ;
    p2 = cs_nd (sparse (1)) ;
    toc ;
    if (p2 ~= 1)
        error ('!') ;
    end

    tic ;
    p2 = cs_nd (S) ;
    t2 = toc ;

    if (any (sort (p2) ~= 1:n))
        error ('!') ;
    end

    rel = t2 / max (t1,1e-6) ;

    fprintf ('time: symrcm %8.3f   nd %8.3f  rel %8.2f\n', t1, t2, rel) ;

    subplot (1,3,1) ; spy (A) ;
    subplot (1,3,2) ; spy (A (p1,p1)) ;
    subplot (1,3,3) ; spy (A (p2,p2)) ;

    % evaluate the profile ...


    drawnow 
    % pause
end
