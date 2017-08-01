function options = kepler_set_soc(varargin)
%kepler_set_soc Create/alter STATS options structure.
%
% options = kepler_set_soc('PARAM1',VALUE1,'PARAM2',VALUE2,...) is a modification of the
%     Matlab STATSET function for use with the kepler_nonlinear_fit_soc version of nlinfit.
%     kepler_set_soc supports one additional fitting option:
%
%      convSigma   - Convergence criterion for robust fitting based on 
%                    parameter uncertainty.  For each parameter in the fit,
%                    convergence has occurred when either the standadrd nlinfit
%                    convergence criterion is achieved OR the variation in the
%                    parameter from one iteration to the next of robust fitting
%                    is less than convSigma * the parameter estimated uncertainty.
%                    Default value of convSigma is zero, corresponding to the
%                    standard Matlab nlinfit convergence criterion.
%
%   See also kepler_get_soc statset kepler_nonlinear_fit_soc.
%
% Version date:  2008-December-16.
%
%   Copyright 1993-2008 The MathWorks, Inc.
%
%   This file is available under the terms of the MathWorks Limited License.
%   You should have received a copy of this license with the Kepler source
%   code; see the file MATHWORKS-LIMITED-LICENSE.docx.

% Revision history:
%
%     2008-December-16, PT:
%          add 'time' option to Display (displays iteration times for robust fit).
%     2008-june-17, PT:
%          update error messages to say kepler_set_soc instead of statset_fpg; update
%          nlinfit_fpg options to kepler_nonlinear_fit_soc.
%
%=========================================================================================

% Print out possible values of properties.
if (nargin == 0) && (nargout == 0)
    fprintf('                Display: [ off | notify | final ]\n');
    fprintf('            MaxFunEvals: [ positive integer ]\n');
    fprintf('                MaxIter: [ positive integer ]\n');
    fprintf('                 TolBnd: [ positive scalar ]\n');
    fprintf('                 TolFun: [ positive scalar ]\n');
    fprintf('                   TolX: [ positive scalar ]\n')
    fprintf('                GradObj: [ off | on ]\n')
    fprintf('              DerivStep: [ positive scalar or vector ]\n')
    fprintf('            FunValCheck: [ off | on ]\n')
    fprintf('                 Robust: [ off | on ]\n')
    fprintf('                 WgtFun: [ string ]\n')
    fprintf('                   Tune: [ positive scalar ]\n')
    fprintf('              convSigma: [ positive scalar ]\n')
    fprintf('\n');
    return;
end

options = struct('Display', [], 'MaxFunEvals', [], 'MaxIter', [], ...
                 'TolBnd', [], 'TolFun', [], 'TolX', [], 'GradObj', [], ...
                 'DerivStep', [], 'FunValCheck', [], 'Robust',[],'WgtFun',[],...
                 'Tune',[],'convSigma',[]);

% If a function name/handle was passed in, then return the defaults.
if nargin == 1
    arg = varargin{1};
    if (ischar(arg) || isa(arg,'function_handle'))
        if isa(arg,'function_handle')
            arg = func2str(arg);
        end
        % Display is off by default.  The individual fitters have their own
        % warning/error messages that can be controlled via IDs.  The
        % optimizers print out text when display is on, but do not generate
        % warnings or errors per se.
        options.Display = 'off';
        % Robust is off by default.
        options.Robust = 'off';
        switch lower(arg)
        case 'factoran'
            options.MaxFunEvals = 400;
            options.MaxIter = 100;
            options.TolFun = 1e-8;
            options.TolX = 1e-8;
        case {'normfit' 'lognfit' 'gamfit' 'bisafit' 'invgfit' 'logifit'...
              'loglfit' 'nakafit' 'coxphfit'} % these use statsfminbx
            options.MaxFunEvals = 200;
            options.MaxIter = 100;
            options.TolBnd = 1e-6;
            options.TolFun = 1e-8;
            options.TolX = 1e-8;
        case {'evfit' 'wblfit'} % these use fzero (gamfit sometimes does too)
            options.TolX = 1e-6;
        case {'gpfit' 'gevfit' 'nbinfit' 'ricefit' 'tlsfit'} % these use fminsearch
            options.MaxFunEvals = 400;
            options.MaxIter = 200;
            options.TolBnd = 1e-6;
            options.TolFun = 1e-6;
            options.TolX = 1e-6;
        case {'nlinfit','kepler_nonlinear_fit_soc'}
            options.MaxIter = 200;
            options.TolFun = 1e-8;
            options.TolX = 1e-8;
            options.DerivStep = eps^(1/3);
            options.FunValCheck = 'on';
            options.Robust = 'off';
        case 'mlecustom'
            options.MaxFunEvals = 400;
            options.MaxIter = 200;
            options.TolBnd = 1e-6;
            options.TolFun = 1e-6;
            options.TolX = 1e-6;
            options.GradObj = 'off';
            options.DerivStep = eps^(1/3);
            options.FunValCheck = 'on';
        case 'mlecov'
            options.GradObj = 'off';
            options.DerivStep = eps^(1/4);
        case 'mdscale'
            options.MaxIter = 200;
            options.TolFun = 1e-6;
            options.TolX = 1e-6;
        case {'mvncdf' 'mvtcdf'}
            options.MaxFunEvals = 1e7;
            options.TolFun = [];
        otherwise
            error('stats:kepler_set_soc:BadFunctionName',...
                  'No default options available for the function ''%s''.',arg);
        end
        return
    end
