% % Load sphere images
img1 = imread('/sphere-images/real1.bmp');
img1_scaled = double(img1) ./ 255.0;
img2 = imread('/sphere-images/real2.bmp');
img2_scaled = double(img2) ./ 255.0;
img3 = imread('/sphere-images/real3.bmp');
img3_scaled = double(img3) ./ 255.0;
img4 = imread('/sphere-images/real4.bmp');
img4_scaled = double(img4) ./ 255.0;

% View Matrix from sphere-images
v1 = [0.38359, 0.236647, 0.89266];
v2 = [0.372825, -0.303914, 0.87672];
v3 = [-0.250814, -0.34752, 0.903505];
v4 = [-0.203844, 0.096308, 0.974255];
V = [v1; v2; v3; v4];

w = 460;
h = 460;

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
%             depth_map(x, y) = depth_map(x - 1, y + 1) - dzdx(x - 1, y) + dzdy(x, y);
%         end
%     end
% end

% % Show the height map by integrating from the middle
% figure, title('Meshgrid Height Map');
% [x2, y2] = meshgrid(1:1:w, 1:1:h);
% mesh(x2, y2, depth_map);

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

% figure(1), title('new shaded image'), hold on;
% imshow(new_shaded_image);


% Calculate the dpdy - dqdx for each pixel
% checked = ones(h, w);
% for x = 1:1:h - 1
%     for y = 1:1:w - 1
%         checked(x, y) = fix((dzdx(x, y + 1) - dzdx(x, y)) - (dzdy(x + 1, y) - dzdy(x, y)) ^ 2);
%     end
% end

% height_map_greyscaled = (height_map(:) - min(height_map(:)))/ (max(height_map(:)) - min(height_map(:)));
% height_map_greyscaled = reshape(height_map_greyscaled, w, h);

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
% figure(7);
% [x, y] = meshgrid(1:1:rows, 1:1:cols);
% mesh(x, y, z);
% figure(8);
% surf(x, y, z, 'EdgeColor', 'none');
% camlight left;
% lighting phong;

% % show the three components of surface normal vector
% figure(1), title('surface normal vector'), hold on;
% subplot(1, 3, 1), title('normal X'), hold on;
% imshow(normal_x);
% subplot(1, 3, 2), title('normal Y'), hold on;
% imshow(normal_y);
% subplot(1, 3, 3), title('normal Z'), hold on;
% imshow(normal_z);
% hold off;

% % Show the albedo map
% figure(2);
% title('albedo map'), hold on;
% imshow(albedo);
% hold off;

% % Show the needle map(2D vectors on the 100 * 100 grif)
% figure(3), title('2D Vector Map'), hold on;
% [x1, y1] = meshgrid(1:1:w, 1:1:h);
% quiver(x1, y1, normal_x, normal_y);
% axis tight, axis square, hold off;

% Show the mesh grid map
% figure(4), title('Mesh Grid Map'), hold on;
% [x2, y2] = meshgrid(1:1:w, 1:1:h);
% mesh(x2, y2, height_map);
% hold off;
% 
% % Show the height map
% figure(5), title('Surf Height Map'), hold on;
% [x3, y3] = meshgrid(1:1:w, 1:1:h);
% surf(x3, y3, height_map, 'EdgeColor', 'none');
% hold off;

% % Show the greyscaled height map
% figure(6), title('Greyscaled Height Map'), hold on;
% imshow(height_map_greyscaled);
% hold off;
 
% % Show the Height Map by surf() Method
% figure(7), title('Surf Height Map'), hold on;
% [x3, y3] = meshgrid(1:1:w, 1:1:h);
% surf(wx, wy, z, 'EdgeColor', 'none');
% hold off;

% % Show the quiver3, the space complexity is too high, approximatelty 300 GB 
% figure(7);
% [x4, y4] = meshgrid(1:1:w, 1:1:h);
% z4 = height_map(x4, y4);
% [u, v, w] = surfnorm(z4);
% quiver3(z4, u, v, w);