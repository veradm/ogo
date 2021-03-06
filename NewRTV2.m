%==========================================================================
% Experimental new raytracer, with new computation of powerloss
% for ALL transducer element, V2 positions startpoint.
% with FFA distributed rays, with INTERFERENCE
%==========================================================================
clear all;
close all;
GUIO

%figure('Position',[50 0 1383 737]);
%C = imread('img.jpg');
%image(C)

figure('Position',[0 270 500 500],'Name','Rays through the tissue','NumberTitle','off');

% HTE, version JULY, 2016
% generate rays from one transducer element, with "random directions"
% within first (or second or third)lobe of the far field approximation and
% intensity corresponding to far field intensity.
% units: cm, s , kg

%==========================================================================
% Definition of Variables
%
%==========================================================================
%RequiredTotalPower=output.initialpower%100; % watt, set from the Sonalleve
c=output.c%1537*100; % speed of sound in gel, in: cm/s*100
density=output.density%1040e-6; % gel, density in kg/cm^3
Z_gel=c*density; %impedance
fr=output.frequency%1.2e6; %frequency. Do not change.The system works always at this fr
acoeff=output.acoeff%0.0576; % attenuation for pressure, per cm, for gel
alpha=acoeff;

omega=2*pi*fr;
k_gel=omega/c; % unit: m^-1 , wavenumber for gel
radius=0.35; % transducer diameter =7 mm, radius=3.5 mm=0.35 cm
FocalLength=output.distance; % 14 cm
Area=pi*radius^2; % area of transducer
ka_gel=k_gel*radius; %ka for gel

c_oil=1380*100;
k_oil=omega/c_oil;
ka_oil=k_oil*radius;

% first 3 zeros of besselj(1,x)=J1(x):
r1=3.8317;
r2=7.0156;
r3=10.1735;

% SELECT LOBES TO INCLUDE:
sin_theta_max=r1/(ka_oil*4); % smaller, only for shape of focal point
theta_max=asin(sin_theta_max);
cos_theta_max=sqrt(1-sin_theta_max^2);
AA=1-cos_theta_max;
fprintf('all transducer elements, thetamax= %7.3f degrees\n',asin(sin_theta_max)*180/pi);
fprintf('bundle diameter at 14 cm =%7.3f cm\n',2*14*sin_theta_max);

% compute the fraction of the power that an individual transducer element
% radiates between 0 and theta_max. 
% We need this when we scale the poweroutput.distance
% produced at the end

f=@(theta) sin(theta).*(2*besselj(1,ka_oil*sin(theta))./(ka_oil*sin(theta))).^2;
IntTot=quad(f,0.00000001,pi/2); % integral over theta from 0 to pi/2
IntRestr=quad(f,0.00000001,theta_max);
powerfr=IntRestr/IntTot;
fprintf('fraction of total power within theta_max %6.4f \n',powerfr);

I_init     = 1; % DO NOT CHANGE !!!
Ptot=0;
%Nrays=1 % nr of rays PER transducer element.First work with one, then with 30000
%==========================================================================
% Definition of the table region. Each point is the centre of a cube
%==========================================================================
xmin =-2; %startpoint(1)+ FocalLength-2;  % cm
xmax = 2; %startpoint(1)+ FocalLength+2;  % cm
ymin=-0.5; %-2; % cm
ymax= 0.5; % cm
zmin=-0.5; % cm
zmax= 0.5; % cm
% ASSUMPTION: xmin<xmax, ymin<ymax, zmin<zmax
for Nrays=[output.nrays,1];%30000
    