end



names = fieldnames(options);
lowNames = lower(names);
numNames = numel(names);

% Process OLDOPTS and NEWOPTS, if it's there.
i = 1;
while i <= nargin
    arg = varargin{i};
    % Check if we're into the param name/value pairs yet.
    if ischar(arg), break; end

    if ~isempty(arg) % [] is a valid options argument
        if ~isa(arg,'struct')
            error('stats:kepler_set_soc:BadInput',...
                  ['Expected argument %d to be a parameter name string or ' ...
                   'an options structure\ncreated with STATSET.'], i);
        end
        argNames = fieldnames(arg);
        for j = 1:numNames
            name = names{j};
            if any(strcmp(name,argNames))
                val = arg.(name);
                if ~isempty(val)
                    if ischar(val)
                        val = lower(deblank(val));
                    end
                    [valid, errid, errmsg] = checkparam(name,val);
                    if valid
                        options.(name) = val;
                    elseif ~isempty(errmsg)
                        error(errid,errmsg);
                    end
                end
            end
        end
    end
    i = i + 1;
end

% Done with OLDOPTS and NEWOPTS, now parse parameter name/value pairs.
if rem(nargin-i+1,2) ~= 0
    error('stats:kepler_set_soc:BadInput',...
          'Arguments must occur in name-value pairs.');
end
expectval = false; % start expecting a name, not a value
while i <= nargin
    arg = varargin{i};

    % Process a parameter name.
    if ~expectval
        if ~ischar(arg)
            error('stats:kepler_set_soc:BadParameter',...
                  'Expected argument %d to be a parameter name string.', i);
        end
        lowArg = lower(arg);
        j = strmatch(lowArg,lowNames);
        if numel(j) == 1 % one match
            name = names{j};
        elseif length(j) > 1 % more than one match
            % Check for any exact matches (in case any names are subsets of others)
            k = strmatch(lowArg,lowNames,'exact');
            if numel(k) == 1
                name = names{k};
            else
                matches = names{j(1)};
                for k = j(2:end)', matches = [matches ', ' names{k}]; end
                error('stats:kepler_set_soc:BadParameter',...
                      'Ambiguous parameter name ''%s'' (%s)', arg, matches);
            end
        else %if isempty(j) % no matches
            error('stats:kepler_set_soc:BadParameter',...
                  'Unrecognized parameter name ''%s''.', arg);
        end
        expectval = true; % expect a value next

    % Process a parameter value.
    else
        if ischar(arg)
            arg = lower(deblank(arg));
        end
        [valid, errid, errmsg] = checkparam(name,arg);
        if valid
            options.(name) = arg;
        elseif ~isempty(errmsg)
            error(errid,errmsg);
        end
        expectval = false; % expect a name next
    end
    i = i + 1;
end

% The default wgt function for robust fit is bisquare.
if (strcmp(options.Robust, 'on') && isempty(options.WgtFun))
    options.WgtFun = 'bisquare';
