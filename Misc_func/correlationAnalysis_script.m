function correlationAnalysis_script(corr_coef, smooth_corr, granularity, roi_size, dt, type, mode, smooth_window)
% function correlationAnalysis_script(corr_coef, smooth_corr, granularity, roi_size, dt, type, mode, smooth_window)
% Script to run correlation analysis for the Correlation Panel
%
% Parameters:
% corr_coef: a matrix with correlation coefficients
% -  Normal run: [ROI_no, 1, Frame_no, M1/M2]
% -  Grid run: [Y_no, X_no, Frame_no, M1/M2]
% smooth_corr: a smoothed correlation coefficient
% -  Normal run: [ROI_no, 1, Frame_no, M1/M2]
% -  Grid run: [Y_no, X_no, Frame_no, M1/M2]
% granularity: granularity value
% -  Normal run: [ROI_no, 1, Frame_no]
% -  Grid run: [Y_no, X_no, Frame_no]
% roi_size: a total number of pixels in the roi
% -  Normal run: [ROI_no, 1]
% -  Grid run: [Y_no, X_no]
% dt: time between the frames, a value
% type: a type of correlation coefficient: Pearson, Manders...
% mode: a mode of calculation: 'relative', 'absolute'
% smooth_window: a number of frames used for smoothing
% @see calc_correlation.m, ib_calcCorrelation

% Copyright (C) 21.11.2013 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 

if size(corr_coef,4) == 2
    manders_sw = 2;
else
    manders_sw = 1;
end
type = cell2mat(type);
mode = cell2mat(mode);

if size(corr_coef,1) == 1 & size(corr_coef,2) == 1  % single roi or the whole image
    %time = 0:dt:size(pearson,1)*dt-dt;
    time = 1:size(corr_coef,3);
    figure(1);
    clf;
    h=plot(time,squeeze(corr_coef(1,1,:,1)),'o-',time,squeeze(corr_coef(1,1,:,manders_sw)),'o-');
    title(sprintf('Correlation, %s %s\nroi size=%d pix', type, mode,roi_size(1,1)));
    set(h,'MarkerSize',5);
    set(h,'MarkerFaceColor','b');
    set(gca,'xlim',[0 time(end)]);
    grid;
    xlabel('frame, no');
    ylabel('correlation coef');
    figure(2);
    clf;
    h=plot(time,squeeze(smooth_corr(1,1,:,1)),'o-',time,squeeze(smooth_corr(1,1,:,manders_sw)),'o-');
    title(sprintf('Smoothed corr. coef., %s %s mode\nWindow size: %d',type,mode,smooth_window)); 
    set(h,'MarkerSize',5);
    set(h,'MarkerFaceColor','b');
    set(gca,'xlim',[0 time(end)]);
    grid;
    xlabel('frame, no');
    ylabel('corr.coef.');
    
    figure(3);
    clf;
    h=plot(time,squeeze(granularity(1,1,:)),'o-');
    set(h,'MarkerSize',5);
    set(h,'MarkerFaceColor','b');
    title(['Granularity, ' type ' ' mode ' mode']);
    set(gca,'xlim',[0 time(end)]);
    grid;
    xlabel('frame, no');
    ylabel('granularity');
    
    figure(4);
    smooth_vec1 = squeeze(smooth_corr(1,1,:,1))';    % M1
    %smooth_vec2 = squeeze(smooth_corr(1,1,:,manders_sw))'; % M2
    hist(smooth_vec1);
    title('Smoothed corr. coef. histogram (not M2)');
    grid;
