% generateM generates the matlab wrapper for the mex files which simplifies the calling of the mex simulation file
%
% USAGE:
% ======
% generateM( modelname, modelstruct)
%
% INPUTS:
% =======
% modelname ... specifies the name of the model which will be later used for the naming of the simualation file
% modelstruct ... is the struct generated by parseModel

function cw_generateM( filename, struct )
%GENERATEM Summary of this function goes here
%   Detailed explanation goes here

[odewrap_path,~,~]=fileparts(which('cw_compileC.m'));

nmx = struct.sym.nmx;
nx = length(struct.sym.x);
ny = length(struct.sym.y);
np = length(struct.sym.p);
nk = length(struct.sym.k);
nk1 = struct.sym.nk1;
ndisc = struct.ndisc;
nr = length(struct.sym.root)-ndisc;
nnz = struct.nnz;

fid = fopen(fullfile(odewrap_path,'models',filename,['simulate_',filename,'.m']),'w');
fprintf(fid,['%% simulate_' filename '.m is the matlab interface to the cvodes mex\n'...
    '%%   which simulates the ordinary differential equation and respective\n'...
    '%%   sensitivities according to user specifications.\n'...
    '%%\n'...
    '%% USAGE:\n'...
    '%% ======\n'...
    '%% [...] = simulate_' filename '(tout,theta)\n'...
    '%% [...] = simulate_' filename '(tout,theta,kappa,options)\n'...
    '%% sol = simulate_' filename '(...)\n'...
    ]);
if nmx == 0
    fprintf(fid,[
        '%% [status,tout,x,y,sx,sy] = simulate_' filename '(...)\n'...
        ]);
elseif nmx > 0
    fprintf(fid,[
        '%% [status,tout,x,mx,y,sx,smx,sy] = simulate_' filename '(...)\n'...
        ]);
end
fprintf(fid,[
    '%%\n'...
    '%% INPUTS:\n'...
    '%% =======\n'...
    '%% tout ... 1 dimensional vector of timepoints at which a solution to the ODE is desired\n'...
    '%% theta ... 1 dimensional parameter vector of parameters for which sensitivities are desired.\n'...
    '%%           this corresponds to the specification in model.sym.p\n'...
    '%% kappa ... 1 dimensional parameter vector of parameters for which sensitivities are not desired.\n'...
    '%%           this corresponds to the specification in model.sym.k\n'...
    '%%           Arbitrary initial conditions can be provided in kappa (see ACME/doc/ACME_doc.pdf for detailed instructions).\n'...
    '%% options ... additional options to pass to the cvodes solver. Refer to the cvodes guide for more documentation.\n'...
    '%%    .cvodes_atol ... absolute tolerance for the solver. default is specified in the user-provided syms function.\n'...
    '%%    .cvodes_rtol ... relative tolerance for the solver. default is specified in the user-provided syms function.\n'...
    '%%    .cvodes_maxsteps    ... maximal number of integration steps. default is specified in the user-provided syms function.\n'...
    '%%    .tstart    ... start of integration. for all timepoints before this, values will be set to initial value.\n'...
    '%%    .sens_ind ... 1 dimensional vector of indexes for which sensitivities must be computed.\n'...
    '%%           default value is 1:length(theta).\n'...
    '%%    .lmm    ... linear multistep method for forward problem.\n'...
    '%%        1: Adams-Bashford\n'...
    '%%        2: BDF (DEFAULT)\n'...
    '%%    .iter    ... iteration method for linear multistep.\n'...
    '%%        1: Functional\n'...
    '%%        2: Newton (DEFAULT)\n'...
    '%%    .linsol   ... linear solver module.\n'...
    '%%        direct solvers:\n'...
    '%%        1: Dense (DEFAULT)\n'...
    '%%        2: Band (not implented)\n'...
    '%%        3: LAPACK Dense (not implented)\n'...
    '%%        4: LAPACK Band  (not implented)\n'...
    '%%        5: Diag (not implented)\n'...
    '%%        implicit krylov solvers:\n'...
    '%%        6: SPGMR\n'...
    '%%        7: SPBCG\n'...
    '%%        8: SPTFQMR\n'...
    '%%        sparse solvers:\n'...
    '%%        9: KLU\n'...
    '%%    .stldet   ... flag for stability limit detection. this should be turned on for stiff problems.\n'...
    '%%        0: OFF\n'...
    '%%        1: ON (DEFAULT)\n'...
    '%%    .qPositiveX   ... vector of 0 or 1 of same dimension as state vector. 1 enforces positivity of states.\n'...
    '%%    .sensi_meth   ... method for sensitivity computation.\n'...
    '%%        1: Forward Sensitivity Analysis (DEFAULT)\n'...
    '%%        2: Adjoint Sensitivity Analysis\n'...
    '%%    .ism   ... only available for sensi_meth == 1. Method for computation of forward sensitivities.\n'...
    '%%        1: Simultaneous (DEFAULT)\n'...
    '%%        2: Staggered\n'...
    '%%        3: Staggered1\n'...
    '%%    .Nd   ... only available for sensi_meth == 2. Number of Interpolation nodes for forward solution. \n'...
    '%%              Default is 1000. \n'...
    '%%    .interpType   ... only available for sensi_meth == 2. Interpolation method for forward solution.\n'...
    '%%        1: Hermite (DEFAULT)\n'...
    '%%        2: Polynomial\n'...
    '%%    .lmmB   ... only available for sensi_meth == 2. linear multistep method for backward problem.\n'...
    '%%        1: Adams-Bashford\n'...
    '%%        2: BDF (DEFAULT)\n'...
    '%%    .iterB   ... only available for sensi_meth == 2. iteration method for linear multistep.\n'...
    '%%        1: Functional\n'...
    '%%        2: Newton (DEFAULT)\n'...
    '%%\n'...
    '%% Outputs:\n'...
    '%% ========\n'...
    '%% sol.status ... flag for status of integration. generally status<0 for failed integration\n'...
    '%% sol.tout ... vector at which the solution was computed\n'...
    '%% sol.x ... time-resolved state vector\n'...
    ]);