Nx=101; % nr of steps in x direction
Ny=51;
Nz=51;
dx=(xmax-xmin)/Nx;
dy=(ymax-ymin)/Ny;
dz=(zmax-zmin)/Nz;
fprintf('dx= %6.3f, dy= %6.3f, dz= %6.3f cm\n',dx,dy,dz);
xx=xmin-dx/2+[1:Nx]*dx; % x of cube centers
yy=ymin-dy/2+[1:Ny]*dy; % y of cube centers
zz=zmin-dz/2+[1:Nz]*dz; % z of cube centers
xxb=xmin+[0:Nx]*dx; % x of cube boundaries
yyb=ymin+[0:Ny]*dy; % x of cube boundaries
zzb=zmin+[0:Nz]*dz; % x of cube boundaries
Pressure=zeros(Nx,Ny,Nz); % Table for complex pressure
%TransPos contains the coordinates of the transducer elements
TransPos = TransPosV2(); Focusd=14;

xTrd = TransPos.x -Focusd; % unit cm
yTrd = TransPos.y;
zTrd = TransPos.z;
Ntrd= length(xTrd); % nr of transducers
Nraystot=Nrays*Ntrd;
Nraysmissing=0;
Nrayshit=0;
plotfraction=1000/Nraystot; % plot in total about 1000 rays

