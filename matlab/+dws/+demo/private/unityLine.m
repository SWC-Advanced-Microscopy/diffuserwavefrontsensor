function varargout=unityLine(lineProps,margin)
% function H=unityLine(lineProps,margin)
%    
% Purpose
% Add a unity line to the current axes
%
% Inputs
% lineProps - string optional line properties (default is 'k-')
% margin - how much of a margin to leave between the data points
%          and the axes. optional. 0.025 of the data range by
%          default. 
%    
% Outputs
% H [optional] - handle to the unity line.
%
%
% Rob Campbell - Jan 2010
    

if nargin<1 | isempty(lineProps), lineProps='k-'; end
if nargin<2, margin=[]; end

holdStatus=ishold;
if ~holdStatus, hold on,  end

fitAxesToData(margin)

H=plot(xlim,xlim,lineProps);

if ~holdStatus, hold off, end


if nargout==1
    varargout{1}=H;
end