if nmx > 0
    fprintf(fid,[
        '%% sol.mx ... time-resolved vector of the moments of species\n'...
        ]);
end
fprintf(fid,[
    '%% sol.y ... time-resolved output vector\n'...
    '%% sol.sx ... time-resolved state sensitivity vector\n'...
    ]);
if nmx > 0
    fprintf(fid,[
        '%% sol.smx ... time-resolved sensitivity vector of the moments of species\n'...
        ]);
end
fprintf(fid,[
    '%% sol.sy ... time-resolved output sensitivity vector\n'...
    '%% sol.xdot time-resolved right-hand side of differential equation\n'...
    '%% sol.rootval value of root at end of simulation time\n'...
    '%% sol.srootval value of root at end of simulation time\n'...
    '%% sol.root time of events\n'...
    '%% sol.sroot value of root at end of simulation time\n'...
    ]);
fprintf(fid,['function varargout = simulate_' filename '(varargin)\n\n']);
fprintf(fid,['%% DO NOT CHANGE ANYTHING IN THIS FILE UNLESS YOU ARE VERY SURE ABOUT WHAT YOU ARE DOING\n']);
fprintf(fid,['%% MANUAL CHANGES TO THIS FILE CAN RESULT IN WRONG SOLUTIONS AND CRASHING OF MATLAB\n']);
fprintf(fid,['if(nargin<2)\n']);
fprintf(fid,['    error(''Not enough input arguments.'');\n']);
fprintf(fid,['else\n']);
fprintf(fid,['    tout=varargin{1};\n']);
fprintf(fid,['    phi=varargin{2};\n']);
fprintf(fid,['end\n']);

