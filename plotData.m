%************************************************************
%* Fig numbers:
%* 1. force vs time with strain overlay
%* 2. get work from select strain iterations for single run
%* 3. plot single Force vs. Strain
%* 4. get force for 1 side of select strain iterations for single run
%* 5. plot force vs. time for usedS
%* 6. plot force vs. strain for usedS
%* 7. plot force vs. strain for usedS with slope bar
%* 8. plot force vs. strain for usedS with slope bar
%************************************************************
% clearvars -except t
% close all;
clear all;

% maxSpeed= 1.016; %m/s
% pctSpeed=.0173;
% speed=pctSpeed*maxSpeed;

% fold=uigetdir('A:\2DSmartData\entangledData');
fold='A:\RobotArm-CohesiveGM-Rheology\data4';

freq=1000; %hz rate for polling F/T sensor
s=struct;

if ~exist(fullfile(fold,'dataOut.mat'),'file')
    filez=dir2(fullfile(fold,'Stretch*'));
    N=length(filez);
    allFpars=zeros(N,7); % [type,SD,H,del,spd,its,v]
    s=struct;
    
    for i=1:N
        pts(i,'/',N);
        [allFpars(i,:),s(i).t,s(i).strain,s(i).F,s(i).dsPts,s(i).vel]=analyzeDragFile(...
            fold,filez(i).name,freq);
        s(i).name=filez(i).name;
        s(i).fpars=allFpars(i,:);
        [s(i).type,s(i).SD,s(i).H,s(i).del,s(i).spd,s(i).its,s(i).v]=separateVec(allFpars(i,:),1);
        
    end
    save(fullfile(fold,'dataOut.mat'),'s','allFpars');
else
    load(fullfile(fold,'dataOut.mat'));
end
typeTitles={'Inactive Smarticles','Regular Chain','Viscous, open first 2 smarticles',...
    'Elastic, close all smarticles','Fracture On','Stress Avoiding Chain'...
    'Fracture SAC'};
%%%%%%%%%%%%%%%%%%
% strains=[65]/1000;
types=[]; strains=[]; Hs=[]; dels=[]; spds=[]; its=[]; vs=[];
%%%%%%%%%%%%%%%%%%%%%%%%
props={types strains Hs dels spds its vs};

setP1=[];
indcnt=1;
for i=1:length(s)
    cond=1;
    for j=1:length(props)
        
        if ~isempty(props{j})
            if(~any(props{j}==s(i).fpars(j)))
                cond=0;
            end
        end
    end
    if(cond)
        usedS(indcnt)=s(i);
        indcnt=indcnt+1;
    end
end
if ~exist('usedS','var')
    error('No file with specified parameters exists in folder');
end
uN=length(usedS);
fpars=zeros(uN,7);
for i=1:uN
    fpars(i,:)=usedS(i).fpars;
end
[type,SD,H,del,spd,it,v]=separateVec(fpars,1);

showFigs=[1 4];

%% 1. single force vs time with strain overlay
xx=1;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ind=1;
    overlayStrain=1;
    timePts=[1,1]; %iteration to consider as "zero point"
    
    pts('F vs. Strain for ',usedS(ind).name);
    % plot(s(ind).strain,s(ind).F);
    
    time2useS=usedS(ind).dsPts(((timePts(1))*4-3),3);%4 points per iteration
    time2useE=usedS(ind).dsPts(timePts(2)*4-2,3);
    
    pts('F vs. T for ',s(ind).name);
    plot(s(ind).t,s(ind).F);
    maxF=max(s(ind).F);
    maxS=max(s(ind).strain);
    
    if(overlayStrain)
        h=plot(s(ind).t,maxF*s(ind).strain/maxS);
        % text(0.4,0.9,'scaled
        % strain','units','normalized','color',h.Color)'
        set(gca,'colororderindex',4)
        
%         plot first iteration
        timePts=[1,1]; %iteration to consider as "zero point"
        time2useS=usedS(ind).dsPts(((timePts(1))*4-3),3);%4 points per iteration
        time2useE=usedS(ind).dsPts(timePts(2)*4-2,3);
        plot(s(ind).t(time2useS:time2useE),maxF*s(ind).strain(time2useS:time2useE)/maxS,'linewidth',2)
        
        
        timePts=[2,2]; %iteration to consider as "zero point"
        time2useS=usedS(ind).dsPts(((timePts(1))*4-3),3);%4 points per iteration
        time2useE=usedS(ind).dsPts(timePts(2)*4-2,3);
        plot(s(ind).t(time2useS:time2useE),maxF*s(ind).strain(time2useS:time2useE)/maxS,'linewidth',2)
        
        leg=legend({'Force','Scaled Strain','Cycle 1', 'Cycle 2'},...
            'location','south','interpreter','latex');
        
    end
    xlabel('Time (s)','interpreter','latex');
    ylabel('Force (N)','interpreter','latex');
    
    
    
    figText(gcf,18)
    leg.FontSize=12;
end
%% 2. get work from select strain iterations for single run
xx=2;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ind=1;
    timePts=[2,2]; %iteration to consider as "zero point"
    
    pts('F vs. Strain for ',usedS(ind).name);
    % plot(s(ind).strain,s(ind).F);
    
    time2useS=usedS(ind).dsPts(((timePts(1))*4-3),3);%4 points per iteration
    time2useE=usedS(ind).dsPts(timePts(2)*4,3);
    
    x=usedS(ind).strain(time2useS:time2useE);
    y=usedS(ind).F(time2useS:time2useE)';
    
    x=x-x(1);%zero at start iteration
    y=y-y(1);
    
    tArea(i)=trapz(x,y);
    %         A(i)=polyarea([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)]);
    [sm(i),smidx]=max(x);
    
    %     colormapline(x,y,[],jet(100));
    fill([x,x(1)],[y,y(1)],'k','facecolor','c')
    xlabel('Strain');
    ylabel('Force (N)');
    
    text(0.4,0.9,['W=',num2str(tArea,3)],'units','normalized')
    
    xlim([0,inf]);
    figText(gcf,18)