fprintf('number of rays per transducer el = %d\n',Nrays);
fprintf('total nr of rays = %d\n',Nraystot);
%===========================================================
% Generation of the rays
%===========================================================
for trd = 1:Ntrd % loop over all transducer elements
    if mod(trd,10)==0
        fprintf('trans el %3d of %3d\n', trd,Ntrd);
    end;
    Ptrd=0;
    % Definition of the 3D matrices to be filled
    %
    %
    PowerLossOneEl=zeros(Nx,Ny,Nz);
    PhaseOneEl=zeros(Nx,Ny,Nz);
    NraysOneEl=zeros(Nx,Ny,Nz);
    startpoint=[xTrd(trd);yTrd(trd);zTrd(trd)];
    normal =-startpoint/norm(startpoint);
    
    v2=[-normal(3);0;normal(1)]; % a vector perpendicular to the normal, so in the plane of the transd.
    if norm(v2)<1e-12
        input('ERROR, vector v2 vanishes');
        
    end;
    v2norm=v2/norm(v2); % normalised v2
    v3=cross(v2norm,normal); % another vector in the plane of the transd
    
    %initialize structure.
    ray_gel=struct('start',[],'I0',0,'phase',0,'material',0,'Vray',[],'end',[]) ;
    
    scatter3(startpoint(1),startpoint(2),startpoint(3), 40, 'red', 'filled');
    hold on;
    for nray=1: Nrays
        % The generation of rays follows this probability (don't go into details here):
        % generate actual ray direction V_ray:
        % generate angle theta:
        % pdf(theta)dtheta = prop to surface of spherical cap with inner radius sin(theta) and width dtheta
        % so pdf(theta)=A sin(theta)
        % so \int_0^thetamax pdf(theta)= A (1-cos(thetamax)) =1, which implies A=1/(1-cos(thetamax)),
        % which implies pdf(theta)= sin(theta/(1-cos(thetamax));
        % Then* Cumpdf(a)=Pr(theta<a) =(1-cos(a))/(1-cos(thetamax)),
        % then Cumpdf(a)=Pr(1-cos(theta)<1-cos(a))
        % then Cumpdf(a)= Pr[(1-cos(theta))/(1-cos(thetamax)) <(1-cos(a))/(1-cos(thetamax))] =(1-cos(a))/(1-cos(thetamax))
        % So Pr[(1-cos(theta))/(1-cos(thetamax)) <b] =b, for all b in (0,1);
        % So (1-cos(theta))/(1-cos(thetamax)) has a uniform distribution on (0,1)
        % with AA=1-cos(thetamax) this means that theta can be generated by:
        r=rand;
        theta=acos(1-AA*r);
        %  other angle (azimuth)
        phi=2*pi*rand(1);
        Rtheta=tan(theta);
        
        [ray_gel]=Update_rays(theta,phi,startpoint,I_init,k_oil,normal,v2norm,v3,ka_oil);
       
        Vray=normal+Rtheta*(cos(phi)*v2norm+sin(phi)*v3);
        Vray=Vray/norm(Vray);
        
        Vray_gel=ray_gel.Vray/norm(ray_gel.Vray);
        startpoint_gel=ray_gel.start;
        
        % ray with init in startpoint and direction Vray (=normalized)
        B=ka_oil*sin(theta);
        if B==0
            Scaling=1;
        else
            Scaling= (2*besselj(1,B)/B)^2;
        end;
        % scaled power for this ray:
        I0=I_init*Scaling;
        % ray with init in startpoin, direction Vray (=normalized) and power % I0;
        Ptrd=Ptrd+I0; % total emitted power in rays, unit: watt, important for the scaling at the end
        
        
        %==========================================================================
        % Check if a ray intersects a cube
        % remember that each point of the grid is the centre of a cube!
        % you don't have to go into the details in this part of the code,just know
        % that:
        % 1) lambda_1= is the distance from the start point of a ray at which a ray intersect a cube (enter in
        % the cube)
        % 2) lambda_2= is the distance from the start point of a ray at which a ray leaves the cube
        % 3) lambda_12= is the distance from the start point of a ray (in between
        % lambda_1 and lambda_2 -> so inside the cube) at which I calculate the
        % phase
        %
        %==========================================================================
        % Generate lambda_x, the series of lambdas such that
        % startpoint+lambda_x*Vray crosses a x-boundary between two cubes
        
        if  startpoint_gel(1)<xmin
            if Vray_gel(1)>0
                lambda_x=(xxb-startpoint_gel(1))/Vray_gel(1); % all positive elements
            else % Vray(1)<=0, ray cannot reach table region
                lambda_x=inf;
            end
        elseif startpoint_gel(1)>xmax
            if Vray_gel(1)<0
                lambda_x=(xxb-startpoint_gel(1))/Vray_gel(1);
                % all positive elements, BUT: decreasing sequence
                lambda_x=lambda_x(end:-1:1); % reverse
            else % Vray(1)>=0, ray cannot reach table region
                lambda_x=inf;
            end
        else % xmin<= startpoint(1)<= xmax, start inside table region
            if Vray_gel(1)>0
                lambda_x=(xxb-startpoint_gel(1))/Vray_gel(1); % may contain pos and neg values
                lambda_x=lambda_x(lambda_x>=0); % no neg values
                lambda_x=[0,lambda_x]; % add lambda=0, doubles will be removed later on
            elseif Vray_gel(1)<0
                lambda_x=(xxb-startpoint_gel(1))/Vray_gel(1); % may contain pos and neg values
                lambda_x=lambda_x(lambda_x>=0); % no neg values, BUT decreasing sequence
                lambda_x=lambda_x(end:-1:1); % reverse
                lambda_x=[0,lambda_x]; % add lambda=0, doubles will be removed later
            else % Vray(1) ==0
                lambda_x=0;
            end;
        end;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if lambda_x(1)<inf % ray may pass through table region
            % Generate lambda_y, the series of lambdas such that
            % startpoint+lambda_y*Vray crosses a y-boundary between two cubes
            if  startpoint_gel(2)<ymin
                if Vray_gel(2)>0
                    lambda_y=(yyb-startpoint_gel(2))/Vray_gel(2); % all positive elements
                else % Vray(2)<=0, ray cannot reach table region
                    lambda_y=inf;
                end
            elseif startpoint_gel(2)>ymax
                if Vray_gel(2)<0
                    lambda_y=(yyb-startpoint_gel(2))/Vray_gel(2);
                    % all positive elements, BUT decreasing sequence
                    lambda_y=lambda_y(end:-1:1); %reverse
                else % Vray(2)>=0, ray cannot reach table region
                    lambda_y=inf;
                end
            else % ymin<= startpoint(2)<= ymax, start inside table region
                if Vray_gel(2)>0
                    lambda_y=(yyb-startpoint_gel(2))/Vray_gel(2); % may contain pos and neg values
                    lambda_y=lambda_y(lambda_y>=0); % no neg values
                    lambda_y=[0,lambda_y]; % add lambda=0, doubles will be removed later on
                elseif Vray_gel(2)<0
                    lambda_y=(yyb-startpoint_gel(2))/Vray_gel(2); % may contain pos and neg values
                    lambda_y=lambda_y(lambda_y>=0); % no neg values, BUT decreasing sequence
                    lambda_y=lambda_y(end:-1:1); % reverse
                    lambda_y=[0,lambda_y];% add lambda=0, doubles will be removed later
                else % Vray(2) ==0
                    lambda_y=0;
                end;
            end;
        else
            lambda_y=inf; % lambda_x(1)=inf, so ray does not pass through table region anyway
        end;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if lambda_x(1)<inf && lambda_y(1)<inf % ray may pass through table region
            % Generate lambda_z, the seies of lambdas such that
            % startpoint+lambda_z*Vray crosses a z-boundary between two cubes
            if  startpoint_gel(3)<zmin
                if Vray_gel(3)>0
                    lambda_z=(zzb-startpoint_gel(3))/Vray_gel(3); % all positive elements
                else % Vray(3)<=0, ray cannot reach table region
                    lambda_z=inf;
                end
            elseif startpoint_gel(3)>zmax
                if Vray_gel(3)<0
                    lambda_z=(zzb-startpoint_gel(3))/Vray_gel(3);
                    % all positive elements, BUT decreasing sequence
                    lambda_z=lambda_z(end:-1:1); % reverse
                else % Vray(2)>=0, ray cannot reach table region
                    lambda_z=inf;
                end
            else % zmin<= startpoint(3)<= zmax, start inside table region
                if Vray_gel(3)>0
                    lambda_z=(zzb-startpoint_gel(3))/Vray_gel(3); % may contain pos and neg values
                    lambda_z=lambda_z(lambda_z>=0); % no neg values
                    lambda_z=[0,lambda_z]; % add lambda=0, doubles will be removed later on
                elseif Vray(3)<0
                    lambda_z=(zzb-startpoint_gel(3))/Vray_gel(3); % may contain pos and neg values
                    lambda_z=lambda_z(lambda_z>=0); % no neg values, BUT decreasing sequence
                    lambda_z=lambda_z(end:-1:1); % reverse
                    lambda_z=[0,lambda_z]; %add lambda=0, doubles will be removed later
                else % Vray(3) ==0
                    lambda_z=0;
                end;
            end;
        else
            lambda_z=inf; % lambda_x(1)=inf or lambda_y(1)=inf,
            % so ray does not pass through table region anyway
        end;
        
        % now process the three lambda sequences
        Min_lambda = max([lambda_x(1),lambda_y(1),lambda_z(1)]);
        Max_lambda = min([lambda_x(end),lambda_y(end),lambda_z(end)]);
        % part of the ray between Min_lambda and Max_lambda is
        % in the table region;
        
        %fprintf('ray %d, Min_lambda= %7.3f, max_lambda=%7.3f\n',nray,Min_lambda,Max_lambda);
        
        
        if Min_lambda<Max_lambda %ray passes through table region
            Nrayshit=Nrayshit+1;
            P_in=startpoint_gel+Min_lambda*Vray_gel;
            P_out=startpoint_gel+Max_lambda*Vray_gel;
            
            if rand<plotfraction % plot only a part of the rays
                % plot in green the part from startpoint to boundary with table region:
                plot3([startpoint_gel(1),P_in(1)],[startpoint_gel(2),P_in(2)],[startpoint_gel(3),P_in(3)],'-r');
                plot3([startpoint(1),startpoint_gel(1)],[startpoint(2),startpoint_gel(2)],[startpoint(3),startpoint_gel(3)],'-g');
                % plot in blue the part in table region:
                p=patch([-6 -6 -6 -6], [8 8 -8 -8], [-8 8 8 -8],'black');
                set(p,'facealpha',0.5);
                plot3([P_in(1),P_out(1)],[P_in(2),P_out(2)],[P_in(3),P_out(3)],'-b');
            end;
            
            lambda_x=lambda_x(Min_lambda<=lambda_x);
            lambda_x_restr=lambda_x(lambda_x<=Max_lambda);
            lambda_y=lambda_y(Min_lambda<=lambda_y);
            lambda_y_restr=lambda_y(lambda_y<=Max_lambda);
            lambda_z=lambda_z(Min_lambda<=lambda_z);
            lambda_z_restr=lambda_z(lambda_z<=Max_lambda);
            lambda_interesting=unique(sort([lambda_x_restr,lambda_y_restr,lambda_z_restr]));
            % when the intersections with the cubes are detected, three 3D matrix are filled
            for n=1:length(lambda_interesting)-1
                lambda_1= lambda_interesting(n);
                lambda_2= lambda_interesting(n+1);
                lambda_12=(lambda_1+lambda_2)/2;
                ind=floor((startpoint_gel+lambda_12*Vray_gel-[xmin;ymin;zmin])./[dx;dy;dz])+1;
                %==================================================================
                % at this point we found all my lambda_1, lambda_2 and lambda_12
                %==================================================================
                % Important part:
                % remember that each point of the gridsize is the centre of
                % a cube!
                % PowerLossOneEl: 3D matrix which at each point cointains
                % the sum of the power loss of all rays crossing the cube
                % PhaseOneEl: 3D matrix which at each point cointains
                % the sum of the Phases of all rays crossing the cube
                % NraysOneEl: at each point counts how many rays have
                % crossed the cube
                
                %==================================================================
                % In the case of processing refracted rays, what matrix/ matrices need
                % to be modified? and how?
                %
                %==================================================================
                PowerLossOneEl(ind(1),ind(2),ind(3))=PowerLossOneEl(ind(1),ind(2),ind(3))+ ...
                    I0*(exp(-2*alpha*lambda_1)-exp(-2*alpha*lambda_2));
                PhaseOneEl(ind(1),ind(2),ind(3))=PhaseOneEl(ind(1),ind(2),ind(3))+k_gel*lambda_12+ray_gel.phase;
                NraysOneEl(ind(1),ind(2),ind(3))=NraysOneEl(ind(1),ind(2),ind(3))+1;
                % take care: PowerLoss must be divided by dx*dy*dz to obtain power density
                % in watt/cm^3
            end;
        else
            Nraysmissing=Nraysmissing+1;
        end;
    end;  % loop over all rays from one trd element
    %
    Ptot=Ptot+Ptrd;
    NraysOneEl=max(NraysOneEl,1); % to avoid division by 0 if no ray passes through the cube
    PhaseOneEl=PhaseOneEl./NraysOneEl; % compute average phase from all rays that pass through this cube
    Pressure= Pressure +sqrt(PowerLossOneEl).*exp(i*PhaseOneEl);  