fprintf(fid,['if(nargin>=3)\n']);
fprintf(fid,['    kappa=varargin{3};\n']);
fprintf(fid,['   if(length(kappa)==',num2str(nk1),')\n']);
fprintf(fid,['    kappa(',num2str(nk1+1),':',num2str(nk),')=0;\n']);
fprintf(fid,['   end\n']);
fprintf(fid,['else\n']);
fprintf(fid,['    kappa=zeros(1,',num2str(nk),');\n']);
fprintf(fid,['end\n']);

fprintf(fid,['if(nargout>1)\n']);
fprintf(fid,['    if(nargout>4)\n']);
fprintf(fid,['        options_cvode.sensi = 1;\n']);
fprintf(fid,['    else\n']);
fprintf(fid,['        options_cvode.sensi = 0;\n']);
fprintf(fid,['    end\n']);
fprintf(fid,['else\n']);
fprintf(fid,['    options_cvode.sensi = 1;\n']);
fprintf(fid,['end\n']);

if(isfield(struct,'param'))
    switch(struct.param)
        case 'log'
            fprintf(fid,'theta = exp(phi);\n\n');
        case 'log10'
            fprintf(fid,'theta = 10.^(phi);\n\n');
        case 'lin'
            fprintf(fid,'theta = phi;\n\n');
        otherwise
            disp('No valid parametrisation chosen! Valid options are "log","log10" and "lin". Using linear parametrisation (default)!')
            fprintf(fid,'theta = phi;\n\n');
    end
else
    disp('No parametrisation chosen! Using linear parametrisation (default)!')
    fprintf(fid,'theta = phi;\n\n');
end
fprintf(fid,'\n');

fprintf(fid,['options_cvode.cvodes_atol = ' num2str(struct.atol) ';\n']);
fprintf(fid,['options_cvode.cvodes_rtol = ' num2str(struct.atol) ';\n']);
fprintf(fid,['options_cvode.cvodes_maxsteps = ' num2str(struct.maxsteps) ';\n']);
fprintf(fid,['options_cvode.sens_ind = 1:' num2str(np) ';\n']);
fprintf(fid,['options_cvode.nx = ' num2str(nx) '; %% MUST NOT CHANGE THIS VALUE\n']);
fprintf(fid,['options_cvode.ny = ' num2str(ny) '; %% MUST NOT CHANGE THIS VALUE\n']);
fprintf(fid,['options_cvode.nr = ' num2str(nr) '; %% MUST NOT CHANGE THIS VALUE\n']);
fprintf(fid,['options_cvode.ndisc = ' num2str(ndisc) '; %% MUST NOT CHANGE THIS VALUE\n']);
fprintf(fid,['options_cvode.nnz = ' num2str(nnz) '; %% MUST NOT CHANGE THIS VALUE\n']);

fprintf(fid,['options_cvode.tstart = ' num2str(struct.t0) ';\n']);
fprintf(fid,['options_cvode.lmm = 2;\n']);
fprintf(fid,['options_cvode.iter = 2;\n']);
fprintf(fid,['options_cvode.linsol = 9;\n']);
fprintf(fid,['options_cvode.stldet = 1;\n']);
fprintf(fid,['options_cvode.Nd = 1000;\n']);
fprintf(fid,['options_cvode.interpType = 1;\n']);
fprintf(fid,['options_cvode.lmmB = 2;\n']);
fprintf(fid,['options_cvode.iterB = 2;\n']);
fprintf(fid,['options_cvode.ism = 1;\n']);
fprintf(fid,['options_cvode.sensi_meth = 1;\n\n']);
fprintf(fid,['options_cvode.nmaxroot = 100;\n\n']);
fprintf(fid,['options_cvode.ubw = ' num2str(struct.ubw) ';\n\n']);
fprintf(fid,['options_cvode.lbw = ' num2str(struct.lbw)  ';\n\n']);

fprintf(fid,['options_cvode.qPositiveX = zeros(length(tout),' num2str(nx) ');\n']);

fprintf(fid,['\n']);

