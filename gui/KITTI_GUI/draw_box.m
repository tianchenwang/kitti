function [ img ] = draw_box( img,tag,xmin_input,ymin_input,xmax_input,ymax_input )
	xmin=ceil(ymin_input);
	ymin=ceil(xmin_input);
	xmax=ceil(ymax_input);
	ymax=ceil(xmax_input);
	if(xmin==0)
		xmin=1;
	elseif(xmax==0)
		xmax=1;
	elseif(ymin==0)
		ymin=1;
	elseif(ymax==0)
		ymax=1;
	end
	if(strcmp(tag,'Car')==1)
		r=0;
		g=255;
		b=0;
	elseif(strcmp(tag,'Misc')==1)
		r=255;
		g=247;
		b=91;
	elseif(strcmp(tag,'Truck')==1)
		r=255;
		g=130;
		b=255;
	end
	
			
	% Car:green, Misc:yellow, Truck:magenta
	img(xmin:xmax,ymin:ymin+1,1)=r;
	img(xmin:xmax,ymax-1:ymax,1)=r;
	img(xmin:xmin+1,ymin:ymax,1)=r;
	img(xmax-1:xmax,ymin:ymax,1)=r;
	img(xmin:xmax,ymin:ymin+1,2)=g;
	img(xmin:xmax,ymax-1:ymax,2)=g;
	img(xmin:xmin+1,ymin:ymax,2)=g;
	img(xmax-1:xmax,ymin:ymax,2)=g;
	img(xmin:xmax,ymin:ymin+1,3)=b;
	img(xmin:xmax,ymax-1:ymax,3)=b;
	img(xmin:xmin+1,ymin:ymax,3)=b;
	img(xmax-1:xmax,ymin:ymax,3)=b;

end

