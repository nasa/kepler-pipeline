function val = kepler_get_soc(options,name,default,flag)
%KEPLER_GET_SOC Get STATS options parameter value.
%
%   val = kepler_get_soc(OPTIONS,'NAME') is a modified version of the original Matlab statget
%      function which supports the additional convSigma option for nlinfit_soc.
%   
%   See also statget kepler_set_soc statset nlinfit_soc nlinfit.
%
% Version date:  2008-june-17.
%
%   Copyright 1993-2008 The MathWorks, Inc.
%
%   This file is available under the terms of the MathWorks Limited License.
%   You should have received a copy of this license with the Kepler source
%   code; see the file MATHWORKS-LIMITED-LICENSE.docx.
%
% Modification history:
%
%     2008-june-17, PT:
%         replace _fpg in error messages with _soc.
%
%
%=========================================================================================

if nargin < 2
    error('stats:kepler_get_soc:TooFewInputs',...
          'Requires at least two input arguments.');
elseif nargin < 3
    default = [];
end

% Undocumented usage for fast access with no error checking.
if nargin == 4 && isequal('fast',flag)
    val = statgetfast(options,name,default);
    return
end

if ~isempty(options) && ~isa(options,'struct')
    error('stats:kepler_get_soc:InvalidOptions',...
          'First argument must be an options structure created with STATSET.');
end

if isempty(options)
    val = default;
    return;
end

names = ['Display    '; 'MaxFunEvals'; 'MaxIter    '; ...
         'TolBnd     '; 'TolFun     '; 'TolX       ';
         'GradObj    '; 'DerivStep  '; 'FunValCheck';
         'Robust     '; 'WgtFun     '; 'Tune       ';
         'convSigma  '];
lowNames = lower(names);

lowName = lower(name);
j = strmatch(lowName,lowNames);
if numel(j) == 1 % one match
    name = deblank(names(j,:));
elseif numel(j) > 1 % more than one match
    % Check for any exact matches (in case any names are subsets of others)
    k = strmatch(lowName,lowNames,'exact');
    if numel(k) == 1
        name = deblank(names(k,:));
    else
        matches = deblank(names(j(1),:));
        for k = j(2:end)', matches = [matches ', ' deblank(names(k,:))]; end
        error('stats:kepler_get_soc:BadParameter',...
              'Ambiguous parameter name ''%s'' (%s)', name, matches);
    end
else %if isempty(j) % no matches
    error('stats:kepler_get_soc:BadParameter',...
        'Unrecognized parameter name ''%s''.  See STATSET for choices.', name);
end

val = options.(name);
if isempty(val)
    val = default;
end


%------------------------------------------------------------------
function value = statgetfast(options,name,defaultopt)
%STATGETFAST Get STATS OPTIONS parameter with no error checking.
%   VAL = STATGETFAST(OPTIONS,FIELDNAME,DEFAULTOPTIONS) will get the value
%   of the FIELDNAME from OPTIONS with no error checking or fieldname
%   completion.  If the value is [], it gets the value of the FIELDNAME from
%   DEFAULTOPTIONS, another OPTIONS structure which is  probably a subset
%   of the options in OPTIONS.

if isempty(options)
    value = defaultopt.(name);
else
    value = options.(name);
    if isempty(value)
        value = defaultopt.(name);
    end
end
