function [rays, ptrd] = Update_rays(theta, phi, startpoint,I_init , k, normal,v2norm,v3,ka) 
%UNTITLED2 Summary of this function goes here
%   Here we have to treat 2 cases:
% 1) interface loss-less gel
% 2) interface gel-bone
%  The results is a collection of struct with:
% 1) start, direction, end, material, I0 , PowerProduced,rays, phase
% (initial phase of the ray refracted!)
%



%=====================================
% Case 1 : the ray till the interface
%=====================================
ray.start=startpoint;
Rtheta=tan(theta);
Vray=normal+Rtheta*(cos(phi)*v2norm+sin(phi)*v3);
ray.Vray=Vray/norm(Vray);
t= (-6-ray.start(1))/ray.Vray(1); % x=-6cm is the interface lossless - gel 
ray.end= [-6; t*ray.Vray(2)+ray.start(2);  t*ray.Vray(3)+ray.start(3)]; %here put the x=interface

B=ka*sin(theta);
if B==0
    Scaling=1;
else    
    Scaling= (2*besselj(1,B)/B)^2;
end;    
ray.I0=I_init*Scaling;
ray.phase= k* sqrt((ray.end(1) - ray.start(1))^2 +(ray.end(2) - ray.start(2))^2+(ray.end(3) - ray.start(3))^2);
ray.material=0;

%==========================================================
% Case 2 : the ray from the interface to the end, Refracted
%===========================================================
ray_refracted.start=ray.end;
ray_refracted.I0= ray.I0; 
start=ray_refracted.start;
dir = ray.Vray/norm(ray.Vray);
plane_normal = [1;0;0];
plane_constant=-6;
denominator=dir'*plane_normal;
if abs(denominator)<1e-12
    % ray is parallel to plane, no intersection
    lambdaplane=1e12;
else
    lambdaplane= (plane_constant-start'*plane_normal)/denominator;
end;
if denominator>0
    nn=-plane_normal;
else
    nn=plane_normal;
end;

[refr, v_out]=refraction0(ray.Vray,nn,1380,1537);
ray_refracted.phase= ray.phase; 
ray_refracted.material= 1;
ray_refracted.Vray=v_out/norm(v_out);
%ray_refracted.end=[2; ray_refracted.Vray(2)+ray_refracted.start(2);  ray_refracted.Vray(3)+ray_refracted.start(3)];
ptrd=I_init*Scaling;
t= (2-ray_refracted.start(1))/ray_refracted.Vray(1);
ray_refracted.end= [2; t*ray_refracted.Vray(2)+ray_refracted.start(2);  t*ray_refracted.Vray(3)+ray_refracted.start(3)]; %here put the x=end point
rays=ray_refracted;
%rays=[ray,ray_refracted];

end