end; % loop over the transducer elements



PowerLoss=abs(Pressure.^2);
xlabel('x');
ylabel('y');
zlabel('z');
fprintf('number of rays per transducer el = %d\n',Nrays);
fprintf('total nr of rays = %d\n',Nraystot)
fprintf('of which %d did pass through the table region and %d did NOT pass through the table region\n',Nrayshit,Nraysmissing);
passed=100*Nrayshit/Nraystot; missed=100*Nraysmissing/Nraystot;
fprintf('So %6.2f percent did pass through the table region and %6.2f percent did not\n',passed,missed);

fprintf('using all transducer elements, thetamax= %7.3f degrees\n',asin(sin_theta_max)*180/pi);
fprintf('bundle diameter at 14 cm =%7.3f cm\n',2*14*sin_theta_max);


% All necessary scalings of the power.
% RequiredTotalPower is the total acoustic power for the transducer
% RequiredTotalPower*powerfraction is the part of the total power, emitted
% within theta_max, Ptot is te actual emitted power by the rays within
% theta_max. Therefore we scale by PowerCorrection, and divide by dx*dy*dz to
% obtain densities

PowerCorrectionFactor=powerfr*RequiredTotalPower/Ptot;
PowerLoss=PowerLoss*(PowerCorrectionFactor/(dx*dy*dz));
Ptable=sum(sum(sum(PowerLoss)))*dx*dy*dz;
fprintf('total emitted power %7.4f watt\n',RequiredTotalPower);
fprintf('total power in the table %7.4f  watt\n',Ptable);
MaxP=max(max(max(PowerLoss)));
fprintf('max heat prod %7.3f  watt/cm^3\n', MaxP);

