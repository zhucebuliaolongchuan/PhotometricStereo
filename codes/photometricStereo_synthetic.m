% % Load synth images
img1 = imread('/synth-images/im1.png');
img1_scaled = double(img1) ./ 255.0;
img2 = imread('/synth-images/im2.png');
img2_scaled = double(img2) ./ 255.0;
img3 = imread('/synth-images/im3.png');
img3_scaled = double(img3) ./ 255.0;
img4 = imread('/synth-images/im4.png');
img4_scaled = double(img4) ./ 255.0;

% View Matrix from synth-images
v1 = [0, 0, 1];
v2 = [-0.2, 0, 1];
v3 = [0.2, 0, 1];
v4 = [0, -0.2, 1];
V = [v1 ./ norm(v1); v2 ./ norm(v2); v3 ./ norm(v3); v4 ./ norm(v4)];

w = 100;
h = 100;

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
        g = (T * V) \ Ti;
        albedo(x, y) = norm(g);
        % calculate the albedo and normal
        normal = g ./ albedo(x, y);
        % Store the normals, 3 components
         normal_x(x, y) = normal(1);
         normal_y(x, y) = normal(2);
         normal_z(x, y) = normal(3);
        % calculate p and q
        p = - normal(1) / normal(3);
        q = - normal(2) / normal(3);
        dzdx(x, y) = p;
        dzdy(x, y) = q;
        % integrate the height map
        if x - 1 >= 1
            height_map(x, y) = height_map(x - 1, y) + q;
        else
            height_map(x, y) = q;
        end
        if y - 1 >= 1
            height_map(x, y) = height_map(x, y - 1) + p;
        else
            height_map(x, y) = p;
        end
    end
end

% % Integrate the height from the middle of the image
% depth_map = zeros(h, w);
% % Middle to top-left
% for x = h/2:(-1):1
%     for y = w/2:(-1):1
%         if x == h / 2 || y == w / 2
%             depth_map(x, y) = height_map(x, y);
%         else
%             depth_map(x, y) = depth_map(x + 1, y + 1) - dzdx(x + 1, y) - dzdy(x, y);
%         end
% %         disp(depth_map(x - 1, y - 1));
% %         disp(dzdy(x, y - 1));
% %         disp(dzdx(x - 1, y));
%     end
% end
% % Middle to top-right
% for x = (h/2):(-1):1
%     for y = (w/2):1:w
%         if x == h / 2 || y == w / 2
%             depth_map(x, y) = height_map(x, y);
%         else
%             depth_map(x, y) = depth_map(x + 1, y - 1) + dzdx(x + 1, y) - dzdy(x, y);
%         end
% %         disp(depth_map(x - 1, y + 1));
%     end
% end
% % Middle to bottom-right
% for x = h/2:1:h
%     for y = w/2:1:w
%         if x == h / 2 || y == w / 2
%             depth_map(x, y) = height_map(x, y);
%         else
%             depth_map(x, y) = depth_map(x - 1, y - 1) + dzdx(x - 1, y) +  dzdy(x, y);
%         end
%     end 
% end
% % Middle to bottom-left
% for x = (h/2):1:h
%     for y = (w/2):(-1):1
%         if x == h / 2 || y == w / 2
%             depth_map(x, y) = height_map(x, y);
%         else
%              depth_map(x, y) = depth_map(x - 1, y + 1) - dzdx(x - 1, y) + dzdy(x, y);
%         end
%     end
% end

% Show the height map by integrating from the middle
% figure, title('Meshgrid Height Map');
% [x2, y2] = meshgrid(1:1:w, 1:1:h);
% mesh(x2, y2, depth_map);


% Calculate the dpdy - dqdx for each pixel
% checked = ones(h, w);
% for x = 1:1:h - 1
%     for y = 1:1:w - 1
%         checked(x, y) = fix((dzdx(x, y + 1) - dzdx(x, y)) - (dzdy(x + 1, y) - dzdy(x, y)) ^ 2);
%     end
% end



% Creating a new shaded image by choosing a new light source position vector 
% and calculating the dot product of surface normals 
% and light source vector (both normalized) at each pixel
% light_source = [0, 0.2, 1];
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

% An implementation of Frankot and Chellappa'a algorithm for constructing
% an integrable surface from gradient information.
% Bonus part

% [rows, cols] = size(dzdx);
% 
% [wx, wy] = meshgrid(([1 : cols] - fix(cols / 2 + 1)) / (cols - mod(cols, 2)), ([1 : rows] - fix(rows / 2 + 1)) / (rows - mod(rows, 2)));
%           
% wx = ifftshift(wx);
% wy = ifftshift(wy);
% 
% DZDX = fft2(dzdx);
% DZDY = fft2(dzdy);
% 
% Z = (-j * wx .* DZDX - j * wy .* DZDY) ./ (wx .^ 2 + wy .^ 2 + eps);
% 
% z = real(ifft2(Z));
% 
% figure(1), title('Depth Map');
% [x, y] = meshgrid(1:1:rows, 1:1:cols);
% mesh(x, y, z);
% figure(2), title('Depth Map');
% surf(x, y, z, 'EdgeColor', 'none');
% camlight left;
% lighting phong;


% height_map_greyscaled = (height_map(:) - min(height_map(:)))/ (max(height_map(:)) - min(height_map(:)));
% height_map_greyscaled = reshape(height_map_greyscaled, w, h);
% 
% % show the three components of surface normal vector
% figure(1), title('surface normal vector');
% subplot(1, 3, 1), title('normal X'), hold on;
% imshow(normal_x);
% subplot(1, 3, 2), title('normal Y'), hold on;
% imshow(normal_y);
% subplot(1, 3, 3), title('normal Z'), hold on;
% imshow(normal_z);
% 
%Show the albedo map
% figure(2), title('albedo map'), hold on;
% imshow(albedo);

% % Show the needle map(2D vectors on the 100 * 100 grif)
% figure(3), title('2D Vector Map'), hold on;
% [x1, y1] = meshgrid(1:1:w, 1:1:h);
% quiver(x1, y1, normal_x, normal_y);
% axis tight;
% axis square;
% 
% Show the mesh grid map
% figure(4), title('Meshgrid Height Map'), hold on;
% [x2, y2] = meshgrid(1:1:w, 1:1:h);
% mesh(x2, y2, height_map);

%Show the height map
% figure(5), title('Surf Height Map'), hold on;
% [x3, y3] = meshgrid(1:1:w, 1:1:h);
% surf(x3, y3, height_map, 'EdgeColor', 'none');
% camlight left;
% lighting phong;
% 
% % Show the greyscaled height map
% figure(6), title('Greyscaled Height Map'), hold on;
% imshow(height_map_greyscaled);