fprintf(fid,['sol.status = 0;\n']);
fprintf(fid,['sol.t = tout;\n']);
fprintf(fid,['sol.x = zeros(length(tout),' num2str(nx) ');\n']);
fprintf(fid,['sol.y = zeros(length(tout),' num2str(ny) ');\n']);
fprintf(fid,['sol.xdot = zeros(length(tout),' num2str(nx) ');\n']);
fprintf(fid,['sol.root = NaN(options_cvode.nmaxroot,' num2str(nr) ');\n']);
fprintf(fid,['sol.rootval = NaN(options_cvode.nmaxroot,' num2str(nr) ');\n']);
fprintf(fid,['sol.numsteps = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numrhsevals = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numlinsolvsetups = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numerrtestfails = zeros(length(tout),1);\n']);
fprintf(fid,['sol.order = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numnonlinsolviters = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numjacevals = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numliniters = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numconvfails = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numprecevals = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numprecsolves = zeros(length(tout),1);\n\n']);
fprintf(fid,['sol.numjtimesevals = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numstepsS = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numrhsevalsS = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numlinsolvsetupsS = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numerrtestfailsS = zeros(length(tout),1);\n']);
fprintf(fid,['sol.orderS = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numnonlinsolvitersS = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numjacevalsS = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numlinitersS = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numconvfailsS = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numprecevalsS = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numprecsolvesS = zeros(length(tout),1);\n']);
fprintf(fid,['sol.numjtimesevalsS = zeros(length(tout),1);\n']);
fprintf(fid,'\n');
fprintf(fid,'pbar = ones(size(theta));\n');
fprintf(fid,'pbar(pbar==0) = 1;\n');
fprintf(fid,'xscale = [];\n');

fprintf(fid,['if(nargin>=4)\n']);
fprintf(fid,['    options_cvode = cw_setdefault(varargin{4},options_cvode);\n']);
fprintf(fid,['else\n']);
fprintf(fid,['end\n']);
fprintf(fid,['options_cvode.np = length(options_cvode.sens_ind); %% MUST NOT CHANGE THIS VALUE\n']);
fprintf(fid,'plist = options_cvode.sens_ind-1;\n');

fprintf(fid,'if(options_cvode.sensi>0)\n');
fprintf(fid,['    sol.xS = zeros(length(tout),' num2str(nx) ',length(options_cvode.sens_ind));\n']);
fprintf(fid,['    sol.yS = zeros(length(tout),' num2str(ny) ',length(options_cvode.sens_ind));\n']);
fprintf(fid,['    sol.rootS =  NaN(options_cvode.nmaxroot,' num2str(nr) ',length(options_cvode.sens_ind));\n']);
fprintf(fid,['    sol.rootvalS =  NaN(options_cvode.nmaxroot,' num2str(nr) ',length(options_cvode.sens_ind));\n']);
fprintf(fid,'end\n');

fprintf(fid,['if(max(options_cvode.sens_ind)>' num2str(np) ')\n']);
fprintf(fid,['    error(''Sensitivity index exceeds parameter dimension!'')\n']);
fprintf(fid,['end\n']);

