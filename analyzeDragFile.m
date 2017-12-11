function [fpars,t,strain,F,dsPts,vel]=analyzeDragFile(fold,fname,FTfreq)
%fpars = params from files [type,strain, sys width,del,version
%time in seconds
%strain, unitless
%F in newtons


% fold='A:\2DSmartData\entangledData\StretchON';
% fname='Stretch_1_SD_65_H_10.5_del_4_v_1.csv';

% ftFreq=1000;
ft=importdata(fullfile(fold,fname));
[t_op,q_op]= getOptiData(fullfile(fold,['OPTI_',fname]));
 
t=[1:length(ft(:,2))]'./FTfreq;
F=ft(:,2);%y+ is backwards

%fix timing between scripts optitrack starts slightly first
dd=t_op(end)-t(end);
%find larger one
if dd>0 %op runs longer
%cut beginning off op
dd_ind=find(abs(dd)<t_op,1,'first');
t_op=t_op(dd_ind:end)-t_op(dd_ind);
q_op=q_op(dd_ind:end)-q_op(dd_ind);
else %ft runs longer
dd_ind=find(abs(dd)<t,1,'first');
t=t(dd_ind:end)-t(dd_ind);
F=F(dd_ind:end)-F(dd_ind);
end
% dd_ind=find(dd<t_op,1,'first');
% t_op=t_op(dd_ind:end)-t_op(dd_ind);
% q_op=q_op(dd_ind:end);

%interpolate opti data to length of FT data
q1=interp1(t_op,q_op,t,'linear','extrap');
% strain=[q1/chainLen]';
strain=q1;
[~,fpars]=parseFileNames(fname);
fpars(2)=fpars(2)/1000; %put strain in meters
fpars(3)=fpars(3)/100;%put sys width in meters

dsPts=zeros(fpars(6)*4,3); %time1,strain1,idx1
fig=figure(1232);
h=plot(t,strain);
[dsPts(:,1),dsPts(:,2),~,dsPts(:,3)]=MagnetGInput(h,fpars(6)*4,1);

if ~isempty(find(isnan(strain), 1))
    id=find(isnan(strain),1);
    prevVal=strain(id-1);
    strain(id-1:end)=prevVal;
    pts('error in:',fullfile(fold,fname));
end
 %get indices between first two points
ptSpan=dsPts(1:2,3);
d=diff(ptSpan)/4;
%get middle range of points
ptSpan=[ptSpan(1)+floor(d),ptSpan(1)+2*floor(d)];
vel=diff(strain(ptSpan))/diff(t(ptSpan));
close(fig);
%%%%%%%%%%%%%%%%%%%%%%%
