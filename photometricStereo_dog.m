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

for i = 1:1:w
    for j = 1:1:h
        i_matrix = [img1_scaled(i, j), img2_scaled(i, j), img3_scaled(i, j), img4_scaled(i, j)];
        Ti = transpose(i_matrix .^ 2);
        T = zeros(4, 4);
        for k = 1:1:4
            T(k, k) = i_matrix(k);
        end
        % Here might be a problem to calculate g(x, y)
        if Ti == zeros(4, 1)
            albedo(i, j) = 0;
            normal_x(i, j) = 0;
            normal_y(i, j) = 0;
            normal_z(i, j) = 0;
            p = 0;
            q = 0;
         else
            g = pinv(T * V) * Ti;
            albedo(i, j) = norm(g);
            % calculate the albedo and normal
            normal = g ./ albedo(i, j);
            % Store the normals, 3 components
            normal_x(i, j) = normal(1);
            normal_y(i, j) = normal(2);
            normal_z(i, j) = normal(3);
            % calculate p and q
            p = normal(1) / normal(3);
            q = normal(2) / normal(3);
        end
        % integrate the height map
        if i - 1 >= 1
            height_map(i, j) = height_map(i - 1, j) + q;
        else
            height_map(i, j) = q;
        end
        if j - 1>= 1
            height_map(i, j) = height_map(i, j - 1) + p;
        else
            height_map(i, j) = p;
        end
    end
end

height_map_greyscaled = (height_map(:) - min(height_map(:)))/ (max(height_map(:)) - min(height_map(:)));
height_map_greyscaled = reshape(height_map_greyscaled, w, h);

% show the three components of surface normal vector
figure(1), title('surface normal vector');
subplot(1, 3, 1), title('normal X');
imshow(normal_x);
subplot(1, 3, 2), title('normal Y');
imshow(normal_y);
subplot(1, 3, 3), title('normal Z');
imshow(normal_z);

% Show the albedo map
figure(2), title('albedo map');
imshow(albedo);

% Show the needle map(2D vectors on the 100 * 100 grif)
figure(3), title('2D Vector Map');
[x1, y1] = meshgrid(1:1:w, 1:1:h);
quiver(x1, y1, normal_x, normal_y);
axis tight;
axis square;

% Show the mesh grid map
figure(4), title('Mesh Grid Map');
[x2, y2] = meshgrid(1:1:w, 1:1:h);
mesh(x2, y2, height_map);

% Show the height map
figure(5), title('Surf Height Map');
[x3, y3] = meshgrid(1:1:w, 1:1:h);
surf(x3, y3, height_map, 'EdgeColor', 'none');
camlight left;
lighting phong;

% Show the greyscaled height map
figure(6), title('Greyscaled Height Map');
imshow(height_map_greyscaled);