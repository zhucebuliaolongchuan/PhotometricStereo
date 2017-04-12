% Load dog images
img1 = imread('/dog-png/dog1.png');
img1 = rgb2gray(img1);
img1_scaled = double(img1) ./ 255.0;
img2 = imread('/dog-png/dog2.png');
img2 = rgb2gray(img2);
img2_scaled = double(img2) ./ 255.0;
img3 = imread('/dog-png/dog3.png');
img3 = rgb2gray(img3);
img3_scaled = double(img3) ./ 255.0;
img4 = imread('/dog-png/dog4.png');
img4 = rgb2gray(img4);
img4_scaled = double(img4) ./ 255.0;

% View Matrix from dog-png
v1 = [16, 19, 30];
v2 = [13, 16, 30];
v3 = [-17, 10.5, 26.5];
v4 = [9, -25, 4];
V= [v1 ./ norm(v1); v2 ./ norm(v2); v3 ./ norm(v3); v4 ./ norm(v4)];

w = 400;
h = 400;

albedo = zeros(h, w);
normal_x = zeros(h, w);
normal_y = zeros(h, w);
normal_z = zeros(h, w);

height_map = zeros(h, w);

dzdx = zeros(h, w);
dzdy = zeros(h, w);

for x = 1:1:w
    for y = 1:1:h
        i_matrix = [img1_scaled(x, y), img2_scaled(x, y), img3_scaled(x, y), img4_scaled(x, y)];
        Ti = transpose(i_matrix .^ 2);
        T = zeros(4, 4);
        for k = 1:1:4
            T(k, k) = i_matrix(k);
        end
        % Here might be a problem to calculate g(x, y)
        if Ti == zeros(4, 1)
            albedo(x, y) = 0;
            normal_x(x, y) = 0;
            normal_y(x, y) = 0;
            normal_z(x, y) = 0;
            p = 0;
            q = 0;
         else
            g = pinv(T * V) * Ti;
            albedo(x, y) = norm(g);
            % calculate the albedo and normal
            normal = g ./ albedo(x, y);
            % Store the normals, 3 components
            normal_x(x, y) = normal(1);
            normal_y(x, y) = normal(2);
            normal_z(x, y) = normal(3);
            % calculate p and q
            p = normal(1) / normal(3);
            q = normal(2) / normal(3);
        end
        dzdx(x, y) = p;
        dzdy(x, y) = q;
        % integrate the height map
        if x - 1 >= 1
            height_map(x, y) = height_map(x - 1, y) + q;
        else
            height_map(x, y) = q;
        end
        if y - 1>= 1
            height_map(x, y) = height_map(x, y - 1) + p;
        else
            height_map(x, y) = p;
        end
    end
end

% Create New Shaded Image
% light_source = [1, 1, 1];
% new_shaded_image = zeros(h, w);
% 
% for x=1:1:w
%     for y=1:1:h
%         s = transpose(light_source ./ norm(light_source));
%         normal = [normal_x(x, y), normal_y(x, y), normal_z(x, y)];
%         new_shaded_image(x, y) = albedo(x, y) * dot(s, normal);
%     end
% end
% 
% figure(1), title('new shaded image'), hold on;
% imshow(new_shaded_image);

% Calculate the dpdy - dqdx for each pixel
% checked = ones(h, w);
% for x = 1:1:h - 1
%     for y = 1:1:w - 1
%         checked(x, y) = fix((dzdx(x, y + 1) - dzdx(x, y)) - (dzdy(x + 1, y) - dzdy(x, y)) ^ 2);
%     end
% end

% An implementation of Frankot and Chellappa'a algorithm for constructing
% an integrable surface from gradient information.
% Bonus part

% [rows, cols] = size(dzdx);
% 
% [wx, wy] = meshgrid(([1 : cols] - fix(cols / 2 + 1)) / (cols - mod(cols, 2)), ...
%                     ([1 : rows] - fix(rows / 2 + 1)) / (rows - mod(rows, 2)));
%           
% wx = ifftshift(wx);  wy = ifftshift(wy);
% 
% DZDX = fft2(dzdx);
% DZDY = fft2(dzdy);
% 
% Z = (-j * wx .* DZDX - j * wy .* DZDY) ./ (wx .^ 2 + wy .^ 2 + eps);
% 
% z = real(ifft2(Z));
% 
% figure(7);
% [x, y] = meshgrid(1:1:rows, 1:1:cols);
% mesh(x, y, z);
% figure(8);
% surf(x, y, z, 'EdgeColor', 'none');
% camlight left;
% lighting phong;

% height_map_greyscaled = (height_map(:) - min(height_map(:)))/ (max(height_map(:)) - min(height_map(:)));
% height_map_greyscaled = reshape(height_map_greyscaled, w, h);

% % show the three components of surface normal vector
% figure(1), title('surface normal vector');
% subplot(1, 3, 1), title('normal X'), hold on;
% imshow(normal_x);
% subplot(1, 3, 2), title('normal Y'), hold on;
% imshow(normal_y);
% subplot(1, 3, 3), title('normal Z'), hold on;
% imshow(normal_z);
% 
% Show the albedo map
% figure(2), title('albedo map'), hold on;
% imshow(albedo);
% 
% Show the needle map(2D vectors on the 400 * 400 grid)
% figure(3), title('2D Vector Map'), hold on;
% [x1, y1] = meshgrid(w:-1:1, h:-1:1);
% quiver(x1, y1, normal_x, normal_y);
% axis tight;
% axis square;
% hold off;

% % Show the mesh grid map
% figure(4), title('Mesh Grid Map'), hold on;
% [x2, y2] = meshgrid(1:1:w, 1:1:h);
% mesh(x2, y2, height_map);

% %  Show the height map
% figure(5), title('Surf Height Map'), hold on;
% [x3, y3] = meshgrid(1:1:w, 1:1:h);
% surf(x3, y3, height_map, 'EdgeColor', 'none');
% camlight left;
% lighting phong;

% Show the greyscaled height map
% figure(6), title('Greyscaled Height Map'), hold on;
% imshow(height_map_greyscaled);