elseif size(corr_coef,1) > 1 & size(corr_coef,2) == 1  % set of rois
    roi_no = size(corr_coef,1);    % number of rois
    hor_no = ceil(sqrt(roi_no));   % number of horizontal plots
    ver_no = ceil(sqrt(roi_no));   % number of vertical plots
    %time = 0:dt:size(pearson,2)*dt-dt;
    time = 1:size(corr_coef,3);
    figure(1)   % plot correlation coef.
    clf;
    index = 1;
    for y=1:ver_no
        for x=1:hor_no
            if index <= roi_no
                subplot(hor_no,ver_no,index);
                h=plot(time,squeeze(corr_coef(index,1,:,1)),'o-',time,squeeze(corr_coef(index,1,:,manders_sw)),'o-');
                title(sprintf('Corr. ROI=%d %s %s\nroi size=%d pix', index, type, mode,roi_size(index,1)));
                set(h,'MarkerSize',3);
                set(h,'MarkerFaceColor','b');
                set(gca,'xlim',[0 time(end)]);
                xlabel('frame, no');
                ylabel('corr. func.');
                grid;
                index = index + 1;
            end
        end
    end
    figure(2)   % plot smoothed corr. coef.
    clf;
    index = 1;
    for y=1:ver_no
        for x=1:hor_no
            if index <= roi_no
                subplot(hor_no,ver_no,index);
                h=plot(time,squeeze(smooth_corr(index,1,:,1)),'o-',time,squeeze(smooth_corr(index,1,:,manders_sw)),'o-');
                title(['Smoothed, ROI=' num2str(index) ' ' type ' ' mode ' mode']);
                title(sprintf('Smoothed,ROI=%d %s %s mode\nWindow size: %d',index,type,mode,smooth_window)); 
                set(h,'MarkerSize',3);
                set(h,'MarkerFaceColor','b');
                set(gca,'xlim',[0 time(end)]);
                grid;
                xlabel('frame, no');
                ylabel('corr.coef.');
                index = index + 1;
            end
        end
    end
    figure(3)   % plot granularity
    clf;
    index = 1;
    for y=1:ver_no
        for x=1:hor_no
            if index <= roi_no
                subplot(hor_no,ver_no,index);
                h=plot(time,squeeze(granularity(index,1,:)),'o-');
                set(h,'MarkerSize',3);
                set(h,'MarkerFaceColor','b');
                title(['Granularity, ROI=' num2str(index)]);
                set(gca,'xlim',[0 time(end)]);
                grid;
                xlabel('frame, no');
                ylabel('granularity');
                index = index + 1;
            end
        end
    end
    
    figure(4);
    smooth_vec = smooth_corr(:,1,:,1);
    hist(squeeze(smooth_vec)');
    title('Smoothed corr.coef. histogram (not M2)');
    grid;
    
else        % grid run
    %time = 0:dt:size(pearson,3)*dt-dt;
    time = 1:size(corr_coef,3);
    hor_no = size(corr_coef,2);
    ver_no = size(corr_coef,1);
    index = 1;
    
    if hor_no*ver_no<=25
        figure(1)   % plot pearsons coef.
        clf;
        for y=1:ver_no
            for x=1:hor_no
                subplot(ver_no,hor_no,index);
                h=plot(time,squeeze(corr_coef(y,x,:,1)),'o-',time,squeeze(corr_coef(y,x,:,manders_sw)),'o-');
                title(sprintf('%s X=%d Y=%d\nroi size=%d pix', type, x, y, roi_size(y,x)));
                set(h,'MarkerSize',3);
                set(h,'MarkerFaceColor','b');
                set(gca,'xlim',[0 time(end)]);
                xlabel('frame, no');
                ylabel('corr. func.');
                grid;
                index = index + 1;
            end
        end
        figure(2)   % plot smoothed corr. coef.
        clf;
        index = 1;
        for y=1:ver_no
            for x=1:hor_no
                subplot(ver_no,hor_no,index);
                h=plot(time,squeeze(smooth_corr(y,x,:,1)),'o-',time,squeeze(smooth_corr(y,x,:,manders_sw)),'o-');
                title(['Smoothed, X=' num2str(x) ',Y=' num2str(y) ',size=' num2str(smooth_window)]);
                set(h,'MarkerSize',3);
                set(h,'MarkerFaceColor','b');
                set(gca,'xlim',[0 time(end)]);
                grid;
                xlabel('frame, no');
                ylabel('corr.coef.');
                index = index + 1;
            end
        end
        figure(3)   % plot granularity
        clf;
        index = 1;
        for y=1:ver_no
            for x=1:hor_no
                subplot(ver_no,hor_no,index);
                h=plot(time,squeeze(granularity(y,x,:)),'o-');
                title(['Granularity, X=' num2str(x) ',Y=' num2str(y)]);
                set(h,'MarkerSize',3);
                set(h,'MarkerFaceColor','b');
                set(gca,'xlim',[0 time(end)]);
                grid;
                xlabel('frame, no');
                ylabel('granularity');
                index = index + 1;
            end
        end
    end
    
    smooth_vec = reshape(smooth_corr(:,:,:,1),1,[]); % collect all smoothed coef.
    
    figure(71);
    clf;
    [A,S] = hist(smooth_vec,12);    % A-amplitude, S- value
    A = A./sum(A);  % turn into procentage
    bar(S,A);
    xlabel('Smoothed value');
    ylabel('Fraction, %%');
    dS = S(2)-S(1);
    for pos=1:length(A)
        text(S(pos)-dS/3,A(pos)+.02,sprintf('%.3f',A(pos)),'FontSize',12);
    end
    h1 = gca;
    set(h1,'XTick',double(uint16(round(S*100)))/100);
    set(h1,'XLim',[0 max(S)+.01]);
    h2 = axes('Position',get(h1,'Position'));
    plot(S,log10(A),'ko-','LineWidth',1.5,'MarkerFaceColor','r');
    set(h2,'YAxisLocation','right','Color','none','XTickLabel',[])
    set(h2,'XLim',get(h1,'XLim'),'Layer','top')
    %set(h2,'Ylim',[0 max(log10(A))]);
    ylabel('Log10(Fraction)');
    title('Grid run smoothed corr.coef.');
    grid;
end
end