end
%% 3. plot single Force vs. Strain
xx=3;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ind=1;
    
    pts('F vs. Strain for ',s(ind).name);
    % plot(s(ind).strain,s(ind).F);
    colormapline(s(ind).strain,s(ind).F,[],jet(100));
    xlabel('Strain');
    ylabel('Force (N)');
    figText(gcf,18)
end
%% 4. get force for 1 side of select strain iterations for single run
xx=4;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ind=1;

    set(gca,'colororderindex',4)
%     timePts=[2,2]; %iteration to consider as "zero point"
    
    pts('F vs. Strain for ',usedS(ind).name);
    % plot(s(ind).strain,s(ind).F);
    
    for(i=1:it(ind))
    timePts=[i,i];
    time2useS=usedS(ind).dsPts(((timePts(1))*4-3),3);%4 points per iteration
    time2useE=usedS(ind).dsPts(timePts(2)*4-2,3);
    
    x=usedS(ind).strain(time2useS:time2useE);
    y=usedS(ind).F(time2useS:time2useE)';
    x=x-x(1);%zero at start iteration
    y=y-y(1);
    x=x*100; %convert to cm
    plot(x,y);
    end
    
    xlabel('Distance (cm)','interpreter','latex');
    ylabel('Drag Force (N)','interpreter','latex');
    
    text(0.1,0.9,['V=',num2str(usedS(ind).vel*100,2),'cm/s'],'units','normalized','interpreter','latex')
    leg=legend({'Cycle 1','Cycle 2'},'location','south','interpreter','latex');
    xlim([0,inf]);
    
    figText(gcf,18)
    
    leg.FontSize=12;
end
%% 5. force vs time for usedS
xx=5;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ind=1;
    overlayStrain=1;
    for(i=1:uN)
        pts('F vs. T for ',usedS(i).name);
        h(i)=plot(usedS(i).t,usedS(i).F);
        maxF(i)=max(usedS(i).F);
        maxS(i)=max(usedS(i).strain);
        
        if(overlayStrain)
            %             h2(i)=plot(usedS(i).t,maxF(i)*usedS(i).strain/maxS(i),'k','linewidth',4);
            h3(i)=plot(usedS(i).t,maxF(i)*usedS(i).strain/maxS(i),'linewidth',2);
            legend({'Force','Scaled Strain'},'location','south')
            %             set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            set(get(get(h3(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            
        end
    end
    xlabel('time (s)','fontsize',18);
    ylabel('force (N)','fontsize',18);
    
    
    figText(gcf,16)
end
%% 6. plot Force vs. Strain for usedS
xx=6;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    % ind=2;
    tArea=zeros(uN,1);
    strMax=0;
    for(i=1:uN)
        pts('F vs. Strain for ',usedS(i).name);
        %         plot(usedS(i).strain,usedS(i).F);
        colormapline(usedS(i).strain,usedS(i).F,[],jet(100));
        tArea(i)=trapz(usedS(i).strain,usedS(i).F);
        %         A(i)=polyarea([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)]);
        [sm(i),smidx]=max(usedS(i).strain);
        strMax=max(strMax,sm(i));
        
        %         fill([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)],'k','facecolor','c')
    end
    xlabel('Strain');
    ylabel('Force (N)');
    figText(gcf,18)
    axis([0,round(strMax,2),-0.4,0.8]);
    
    figure(100);
    hold on;
    plot([1:5],tArea,'o-','linewidth',2,'markerfacecolor','w');
    xlabel('Speed');
    
    %     plot(sm,tArea,'o-','linewidth',2,'markerfacecolor','w');
    %     xlabel('Strain');
    
    ylabel('Work');
    figText(gcf,18);
end
%% 7. plot force vs. strain for usedS with slope bar
xx=7;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    subplot(1,2,1)
    hold on;
    % ind=2;
    tArea=zeros(uN,1);
    strMax=0;
    legText={};
    
    for(i=uN:-1:1)
        pts('F vs. Strain for ',usedS(i).name);
        h1(i)=plot(usedS(i).strain,usedS(i).F);
        %             colormapline(usedS(i).strain,usedS(i).F,[],jet(100));
        tArea(i)=trapz(usedS(i).strain,usedS(i).F);
        %         A(i)=polyarea([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)]);
        [sm(i),smidx]=max(usedS(i).strain);
        strMax=max(strMax,sm(i));
        
        h2(i)=plot([0,sm(i)],[0,usedS(i).F(smidx)],'k','linewidth',4);
        h3(i)=plot([0,sm(i)],[0,usedS(i).F(smidx)],'color',h1(i).Color,'linewidth',2);
        
        set(get(get(h1(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        %         set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        %         fill([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)],'k','facecolor','c')
        k(i)=usedS(i).F(smidx)/sm(i);
        legText(i)={['k=',num2str(k(i),2)]};
        
    end
    legend(legText);
    xlabel('Strain');
    ylabel('Force (N)');
    figText(gcf,20)
    axis([0,round(strMax,2),-0.4,0.8]);
    
    subplot(1,2,2)
    hold on;
    xlabel('Strain');
    ylabel('k');
    figText(gcf,20);
    plot(sm,k,'-o','linewidth',2,'markerfacecolor','w')
    
end
