classdef TSST < handle
    %HST base class for temporal-spatial-spectral tensor
    %   subclasses should implement a hyperspectral tensor of a specific
    %   dimensionality.
    
    % Constant values in the TSST class
    properties (Constant)
        
        Dx = 1;     % x dimension
        Dy = 2;     % y dimension
        Dl = 3;     % spectral dimension
        Dm = 4;     % spectral order dimension
        Dp = 5;    % spectral angle dimension
        Dt = 6;     % time dimension
        Di = 7;     % x stride dimension
        Dj = 8;     % y stride dimension
        Dk = 9;     % spectral stride dimension
        Dn = 10;     % time stride dimension
        
        nD = 10;    % Number of dimensions
        
    end
    
    properties
        
        
        % Main tensor memory storage location
        T;
        
        % Cell arrays containing vectors of physical coordinate for each
        % corresponding stride index
        x;      % x coordinates
        y;      % y coordinates
        l;      % Spectral coordinates
        m;      % Spectral order value
        p;      % Spectral angle value
        t;      % Time coordinates
        
        % Storage space for the width the stride in each dimension.
        stride;
        
        % Data origin information
        %         source;      % The observatory responsible for the observation
        %         instrument;  % The instrument responsible for the observation
        %         keywords;       % keywords struct provided by fits file.
        
    end
    
    methods
        
        % Constructor for TSST class
        function S = TSST(Nx, Ny, Nl, Nm, Np, Nt, Ni, Nj, Nk, Nn)
            
            % Allocate memory for the tensor
            S.T = zeros(Nx, Ny, Nl, Nm, Np, Nt, Ni, Nj, Nk, Nn);
            
            % Allocate memory for the coordinate vector
            S.x = zeros(Nx, Ni);
            S.y = zeros(Ny, Nj);
            S.l = zeros(Nl, Nk);
            S.m = zeros(Nm, 1);
            S.p = zeros(Np, 1);
            S.t = cell(Nt, Nn);
            
            
            
        end
        
        % Displays a spatial image
        function [] = disp_xy_slice(S, l, m, p, t, i, j, k, n)
            
            img = S.T(:,:, l, m, p, t, i, j, k, n);
            
%             img_min = min(img(:));
%             img = img - img_min;
            img = sqrt(sqrt(img));
            img_min = min(img(:));
            img_max = max(img(:));
           
            imshow(img, [img_min, img_max]);
            
        end
        
        % Displays a time-sequence of images
        function disp_xyt_cube(S, l, m, p, i, j, k, n)
            
            
           
            % Select the appropriate dimension
            cube = squeeze(S.T(:,:, l, m, p, :));

            % Find the max and min of the cube
            cube_n = min(min(cube, [], 1), [], 2);
            cube_x = max(max(cube, [], 1), [], 2);
            
            % Rescale the cube into bytes
            cube = uint8(255 * (cube - cube_n) ./ (cube_x - cube_n));
           
            % Display the cube
            implay(cube);
            
        end
        
        % Slices up the original input tensor into separate chunks of size
        % given by the stride in each dimension
        function [] = slice_xy(S, stride_x, stride_y)
            
            % Find the size in each dimension
            sz = ones(1,S.nD);
            cD = ndims(S.T);
            sz(1:cD) = size(S.T);
            
            % Check that the current size is evenly divisible by the stide
            if mod(sz(S.Dx), stride_x) ~= 0 || mod(sz(S.Dy), stride_y) ~= 0
               disp('Stride must be evenly divisible by the size') 
               return
            elseif stride_x > sz(S.Dx) || stride_y > sz(S.Dy)
                disp('Stride must be smaller than current size')
                return
            end
            
            % Find the number of chunks
            Nx = sz(S.Dx) / stride_x;
            Ny = sz(S.Dy) / stride_y;
            
            % Allocate extra dimension using resize
            S.T = reshape(S.T, stride_x, Nx, stride_y, Ny, sz(S.Dl), sz(S.Dm), sz(S.Dp), sz(S.Dt), sz(S.Di), sz(S.Dj), sz(S.Dk), sz(S.Dn));          
            
            % Permute the extra dimensions to absorb into stride dimension
            S.T = permute(S.T, [1, 3, 5, 6, 7, 8, 2, 9, 4, 10, 11, 12]);
            
            % Resize to absorb extra dimension into stride dimension
            S.T = reshape(S.T, stride_x, stride_y, sz(S.Dl), sz(S.Dm), sz(S.Dp), sz(S.Dt), Nx * sz(S.Di), Ny * sz(S.Dj), sz(S.Dk), sz(S.Dn));
            
            % Rearrange the coordinate vectors
            S.x = reshape(S.x, stride_x, Nx);
            S.y = reshape(S.y, stride_y, Ny);
            
        end
        
        % Crop a rectangle from the spatial dimensions
        function [] = crop_xy(S, min_x, max_x, min_y, max_y)
           
            % Crop the data
            S.T = S.T(min_x:max_x, min_y:max_y, :, :, :, :, :, :, :, :);
            
            % Crop the coordinate vectors
            S.x = S.x(min_x:max_x, :);
            S.y = S.y(min_y:max_y, :);
            
        end
        
    end
    
    % Static methods for the hyperspectral tensor
    methods (Static)
        
        % Takes a list of fits files and slices them into smaller pieces
        % and saves the result in a new fits file
        function sliced_files = slice_fits(files, new_path, stride)
            
            % Initialize return variable
            sliced_files = [];
            
            % Loop through filenames
            for i = 1:numel(files)
                
                % select the filename
                file = files{i};
                
                % read in parameters from the fits header
                % keywords = fitsinfo(file).PrimaryData.Keywords;
                
                % read in data from fits file
                img = fitsread(file);
                
                % slice image
                cube = HST.slice(img, stride);
                
                % Construct new filename for the sliced image
%                 new_file =
                
                %                 test = squeeze(cube(32+4, :, :));
                %                 imshow(test, [min(test(:)), max(test(:))]);
                
                %                 for i = 1:20
                %                     subplot(4,5,i);
                %                     test = squeeze(cube(512 + i, :, :));
                %                     imshow(test, [min(test(:)), max(test(:))]);
                %                 end
                
            end
            
            sliced_files = [];
            
        end
        
        % Slices a given input image into a cube
        function cube = slice(img, stride)
            
            % Check to see if img is 2-dimensional
            if ~ismatrix(img)
                disp('slice called with non-image');
                cube = [];
                return;
            end
            
            [sz_x, sz_y] = size(img); % Find the size of the image
            
            % find the number of sub-images given the stride
            n_x = int16(sz_x / stride);
            n_y = int16(sz_y / stride);
            
            % Use double loop to slice
            cube = zeros(n_x * n_y, stride, stride);    % initialize cube
            for i = (1:n_x)         % loop along x-dimension
                for j = (i:n_y)     % loop along y-dimension
                    
                    % Find the limits of the subimage
                    x_min = stride * (i - 1) + 1;   % Minimum x pixel
                    x_max = stride * i;             % Maximum x pixel
                    y_min = stride * (j - 1) + 1;   % Minimum y pixel
                    y_max = stride * j;             % Maximum y pixel
                    
                    % Select subimage
                    sub_img = img(x_min : x_max, y_min : y_max);
                    
                    % insert subimage into cube
                    k = sub2ind([n_x, n_y], i, j);
                    cube(k,:,:) = sub_img;
                    
                end
            end
            
        end
        
        
        
    end
    
end