end
if strcmp(options.Robust, 'on')
    if ischar(options.WgtFun)
        switch(options.WgtFun )
            case 'andrews',  options.Tune = 1.339;
            case 'bisquare', options.Tune = 4.685;
            case 'cauchy',   options.Tune = 2.385;
            case 'fair',     options.Tune = 1.400;
            case 'huber',    options.Tune = 1.345;
            case 'logistic', options.Tune = 1.205;
            case 'ols',      options.Tune = 1;
            case 'talwar',   options.Tune = 2.795;
            case 'welsch',   options.Tune = 2.985;
        end
    end
    if isempty(options.Tune) || ~isnumeric(options.Tune)
        error('stats:kepler_set_soc:BadParameter', 'Tune must be provided for user-defined WgtFun');
    end
end

% set default of convSigma to zero
if (strcmp(options.Robust, 'on') && isempty(options.convSigma))
    options.convSigma = 0 ;
end

%-------------------------------------------------
function [valid, errid, errmsg] = checkparam(name,value)
%CHECKPARAM Validate a STATSET parameter value.
%   [VALID,ID,MSG] = CHECKPARAM('name',VALUE) checks that the specified
%   value VALUE is valid for the parameter 'name'.
valid = true;
errmsg = '';
errid = '';

% Empty is always a valid parameter value.
if isempty(value)
    return
end

switch name
case {'TolFun','TolBnd','TolX'} % positive real scalar
    if ~isfloat(value) || ~isreal(value) || ~isscalar(value) || any(value <= 0)
        valid = false;
        errid = 'stats:kepler_set_soc:BadTolerance';
        if ischar(value)
            errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar (not a string).',name);
        else
            errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar.',name);
        end
    end
case {'Display'} % off,notify,final,iter
    values = ['off   '; 'notify'; 'final '; 'iter  '; 'time  '];
    if ~ischar(value) || isempty(strmatch(value,values,'exact'))
        valid = false;
        errid = 'stats:kepler_set_soc:BadDisplay';
        errmsg = sprintf('STATSET parameter ''%s'' must be ''off'', ''notify'', ''final'', ''time'', or ''iter''.',name);
    end
case {'MaxIter' 'MaxFunEvals'} % non-negative integer, possibly inf
    if ~isfloat(value) || ~isreal(value) || ~isscalar(value) || any(value < 0)
        valid = false;
        errid = 'stats:kepler_set_soc:BadMaxValue';
        if ischar(value)
            errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar (not a string).',name);
        else
            errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar.',name);
        end
    end
case {'GradObj' 'FunValCheck' 'Robust'}
    values = ['off'; 'on '];
    if ~ischar(value) || isempty(strmatch(value,values,'exact'))
        valid = false;
        errid = 'stats:kepler_set_soc:BadFlagValue';
        errmsg = sprintf('STATSET parameter ''%s'' must be ''off'' or ''on''.',name);
    end
case {'WgtFun'}
    values = ['andrews ';'bisquare';'cauchy  ';'fair    '; 'huber   '; 'logistic'; 'talwar  ';  'welsch  '];
    % allow custom wgt function
   if ~strcmp(class(value), 'function_handle')&&(~ischar(value) || isempty(strmatch(value,values,'exact')))
        valid = false;
        errid = 'stats:kepler_set_soc:BadWeightFunction';
        errmsg = sprintf('STATSET parameter ''%s'' is not valid.',name);
    end
case 'DerivStep'
    if ~isfloat(value) || ~isreal(value) || any(value <= 0)
        valid = false;
        errid = 'stats:kepler_set_soc:BadDifference';
        errmsg = sprintf('STATSET parameter ''%s'' must contain real positive values.',name);
    end
case 'convSigma'
    if ~isfloat(value) || ~isreal(value) || any(value < 0)
        valid = false;
        errid = 'stats:kepler_set_soc:BadConvSigma';
        errmsg = sprintf('STATSET parameter ''%s'' must contain real positive values.',name);
    end
case 'Tune'
if ~isfloat(value) || ~isreal(value) || any(value <= 0)
    valid = false;
    errid = 'stats:kepler_set_soc:BadTune';
    errmsg = sprintf('STATSET parameter ''%s'' must contain real positive values.',name);
end
otherwise
    valid = false;
    errid = 'stats:kepler_set_soc:BadParameter';
    errmsg = sprintf('Invalid STATSET parameter name: ''%s''.',name);
end
