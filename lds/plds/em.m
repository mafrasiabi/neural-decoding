function params = em( data, eps, k, maxIter, init )
% Expectation-Maximiation for Poisson-LDS model
% David Pfau 2012

addpath ../../util
addpath /Users/davidpfau/Documents/MATLAB/tprod
if nargin == 4
    [params map] = rand_init( k, size(data,1), size(data,2) ); % initial estimate for phase path and parameters
else
    map = init.map;
    params = init.params;
end
[~,~,prec] = log_lik( data, map, params ); % get Hessian of log likelihood with crude parameter estimates

fe = Inf;
fe_ = exp_comp_log_lik( data, map, prec, params ) + entropy( prec );
i = 0;
while i < maxIter && ( i < 10 || fe - fe_ > eps )
    i = i+1;
    fe = fe_;
    [map,cll,prec] = newtons_method(@(x) log_lik( data, x, params ), map, 1e-8 ); % Initialize with path from previous step
    [params,ecll,fe_] = m_step( data, map, prec, params );
    fprintf('Iter: %4i\tFE: %2.4d->%2.4d\tECLL: %2.4d\tLatent LL: %2.4d\n',i,fe,fe_,ecll,cll);
end