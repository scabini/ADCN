function [li, lf] = automaticThresholds(path, pathOUT, covering, opt)
% automaticThresholds: takes a string "path" which contains the set of training
% shape-images to calculate the automatic threshold range, according to the
% work (Scabini, Leonardo FS, et al. "Angular Descriptors of Complex 
% Networks: a novel approach for boundary shape analysis." Expert Systems 
% with Applications (2017))
% 
% author: Leonardo Scabini
%
% Usage: [li, lf] = evaluateEdges('path/images/', 'path/output/', 0.14, 'string defining the configuration used')
%   Saves in 'path/output/' the mean and standard deviation of the Complex 
%   Network edges for all images in 'path/images/'. The third parameter 
%   is the alpha rate, according to the paper. The last parameter is
%   a complemention to the file name.
%
%   Returns [li, lf] that are, respectivelly, the initial and
%       final thresholds according to the paper (see Equations 8 to 10).

    
    file=[pathOUT, opt, 'mean_std.mat'];
     if exist(file, 'file') == 0          
         
        arq1 = dir([path, '*.jpg']); 
        arq2 = dir([path, '*.png']);
        arq3 = dir([path, '*.bmp']);
        arq4 = dir([path, '*.tif']); 
        arq = [arq1; arq2; arq3; arq4];
         
        mean=0;
        qtd=0;
        tic();
        for i=1 : length(arq)  
            path2= strcat(path, arq(i).name);
            img=imread(path2);

            if size(img,3) >= 3
                img = rgb2gray(img(:,:,1:3));            
            end

            %disp(arq(i).name);
            img = im2uint8(img);
            [w,h]=size(img);
            pixels= [];
            c=1;
            for x=1:w
               for y=1:h
                   if(img(x,y)>230)
                       pixels(c, 1)=x;
                       pixels(c, 2)=y;
                       c=c+1;
                   end
               end
            end

            network=pdist2(pixels, pixels);
            network= network/max(max(network));
            mean= mean + sum(sum(network));
            qtd=qtd+ ((length(pixels)^2)-length(pixels));

        end
        std=0;
        mean= mean/qtd;


        for i=1 : length(arq)
            path2= strcat(path, arq(i).name);
            img=imread(path2);

            if size(img,3) >= 3
                img = rgb2gray(img(:,:,1:3));            
            end

            %disp(arq(i).name);
            img = im2uint8(img);
            [w,h]=size(img);
            pixels= [];
            c=1;
            for x=1:w
               for y=1:h
                   if(img(x,y)>230)
                       pixels(c, 1)=x;
                       pixels(c, 2)=y;
                       c=c+1;
                   end
               end
            end

            network=pdist2(pixels, pixels);
            network= network/max(max(network));

            [w,h]=size(network);
            for x=1:w
               for y=1:h
                   if( x~=y)
                       std= std+ (network(x,y) - mean)^2;
                   end
               end
            end    
        end    

        std=sqrt(std/(qtd-1));    
    %     disp(mean);
    %     disp(std);

        save(file, 'mean', 'std');
                      
     else
         load(file, 'mean', 'std');
    end
    li = max(mean - (covering*std),0.025);
    lf = min(mean + (covering*std),1);
toc();
end
    
