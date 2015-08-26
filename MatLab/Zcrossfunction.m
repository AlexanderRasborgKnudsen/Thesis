function ZC = ZCwHyst(vec_in, hist_l, hist_h, figh,n)
% ZCwHyst - Zero crossings of a vector or a matrix, with hysteresis
% thresholds.
%
% Usage:
% D = ZCwHyst(vec_in, hist_l, hist_h, figh)
%
%   Inputs:
%       vec_in - vector or a matrix of data. if vec_in is a matrix,  the function
%       takes each column as an entry.
%       hist_l - lower hysteresis bound. should be 0 or below.
%       hist_h - upper hysteresis bound. should be 0 or above.
%       figh (optional) - figure handle for plot. To disable the plot, use
%       only 3 inputs or assign figh as []. To draw in a specific figure
%       window, assign the window number to figh. For a new figure window,
%       assign -1 to figh.
%
%   Output:
%       ZC = vector of the zero crossings. 
%       
%   In order to draw stairs graph of the crossings, use the following code:
%   ZC(ZC==0) = -1;
%   stairs(ZC)
% 
%
%
% Noam Greenboim
% www.perigee.co.il


% rotate row vector to column vector
if size(vec_in,1)==1 & size(vec_in,2)>1
    vec_in = vec_in';
end

if nargin==3    % without drawing plots
    figh = [];
end

below = vec_in<=hist_l; % below threshold
above = vec_in>=hist_h; % above threshold
Z = ~below & ~above;    % in between thresholds
str=sprintf('Signal filtered with CR-RC^%d filter ',n-2);

% draw threshold lines
if figh
    if figh==-1
        %figure(10);
        subplot(2,3,n)
        title(str)
    else
        figure(figh)
    end
    hold on
    plot(vec_in(5000:end))
    %plot(vec_in)
    line([1 length(vec_in)],[1 1]*hist_h,'color',[1 1 1]*0.6,'linestyle','--','linewidth',2)
    line([1 length(vec_in)],[1 1]*hist_l,'color',[1 1 1]*0.6,'linestyle','--','linewidth',2)
    %xlabel('samples')
    xlabel('Time')
    ylabel('Voltage')

end

%%
for k=1:size(vec_in,2)
    z0 = find(Z(:,k)==0,1,'first'); % find first crossing
    if ~isempty(z0)  % if any crossing found
        Z(1:z0,k) = false;
        z1 = find(Z(:,k)==1);
        for i=1:length(z1)
            below(z1(i),k) = below(z1(i)-1,k);
        end
    end
end
D = [0*below(1,:); abs(diff(below,1,1))];


if figh
    vec_in_D = vec_in;
    vec_in_D(D==0) = NaN;
    plot(vec_in_D(5000:end),'*r')
    %plot(vec_in_D,'*r')
end

ZC = ~isnan(vec_in_D);