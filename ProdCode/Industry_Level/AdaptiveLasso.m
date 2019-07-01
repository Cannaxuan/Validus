function [beta,runinfo, w] = AdaptiveLasso(y,X,par)
%%
%% This function is to estimate the Sparse Linear Regression via Adpative Lasso.
%% Cross validation is used to choose a suitlable penalty parameter.
%%
%% Sparse Linear Regression with Adpative Lasso;
%  Step 1: Find a suitable initial estimator
%          Option 1): OLS estimator
%          Option 2): Lasso estimator
%  Step 2: Run weighted Lasso (with weight constructed from the initial estimator)
%%
%% Linear Regression
%  y_i = x_i*beta + u_i, u_i ~ N(0,sigma^2)
%  where beta is a sparse vector.
%% Required Inputs:
%   y  = observed response variable (mx1)
%   X  = observed explantory variables (mxn)
%% Optional Inputs:
%   initial    = option to choose the initial estimator
%                'ols' = use the ols estimator
%                'lasso' = use the lasso estimator
%                (Default: If m >= 2n, initial = 'ols'; else, initial = 'lasso')
%   nfold      = numbers of folds in cross validation (Default = 10)
%   nlambda    = numbers of candidate penalty parameters in cross validation (Default = 100)
%   cvRule     = option to choose cross validation rule (Default = 'lambda_min');
%                'lambda_min' = use minimue error rule
%                'lambda_1se' = use one-standard error rule 
%   alpha      = option to choose elastic-net mixing parameter in [0,1] (Default = 1)
%                '1' = use lasso penalty
%                '0' = use ridge penaly
%   randseed   = random seed (Default = 0)   
%   tol        = tolerance of final estimates (Default = 1e-6)
%   isParallel = k-fold cross validation in parallel or not (Default = 0)
%   isPrint    = work silently (=0) or not (=1) (Default = 0);
%% Output:
%   beta = final solution
%   runinfo = running information of final solution
%%
%% Written by Miao Weimin, May 1, 2016
%% Revised by Miao Weimin, June 2, 2016
% Fix the issue of standarization of regressors
% Add R-squares
%% Revised by Miao Weimin, June 3, 2016 
% Add the cvRule option from mse minimum rule to one-standard-error rule
% Add the elastic-net option
% Add the random seed control
%% Revised by Miao Weimin, June 6, 2016
% Change the identification of zero coefficient after Step 1
% Change the default tolerance from 1e-4 to 1e-6
%% Revised by Miao Weimin, July 14, 2016
% Remove the variable exclusion tolerance 
%% Revised by Miao Weimin, July 20, 2016
% Change the default setting of cvRule to minimun error rule
%% Revised by Miao Weimin, Oct 3, 2016
% Add the BIC rule to select the "best" penalty parameter
%%

warning('off','all');
%% Initialization
currentfolder = fileparts(mfilename('fullpath'));
addpath([currentfolder '\glmnet']);

nfold = 10;
nlambda = 100;
cvRule = 'lambda_min';
alpha = 1;
tol = 1e-6;
randseed = 0;
isParallel = 0;
isPrint = 0;

[m,n] = size(X);
if (m >= 2*n)
    initial = 'ols'; % use the ordinary least squares solution as the initial estimator
else
    initial = 'lasso'; % use the lasso solution via cross validation as the initial estimator
end

if (nargin == 3)
    if isfield(par,'initial'); initial = par.initial; end
    if isfield(par,'nfold'); nfold = par.nfold; end
    if isfield(par,'nlambda'); nlambda = par.nlambda; end
    if isfield(par,'cvRule'); cvRule = par.cvRule; end
    if isfield(par,'alpha'); alpha = par.alpha; end
    if isfield(par,'tol'); tol = par.tol; end
    if isfield(par,'randseed'); randseed = par.randseed; end
    if isfield(par,'isParallel'); isParallel = par.isParallel; end
    if isfield(par,'isPrint'); isPrint = par.isPrint; end
end

if (~strcmp(cvRule,'lambda_min')) && (~strcmp(cvRule,'lambda_1se'))
    error('Please insert a correct cvRule!'); 
end

% Standardize X
% (By default, the function 'glmnet' in 'cvglmnet' standarize both y and X.
% However, the weight in 'glmnet' is applied to the coefficient associated
% with X after standardization. Thus, to properly derive the weight in
% Adaptive Lasso, we have to standaridize X in advance.)
meanX = mean(X);
stdX = std(X);
X = bsxfun(@rdivide, bsxfun(@minus, X, meanX), stdX); 
% X_ols = bsxfun(@rdivide, bsxfun(@minus, X, meanX), stdX); 
t0 = clock;
%%
%% Compute the initial estimator
%%
if (isPrint)
    fprintf('\n # Step 1: Initial Estimator (%s) ...', initial);
end
if strcmp(initial,'ols')
    beta = regress(y,[ones(m,1) X]);
%     beta = regress(y,[ones(m,1) X_ols]);
elseif strcmp(initial,'lasso')
    options.nlambda = nlambda;
    options.thresh = tol;
    options.alpha = alpha;
    
    
    rng(randseed);
    CVerr = cvglmnet(X,y,[],options,[],nfold,[],isParallel);
    beta = cvglmnetCoef(CVerr,cvRule);
    
    runinfo.Step1.cvinfo = CVerr;
else
    error('Please choose the correct initial estimator, either "ols" or "lasso"!');
end
 
runinfo.Step1.beta = [beta(1) - (meanX./stdX)*beta(2:end); beta(2:end)./(stdX)']; % adjuste coeffcient back
runinfo.Step1.method = initial;
runinfo.Step1.rsqr = 1 - norm(y -beta(1)- X*beta(2:end))^2 / norm(y-mean(y))^2; % Rsquare
%%
%% Compute the adaptive lasso estimator
%%
if (isPrint)
    fprintf('\n # Step 2: Weighted Lasso ...');
end
abscoef = abs(beta(2:end));
w = 1./abscoef;
idx_nonzero = find(abscoef ~= 0);

if ~(sum(idx_nonzero) == 0)
    wR = w(idx_nonzero); 
    XR = X(:,idx_nonzero); % "R" means "reduced"
    
    options.nlambda = nlambda;
    options.thresh = tol;
    options.alpha = alpha;
    options.penalty_factor = wR; % weighted lasso 
    rng(randseed);
    CVerrR = cvglmnet(XR,y,[],options,[],nfold,[],isParallel); 
    betaR = cvglmnetCoef(CVerrR,cvRule);
    
    beta = zeros(n+1,1);
    beta(1) = betaR(1);
    beta(idx_nonzero+1) = betaR(2:end);
    
    runinfo.Step2.cvinfo = CVerrR;
else
    if (isPrint)
        fprintf('\n All coefficients from Step 1 are zeros. No need to run Step 2!');
    end
end
  
runinfo.Step2.beta = [beta(1) - (meanX./stdX)*beta(2:end); beta(2:end)./(stdX)']; % adjuste coeffcient back
runinfo.Step2.w = w;
runinfo.Step2.method = 'TobitWeightedLasso_cv'; 
runinfo.Step2.rsqr = 1 - norm(y -beta(1)- X*beta(2:end))^2 / norm(y-mean(y))^2; % Rsquare;
%%
%% Output
%%
beta = runinfo.Step2.beta;
%%
%% Compuational time
%%
if (isPrint)
    t1 = etime(clock,t0);
    fprintf('\n # Compuational time = %10.3e', t1);
    fprintf('\n');
end
end