%==========================================================================
if Nrays<30000;
    [rx,cy,vz]=ind2sub(size(PowerLoss),find(PowerLoss==MaxP))
    xmid=xmin+(0.5+cy)*dx;
    xmin=xmid-1
    xmax=xmid+1
end
fprintf('first initial gues loop complete, starting the accurate loop now')
end; % loop over different NRays

%==========================================================================
% Visualization!
%==========================================================================
% plot for fixed z=z0 lateral plane
z0=0;
[zmin,iz]=min(abs(zz-z0));
z1=zz(iz);
fprintf('nearest occuring height value z=%7.3f\n',z1);
Powerz=squeeze(PowerLoss(:,:,iz));
[x3,y3]=meshgrid(xx,yy);
figure('Position',[500 270 500 500],'Name','Heatproduction in x- and y-direction','NumberTitle','off');
surfc(x3,y3,Powerz');
xlabel('x (cm)');
ylabel('y (cm)');
st2=['heat production at z=',num2str(z1),' in watt/cm^3'];
title(st2);

% plot for fixed x=x0 coronal plane
x0=0;
[xmin,ix]=min(abs(xx-x0));
x1=xx(ix);
fprintf('nearest occuring x value x=%7.3f\n',x1);
Powerx=squeeze(PowerLoss(ix,:,:));
[x4,y4]=meshgrid(yy,zz);
figure('Position',[1000 270 500 500],'Name','Heatproduction in y- and z-direction','NumberTitle','off');
surfc(x4,y4,Powerx');
xlabel('y (cm)');
ylabel('z (cm)');
st3=['heat production at x=',num2str(x1),' in watt/cm^3'];
title(st3);

%==========================================================================

figure('Position',[0 0 500 200],'Name','Description','NumberTitle','off')
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
title('Description');
a1 = '  The phase of the rays causes the rays to beam to a focal point.';
a2 = '  Within a table region around the focal point, the intensity of all rays';
a3 = '  intersecting the box is calculated.';
a1 = [a1 char(10) a2 char(10) a3];
text(0,.6,a1,'FontSize',11);
   

figure('Position',[500 0 500 200],'Name','Description','NumberTitle','off')
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
b1 = '  In the figure above we can see the heatproduction in x- and ';
b2 = '  y-direction The heatproduction is given in the Watt/cm^3. By closing ' ;
b3 = '  the figures that are shown, the parameter values you used are shown';
b1 = [b1 char(10) b2 char(10) b3];
text(0,.6,b1,'FontSize',11);

figure('Position',[1000 0 500 200],'Name','Description','NumberTitle','off')
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
title('Description');
c1 = '  In the figure above we can see the heatproduction in y-';
c2 = '  z-direction The heatproduction is given in the Watt/cm^3. By closing ' ;
c3 = '  the figures that are shown, the parameter values you used are shown';
c1 = [c1 char(10) c2 char(10) c3];
text(0,.6,c1,'FontSize',11);