fprintf(fid,['cw_' filename '(sol,tout,theta(1:' num2str(np) '),kappa(1:' num2str(nk) '),options_cvode,plist,pbar,xscale);\n']);
fprintf(fid,['rt = [' num2str(struct.rt) '];\n']);
fprintf(fid,['sol.x = sol.x(:,rt);\n']);
fprintf(fid,['sol.xdot = sol.xdot(:,rt);\n']);
fprintf(fid,'if(options_cvode.sensi>0)\n');
if(isfield(struct,'param'))
    switch(struct.param)
        case 'log'
            fprintf(fid,['    sol.sx = bsxfun(@times,sol.xS(:,rt,:),permute(theta(options_cvode.sens_ind),[3,2,1]));\n']);
            fprintf(fid,['    sol.sy = bsxfun(@times,sol.yS,permute(theta(options_cvode.sens_ind),[3,2,1]));\n']);
            fprintf(fid,['    sol.sroot = bsxfun(@times,sol.rootS,permute(theta(options_cvode.sens_ind),[3,2,1]));\n']);
            fprintf(fid,['    sol.srootval = bsxfun(@times,sol.rootvalS,permute(theta(options_cvode.sens_ind),[3,2,1]));\n']);
        case 'log10'
            fprintf(fid,['    sol.sx = bsxfun(@times,sol.xS(:,rt,:),permute(theta(options_cvode.sens_ind),[3,2,1])*log(10));\n']);
            fprintf(fid,['    sol.sy = bsxfun(@times,sol.yS,permute(theta(options_cvode.sens_ind),[3,2,1])*log(10));\n']);
            fprintf(fid,['    sol.sroot = bsxfun(@times,sol.rootS,permute(theta(options_cvode.sens_ind),[3,2,1])*log(10));\n']);
            fprintf(fid,['    sol.srootval = bsxfun(@times,sol.rootvalS,permute(theta(options_cvode.sens_ind),[3,2,1])*log(10));\n']);
        case 'lin'
            fprintf(fid,'    sol.sx = sol.xS(:,rt,:);\n');
            fprintf(fid,'    sol.sy = sol.yS;\n');
            fprintf(fid,'    sol.sroot = sol.rootS;\n');
            fprintf(fid,'    sol.srootval = sol.rootvalS;\n');
        otherwise
            fprintf(fid,'    sol.sx = sol.xS(:,rt,:);\n');
            fprintf(fid,'    sol.sy = sol.yS;\n');
            fprintf(fid,'    sol.sroot = sol.rootS;\n');
            fprintf(fid,'    sol.srootval = sol.rootvalS;\n');
    end
else
    fprintf(fid,'    sol.sx = sol.xS(:,rt,:);\n');
    fprintf(fid,'    sol.sy = sol.yS;\n');
    fprintf(fid,'    sol.sroot = sol.rootS;\n');
    fprintf(fid,'    sol.srootval = sol.rootvalS;\n');
end
fprintf(fid,'end\n');
fprintf(fid,['if(nargout>1)\n']);
fprintf(fid,['    varargout{1} = sol.status;\n']);
fprintf(fid,['    varargout{2} = sol.t;\n']);
fprintf(fid,['    varargout{3} = sol.x;\n']);
if nmx > 0
    fprintf(fid,['    varargout{4} = sol.y(:,1:',num2str(nmx),'); %% Moments of species\n']);
    fprintf(fid,['    varargout{5} = sol.y(:,',num2str(nmx+1),':end);\n']);
    fprintf(fid,['    if(nargout>5)\n']);
    fprintf(fid,['        varargout{6} = sol.sx;\n']);
    fprintf(fid,['        varargout{7} = sol.sy(:,1:',num2str(nmx),',:);\n']);
    fprintf(fid,['        varargout{8} = sol.sy(:,',num2str(nmx+1),':end,:);\n']);
    fprintf(fid,['    end\n']);
else
    fprintf(fid,['    varargout{4} = sol.y; %% Moments of species\n']);
    fprintf(fid,['    if(nargout>4)\n']);
    fprintf(fid,['        varargout{5} = sol.sx;\n']);
    fprintf(fid,['        varargout{6} = sol.sy;\n']);
    fprintf(fid,['    end\n']);
end

fprintf(fid,['else\n']);
if nmx>0
    fprintf(fid,['    sol.mx = sol.y(:,1:',num2str(nmx),');\n']);
    fprintf(fid,['    sol.y =  sol.y(:,',num2str(nmx+1),':end);\n']);
    fprintf(fid,['    sol.smx = sol.sy(:,1:',num2str(nmx),',:);\n']);
    fprintf(fid,['    sol.sy =  sol.sy(:,',num2str(nmx+1),':end,:);\n']);
end
fprintf(fid,['    sol.theta = theta;\n']);
fprintf(fid,['    sol.kappa = kappa;\n']);
fprintf(fid,['    varargout{1} = sol;\n']);
fprintf(fid,['end\n']);
fprintf(fid,'end\n');

fclose(fid);
end
